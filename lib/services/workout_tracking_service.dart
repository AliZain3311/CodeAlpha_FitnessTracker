import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:pedometer/pedometer.dart';
import 'package:uuid/uuid.dart';

import '../models/workout_session_model.dart';
import 'auth_service.dart';
import 'permission_service.dart';

class WorkoutTrackingService {
  WorkoutTrackingService({this.onUpdate, this.onError});

  final void Function(WorkoutSession session)? onUpdate;
  final void Function(String message)? onError;

  final Uuid _uuid = const Uuid();

  StreamSubscription<Position>? _positionSubscription;
  StreamSubscription<StepCount>? _stepSubscription;
  Timer? _timer;

  WorkoutSession? _session;

  Position? _lastPosition;

  int? _initialSteps;
  int _currentRawSteps = 0;

  bool _isRunning = false;
  bool _isPaused = false;

  Duration _accumulatedDuration = Duration.zero;

  DateTime? _activeStartTime;

  // A minimum walking/running speed helps
  // prevent stationary GPS drift from being
  // counted as workout movement.
  static const double _minimumMovementSpeedMps = 0.8;

  // Ignore very inaccurate GPS readings.
  static const double _maximumGpsAccuracyMeters = 20.0;

  // Ignore impossible GPS jumps.
  static const double _maximumGpsJumpMeters = 100.0;

  // Ignore tiny GPS drift.
  static const double _minimumMovementDistanceMeters = 5.0;

  WorkoutSession? get session => _session;

  bool get isRunning => _isRunning;

  bool get isPaused => _isPaused;

  Future<bool> startWorkout({required String activityType}) async {
    final String? userId = AuthService.currentUserId;

    if (userId == null) {
      onError?.call('Please login before starting a workout.');
      return false;
    }

    if (_isRunning) {
      onError?.call('A workout is already running.');
      return false;
    }

    final bool permissionsGranted =
        await PermissionService.requestTrackingPermissions();

    if (!permissionsGranted) {
      onError?.call(
        'Location and physical activity permissions are required for real-time tracking.',
      );
      return false;
    }

    final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      onError?.call('Please turn on your device location service.');
      return false;
    }

    _resetTrackingData();

    final DateTime startTime = DateTime.now();

    _session = WorkoutSession(
      id: _uuid.v4(),
      userId: userId,
      activityType: activityType,
      startTime: startTime,
      endTime: null,
      duration: Duration.zero,
      distanceKm: 0,
      steps: 0,
      calories: 0,
      isCompleted: false,
    );

    _isRunning = true;
    _isPaused = false;

    _accumulatedDuration = Duration.zero;

    _activeStartTime = startTime;

    await _startLocationTracking();
    await _startStepTracking();

    _startTimer();

    _notifyUpdate();

    return true;
  }

  void pauseWorkout() {
    if (!_isRunning || _isPaused) {
      return;
    }

    final DateTime now = DateTime.now();

    _updateAccumulatedDuration(now);

    _isPaused = true;

    _timer?.cancel();
    _timer = null;

    _positionSubscription?.pause();
    _stepSubscription?.pause();

    _updateSessionDuration();
    _updateCalories();

    _notifyUpdate();
  }

  void resumeWorkout() {
    if (!_isRunning || !_isPaused) {
      return;
    }

    _isPaused = false;

    _activeStartTime = DateTime.now();

    // Do not connect the GPS point before
    // pause with the point after resume.
    _lastPosition = null;

    _positionSubscription?.resume();
    _stepSubscription?.resume();

    _startTimer();

    _updateSessionDuration();
    _updateCalories();

    _notifyUpdate();
  }

  WorkoutSession? stopWorkout() {
    if (!_isRunning || _session == null) {
      return null;
    }

    final DateTime endTime = DateTime.now();

    if (!_isPaused) {
      _updateAccumulatedDuration(endTime);
    }

    _isRunning = false;
    _isPaused = false;

    _timer?.cancel();
    _timer = null;

    _positionSubscription?.cancel();
    _positionSubscription = null;

    _stepSubscription?.cancel();
    _stepSubscription = null;

    _activeStartTime = null;

    _updateSessionDuration();
    _updateCalories();

    _session = _session!.copyWith(
      endTime: endTime,
      duration: _accumulatedDuration,
      isCompleted: true,
    );

    _notifyUpdate();

    return _session;
  }

  void dispose() {
    _timer?.cancel();
    _positionSubscription?.cancel();
    _stepSubscription?.cancel();

    _timer = null;
    _positionSubscription = null;
    _stepSubscription = null;

    _activeStartTime = null;
    _accumulatedDuration = Duration.zero;

    _isRunning = false;
    _isPaused = false;
  }

  Future<void> _startLocationTracking() async {
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5,
    );

    _positionSubscription =
        Geolocator.getPositionStream(locationSettings: locationSettings).listen(
          _handlePositionUpdate,
          onError: (Object error) {
            onError?.call('Unable to receive GPS updates.');
          },
        );

    try {
      final Position currentPosition = await Geolocator.getCurrentPosition(
        locationSettings: locationSettings,
      );

      if (_isUsableGpsPosition(currentPosition)) {
        // First GPS point is only a
        // reference point. It is never
        // counted as workout distance.
        _lastPosition = currentPosition;
      }
    } catch (_) {
      _lastPosition = null;
    }
  }

  Future<void> _startStepTracking() async {
    try {
      _stepSubscription = Pedometer.stepCountStream.listen(
        _handleStepUpdate,
        onError: (Object error) {
          onError?.call('Unable to receive step updates.');
        },
      );
    } catch (_) {
      onError?.call('Step tracking is not available on this device.');
    }
  }

  void _handlePositionUpdate(Position position) {
    if (!_isRunning || _isPaused || _session == null) {
      return;
    }

    if (!_isUsableGpsPosition(position)) {
      return;
    }

    if (_lastPosition == null) {
      _lastPosition = position;
      return;
    }

    final double distanceMeters = Geolocator.distanceBetween(
      _lastPosition!.latitude,
      _lastPosition!.longitude,
      position.latitude,
      position.longitude,
    );

    if (distanceMeters >= _maximumGpsJumpMeters) {
      // GPS jump/noise. Do not accept it
      // and do not move the reference point.
      return;
    }

    if (distanceMeters < _minimumMovementDistanceMeters) {
      // Tiny GPS drift while stationary.
      return;
    }

    // A real walking/running movement should
    // normally have a meaningful GPS speed.
    // This prevents a stationary phone from
    // accumulating distance from GPS drift.
    final double speedMps = position.speed.isFinite && position.speed > 0
        ? position.speed
        : 0;

    if (speedMps < _minimumMovementSpeedMps) {
      // Keep the current GPS reference
      // until genuine movement is detected.
      return;
    }

    final double additionalKm = distanceMeters / 1000;

    _session = _session!.copyWith(
      distanceKm: _session!.distanceKm + additionalKm,
    );

    _lastPosition = position;

    _updateCalories();

    _notifyUpdate();
  }

  void _handleStepUpdate(StepCount event) {
    if (!_isRunning || _isPaused || _session == null) {
      return;
    }

    _currentRawSteps = event.steps;

    // The first pedometer value is the
    // device's baseline, not workout steps.
    _initialSteps ??= event.steps;

    final int sessionSteps = _currentRawSteps - _initialSteps!;

    final int safeSteps = sessionSteps < 0 ? 0 : sessionSteps;

    _session = _session!.copyWith(steps: safeSteps);

    _updateCalories();

    _notifyUpdate();
  }

  void _startTimer() {
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!_isRunning || _isPaused || _session == null) {
        return;
      }

      final DateTime now = DateTime.now();

      _updateAccumulatedDuration(now);

      _updateSessionDuration();

      // Calories are deliberately updated
      // here only from actual movement data.
      _updateCalories();

      _notifyUpdate();
    });
  }

  void _updateAccumulatedDuration(DateTime now) {
    if (_activeStartTime == null) {
      return;
    }

    final Duration activeSegment = now.difference(_activeStartTime!);

    if (activeSegment.isNegative) {
      return;
    }

    _accumulatedDuration += activeSegment;

    _activeStartTime = now;
  }

  void _updateSessionDuration() {
    if (_session == null) {
      return;
    }

    _session = _session!.copyWith(duration: _accumulatedDuration);
  }

  void _updateCalories() {
    if (_session == null) {
      return;
    }

    // Calories must NOT increase merely
    // because the workout timer is running.
    //
    // We calculate them only from actual
    // movement metrics:
    // - GPS distance
    // - pedometer steps
    //
    // If there is no movement, calories stay 0.

    final double distanceCalories = _session!.distanceKm * 60.0;

    final double stepCalories = _session!.steps * 0.04;

    final double estimatedCalories = distanceCalories > stepCalories
        ? distanceCalories
        : stepCalories;

    _session = _session!.copyWith(
      calories: estimatedCalories < 0 ? 0 : estimatedCalories,
    );
  }

  bool _isUsableGpsPosition(Position position) {
    if (!position.latitude.isFinite || !position.longitude.isFinite) {
      return false;
    }

    if (position.accuracy <= 0 ||
        position.accuracy > _maximumGpsAccuracyMeters) {
      return false;
    }

    return true;
  }

  void _resetTrackingData() {
    _lastPosition = null;
    _initialSteps = null;
    _currentRawSteps = 0;
    _session = null;

    _accumulatedDuration = Duration.zero;

    _activeStartTime = null;

    _timer?.cancel();
    _positionSubscription?.cancel();
    _stepSubscription?.cancel();

    _timer = null;
    _positionSubscription = null;
    _stepSubscription = null;
  }

  void _notifyUpdate() {
    final WorkoutSession? currentSession = _session;

    if (currentSession != null) {
      onUpdate?.call(currentSession);
    }
  }
}
