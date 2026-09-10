import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../models/activity_model.dart';
import '../models/workout_session_model.dart';
import '../models/fitness_goals_model.dart';
import '../services/activity_service.dart';
import '../services/auth_service.dart';
import '../services/workout_tracking_service.dart';
import '../services/fitness_goals_service.dart';

class WorkoutTrackerScreen extends StatefulWidget {
  const WorkoutTrackerScreen({super.key, this.initialActivityType = 'Running'});

  final String initialActivityType;

  @override
  State<WorkoutTrackerScreen> createState() => _WorkoutTrackerScreenState();
}

class _WorkoutTrackerScreenState extends State<WorkoutTrackerScreen> {
  late final WorkoutTrackingService _trackingService;

  final Uuid _uuid = const Uuid();

  final List<String> _activityTypes = [
    'Running',
    'Walking',
    'Cycling',
    'Gym',
    'Yoga',
    'Swimming',
    'Sports',
    'Other',
  ];

  String _selectedActivityType = 'Running';

  WorkoutSession? _session;

  bool _isStarting = false;
  bool _isStopping = false;
  bool _isSaving = false;

  FitnessGoals? _goals;

  bool _isDailyGoalCompleted = false;
  bool _isLoadingGoals = true;
  bool _isAutoStopping = false;

  String? _goalReachedMessage;

  bool _isGoalWorkout = false;

  @override
  void initState() {
    super.initState();

    if (_activityTypes.contains(widget.initialActivityType)) {
      _selectedActivityType = widget.initialActivityType;
    }

    _trackingService = WorkoutTrackingService(
      onUpdate: _handleTrackingUpdate,
      onError: _handleTrackingError,
    );

    _loadGoalsAndDailyProgress();
  }

  @override
  void dispose() {
    _trackingService.dispose();
    super.dispose();
  }

  Future<void> _loadGoalsAndDailyProgress() async {
    final String? userId = AuthService.currentUserId;

    if (userId == null) {
      if (mounted) {
        setState(() {
          _goals = null;
          _isDailyGoalCompleted = false;
          _isLoadingGoals = false;
        });
      }

      return;
    }

    final FitnessGoals? goals = await FitnessGoalsService.getGoalsForUser(
      userId,
    );

    if (!mounted) {
      return;
    }

    final bool hasActiveGoal = goals != null && _hasActiveGoal(goals);

    final bool completed = hasActiveGoal
        ? _isDailyGoalCompletedForUser(userId, goals)
        : false;

    setState(() {
      _goals = goals;
      _isDailyGoalCompleted = completed;
      _isLoadingGoals = false;
    });
  }

  bool _hasActiveGoal(FitnessGoals goals) {
    return goals.dailySteps > 0 ||
        goals.dailyCalories > 0 ||
        goals.dailyDuration > 0 ||
        goals.dailyDistanceKm > 0;
  }

  bool _isDailyGoalCompletedForUser(String userId, FitnessGoals goals) {
    final DateTime now = DateTime.now();

    final List<Activity> activities =
        ActivityService.getActivitiesForUser(userId).where((activity) {
          final DateTime date = activity.date;

          return date.year == now.year &&
              date.month == now.month &&
              date.day == now.day &&
              activity.notes.contains('Goal Workout Completed: true');
        }).toList();

    return activities.isNotEmpty;
  }

  void _handleTrackingUpdate(WorkoutSession session) {
    if (!mounted) {
      return;
    }

    setState(() {
      _session = session;
    });

    _checkGoalForCurrentWorkout(session);
  }

  void _checkGoalForCurrentWorkout(WorkoutSession session) {
    if (!_isGoalWorkout ||
        _isDailyGoalCompleted ||
        _isStopping ||
        _isSaving ||
        _isAutoStopping ||
        !mounted) {
      return;
    }

    final FitnessGoals? goals = _goals;

    if (goals == null || !_hasActiveGoal(goals)) {
      return;
    }

    bool hasAnyActiveTarget = false;

    bool allActiveTargetsReached = true;

    String? reachedGoalMessage;

    if (goals.dailyDistanceKm > 0) {
      hasAnyActiveTarget = true;

      final bool reached = session.distanceKm >= goals.dailyDistanceKm;

      if (!reached) {
        allActiveTargetsReached = false;
      } else {
        reachedGoalMessage =
            'Distance goal reached: ${goals.dailyDistanceKm.toStringAsFixed(1)} km';
      }
    }

    if (goals.dailySteps > 0) {
      hasAnyActiveTarget = true;

      final bool reached = session.steps >= goals.dailySteps;

      if (!reached) {
        allActiveTargetsReached = false;
      } else {
        reachedGoalMessage ??= 'Steps goal reached: ${goals.dailySteps} steps';
      }
    }

    if (goals.dailyDuration > 0) {
      hasAnyActiveTarget = true;

      final bool reached =
          session.duration.inSeconds >= goals.dailyDuration * 60;

      if (!reached) {
        allActiveTargetsReached = false;
      } else {
        reachedGoalMessage ??=
            'Duration goal reached: ${goals.dailyDuration} minutes';
      }
    }

    if (goals.dailyCalories > 0) {
      hasAnyActiveTarget = true;

      final bool reached = session.calories >= goals.dailyCalories;

      if (!reached) {
        allActiveTargetsReached = false;
      } else {
        reachedGoalMessage ??=
            'Calories goal reached: ${goals.dailyCalories.toStringAsFixed(0)} kcal';
      }
    }

    if (hasAnyActiveTarget && allActiveTargetsReached) {
      _autoStopForGoal(
        reachedGoalMessage ?? 'All active fitness goals reached',
      );
    }
  }

  Future<void> _autoStopForGoal(String message) async {
    if (_isAutoStopping ||
        _isStopping ||
        _isSaving ||
        !_trackingService.isRunning) {
      return;
    }

    _isAutoStopping = true;
    _goalReachedMessage = message;

    if (mounted) {
      setState(() {});
    }

    final WorkoutSession? completedSession = _trackingService.stopWorkout();

    if (!mounted) {
      return;
    }

    setState(() {
      _session = completedSession;
    });

    if (completedSession == null) {
      _isAutoStopping = false;
      _goalReachedMessage = null;

      setState(() {});

      return;
    }

    await _saveCompletedWorkout(completedSession, goalReached: true);
  }

  void _handleTrackingError(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  Future<void> _startWorkout({required bool goalWorkout}) async {
    final String? userId = AuthService.currentUserId;

    if (userId == null) {
      _showMessage('Please login before starting a workout.');

      return;
    }

    if (goalWorkout) {
      final FitnessGoals? goals = _goals;

      if (goals == null || !_hasActiveGoal(goals)) {
        _showMessage(
          'Please set a fitness goal before starting a Goal Workout.',
        );

        return;
      }

      if (_isDailyGoalCompleted) {
        _showMessage('Today\'s goal has already been completed.');

        return;
      }
    }

    setState(() {
      _isStarting = true;
      _isGoalWorkout = goalWorkout;
      _goalReachedMessage = null;
      _session = null;
    });

    final bool started = await _trackingService.startWorkout(
      activityType: _selectedActivityType,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _isStarting = false;
    });

    if (!started) {
      setState(() {
        _isGoalWorkout = false;
      });
    }
  }

  void _pauseWorkout() {
    _trackingService.pauseWorkout();
  }

  void _resumeWorkout() {
    _trackingService.resumeWorkout();
  }

  Future<void> _stopWorkout() async {
    if (_isStopping || _isSaving || _isAutoStopping) {
      return;
    }

    final WorkoutSession? currentSession = _trackingService.session;

    if (currentSession == null) {
      return;
    }

    final bool? shouldStop = await _showStopConfirmation();

    if (shouldStop != true) {
      return;
    }

    setState(() {
      _isStopping = true;
    });

    final WorkoutSession? completedSession = _trackingService.stopWorkout();

    if (!mounted) {
      return;
    }

    setState(() {
      _isStopping = false;
      _session = completedSession;
    });

    if (completedSession == null) {
      return;
    }

    await _saveCompletedWorkout(completedSession, goalReached: false);
  }

  Future<void> _saveCompletedWorkout(
    WorkoutSession session, {
    bool goalReached = false,
  }) async {
    final String? currentUserId = AuthService.currentUserId;

    if (currentUserId == null) {
      _showMessage('Your session cannot be saved because you are logged out.');

      return;
    }

    if (session.userId != currentUserId) {
      _showMessage('You can only save your own workout.');

      return;
    }

    setState(() {
      _isSaving = true;
    });

    final int durationSeconds = session.duration.inSeconds;

    final int durationMinutes = durationSeconds <= 0
        ? 0
        : (durationSeconds / 60).ceil();

    final String distanceText = session.distanceKm.toStringAsFixed(2);

    final String notes = goalReached
        ? 'Real-time workout • Goal Workout Completed: true • Distance: $distanceText km'
        : 'Real-time workout • Distance: $distanceText km';

    final Activity activity = Activity(
      id: _uuid.v4(),
      userId: currentUserId,
      type: session.activityType,
      title: goalReached
          ? '${session.activityType} Goal Workout'
          : '${session.activityType} Workout',
      duration: durationMinutes,
      durationSeconds: durationSeconds,
      calories: session.calories,
      steps: session.steps,
      date: session.startTime,
      notes: notes,
    );

    await ActivityService.addActivity(activity);

    if (!mounted) {
      return;
    }

    await _loadGoalsAndDailyProgress();

    if (!mounted) {
      return;
    }

    setState(() {
      _isSaving = false;
      _isAutoStopping = false;
      _isGoalWorkout = false;
    });

    await _showWorkoutCompletedDialog(session, goalReached: goalReached);

    if (!mounted) {
      return;
    }

    Navigator.of(context).pop(true);
  }

  Future<bool?> _showStopConfirmation() {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Stop Workout?'),
          content: const Text(
            'Your workout will be completed and automatically saved to your activity history.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              child: const Text('Stop & Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showWorkoutCompletedDialog(
    WorkoutSession session, {
    bool goalReached = false,
  }) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          icon: Icon(
            goalReached
                ? Icons.emoji_events_rounded
                : Icons.check_circle_rounded,
            size: 52,
            color: Theme.of(context).colorScheme.primary,
          ),
          title: Text(
            goalReached ? 'Goal Completed! 🎉' : 'Workout Completed! 🎉',
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                goalReached && _goalReachedMessage != null
                    ? 'Excellent! $_goalReachedMessage. Your goal workout was automatically completed and saved.'
                    : 'Great job! Your workout has been saved successfully.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              _summaryRow(
                Icons.timer_outlined,
                'Duration',
                _formatDuration(session.duration),
              ),
              _summaryRow(
                Icons.route_outlined,
                'Distance',
                '${session.distanceKm.toStringAsFixed(2)} km',
              ),
              _summaryRow(
                Icons.directions_walk_outlined,
                'Steps',
                '${session.steps}',
              ),
              _summaryRow(
                Icons.local_fire_department_outlined,
                'Calories',
                '${session.calories.toStringAsFixed(0)} kcal',
              ),
            ],
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                },
                child: const Text('Done'),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _summaryRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 10),
          Expanded(child: Text(label)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final String hours = duration.inHours.toString().padLeft(2, '0');

    final String minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');

    final String seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');

    return '$hours:$minutes:$seconds';
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isRunning = _trackingService.isRunning;

    final bool isPaused = _trackingService.isPaused;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Real-Time Workout',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 650),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildActivitySelector(isRunning),

                  const SizedBox(height: 20),

                  // Live stats are intentionally
                  // shown only during Goal Workout.
                  if (_isGoalWorkout) ...[
                    _buildLiveStatsCard(),

                    const SizedBox(height: 20),

                    _buildGoalProgressCard(),

                    const SizedBox(height: 20),
                  ],

                  _buildControlButtons(isRunning, isPaused),

                  const SizedBox(height: 20),

                  _buildTrackingInfoCard(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActivitySelector(bool isRunning) {
    final Color primaryColor = Theme.of(context).colorScheme.primary;

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Activity Type',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _selectedActivityType,
              decoration: InputDecoration(
                prefixIcon: Icon(
                  Icons.fitness_center_rounded,
                  color: primaryColor,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              items: _activityTypes.map((String type) {
                return DropdownMenuItem<String>(value: type, child: Text(type));
              }).toList(),
              onChanged: isRunning
                  ? null
                  : (String? value) {
                      if (value == null) {
                        return;
                      }

                      setState(() {
                        _selectedActivityType = value;
                      });
                    },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveStatsCard() {
    final Color primaryColor = Theme.of(context).colorScheme.primary;

    final WorkoutSession? session = _session;

    final Duration duration = session?.duration ?? Duration.zero;

    final double distance = session?.distanceKm ?? 0;

    final int steps = session?.steps ?? 0;

    final double calories = session?.calories ?? 0;

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.directions_run_rounded,
                size: 36,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              _selectedActivityType,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text(
              _formatDuration(duration),
              style: TextStyle(
                fontSize: 42,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
                color: primaryColor,
              ),
            ),
            const Text(
              'DURATION',
              style: TextStyle(
                fontSize: 11,
                letterSpacing: 2,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 28),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    Icons.route_outlined,
                    distance.toStringAsFixed(2),
                    'km',
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    Icons.directions_walk_outlined,
                    '$steps',
                    'steps',
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    Icons.local_fire_department_outlined,
                    calories.toStringAsFixed(0),
                    'kcal',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    final Color primaryColor = Theme.of(context).colorScheme.primary;

    return Column(
      children: [
        Icon(icon, size: 24, color: primaryColor),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildControlButtons(bool isRunning, bool isPaused) {
    if (!isRunning) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildQuickWorkoutCard(),

          // Goal Workout card itself decides
          // whether an active goal exists.
          const SizedBox(height: 14),

          _buildGoalWorkoutCard(),
        ],
      );
    }

    return Column(
      children: [
        SizedBox(
          height: 56,
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: isPaused ? _resumeWorkout : _pauseWorkout,
            icon: Icon(
              isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
            ),
            label: Text(
              isPaused ? 'Resume Workout' : 'Pause Workout',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 52,
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _isStopping || _isSaving || _isAutoStopping
                ? null
                : _stopWorkout,
            icon: _isStopping || _isSaving || _isAutoStopping
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2.5),
                  )
                : const Icon(Icons.stop_rounded),
            label: Text(
              _isStopping
                  ? 'Stopping...'
                  : _isSaving
                  ? 'Saving Workout...'
                  : _isAutoStopping
                  ? 'Completing Goal...'
                  : 'Stop & Save Workout',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGoalProgressCard() {
    final FitnessGoals? goals = _goals;

    final WorkoutSession? session = _session;

    if (goals == null || !_hasActiveGoal(goals)) {
      return const SizedBox.shrink();
    }

    final double distance = session?.distanceKm ?? 0;

    final int steps = session?.steps ?? 0;

    final int durationSeconds = session?.duration.inSeconds ?? 0;

    final double calories = session?.calories ?? 0;

    final double durationGoalSeconds = goals.dailyDuration > 0
        ? goals.dailyDuration * 60.0
        : 0;

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.flag_rounded,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Goal Workout Progress',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),

            if (goals.dailyDistanceKm > 0)
              _buildGoalProgressItem(
                icon: Icons.route_rounded,
                label: 'Distance',
                current: '${distance.toStringAsFixed(2)} km',
                target: '${goals.dailyDistanceKm.toStringAsFixed(1)} km',
                progress: distance / goals.dailyDistanceKm,
              ),

            if (goals.dailySteps > 0) ...[
              const SizedBox(height: 13),
              _buildGoalProgressItem(
                icon: Icons.directions_walk_rounded,
                label: 'Steps',
                current: '$steps',
                target: '${goals.dailySteps}',
                progress: steps / goals.dailySteps,
              ),
            ],

            if (goals.dailyDuration > 0) ...[
              const SizedBox(height: 13),
              _buildGoalProgressItem(
                icon: Icons.timer_rounded,
                label: 'Duration',
                current: _formatDuration(Duration(seconds: durationSeconds)),
                target: '${goals.dailyDuration} min',
                progress: durationGoalSeconds > 0
                    ? durationSeconds / durationGoalSeconds
                    : 0,
              ),
            ],

            if (goals.dailyCalories > 0) ...[
              const SizedBox(height: 13),
              _buildGoalProgressItem(
                icon: Icons.local_fire_department_rounded,
                label: 'Calories',
                current: '${calories.toStringAsFixed(0)} kcal',
                target: '${goals.dailyCalories.toStringAsFixed(0)} kcal',
                progress: calories / goals.dailyCalories,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildGoalProgressItem({
    required IconData icon,
    required String label,
    required String current,
    required String target,
    required double progress,
  }) {
    final Color primaryColor = Theme.of(context).colorScheme.primary;

    final double safeProgress = progress.clamp(0.0, 1.0);

    final bool reached = progress >= 1.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 19, color: reached ? Colors.green : primaryColor),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            Text(
              '$current / $target',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: reached
                    ? Colors.green
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: LinearProgressIndicator(value: safeProgress, minHeight: 8),
        ),
      ],
    );
  }

  Widget _buildQuickWorkoutCard() {
    final Color primaryColor = Theme.of(context).colorScheme.primary;

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.play_circle_fill_rounded,
                    color: primaryColor,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Quick Workout',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Start a normal workout anytime.',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 50,
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _isStarting || _isSaving
                    ? null
                    : () => _startWorkout(goalWorkout: false),
                icon: _isStarting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2.5),
                      )
                    : const Icon(Icons.play_arrow_rounded),
                label: Text(
                  _isStarting ? 'Starting...' : 'Start Workout',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalWorkoutCard() {
    final Color primaryColor = Theme.of(context).colorScheme.primary;

    if (_isLoadingGoals) {
      return const Card(
        elevation: 0,
        child: Padding(
          padding: EdgeInsets.all(18),
          child: Row(
            children: [
              SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2.5),
              ),
              SizedBox(width: 12),
              Expanded(child: Text('Checking today\'s goal status...')),
            ],
          ),
        ),
      );
    }

    final FitnessGoals? goals = _goals;

    // No saved goal = no Goal Workout.
    if (goals == null || !_hasActiveGoal(goals)) {
      return const SizedBox.shrink();
    }

    // Completed goal = no Goal Workout.
    if (_isDailyGoalCompleted) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.flag_rounded,
                    color: primaryColor,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Goal Workout',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Automatically completes when all active daily targets are reached.',
                        style: TextStyle(fontSize: 12, height: 1.35),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (goals.dailyDistanceKm > 0)
                  _buildGoalChip(
                    Icons.route_rounded,
                    '${goals.dailyDistanceKm.toStringAsFixed(1)} km',
                  ),
                if (goals.dailySteps > 0)
                  _buildGoalChip(
                    Icons.directions_walk_rounded,
                    '${goals.dailySteps} steps',
                  ),
                if (goals.dailyDuration > 0)
                  _buildGoalChip(
                    Icons.timer_rounded,
                    '${goals.dailyDuration} min',
                  ),
                if (goals.dailyCalories > 0)
                  _buildGoalChip(
                    Icons.local_fire_department_rounded,
                    '${goals.dailyCalories.toStringAsFixed(0)} kcal',
                  ),
              ],
            ),

            const SizedBox(height: 14),

            SizedBox(
              height: 50,
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _isStarting || _isSaving
                    ? null
                    : () => _startWorkout(goalWorkout: true),
                icon: const Icon(Icons.flag_circle_rounded),
                label: const Text(
                  'Start Goal Workout',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 5),
          Text(
            text,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackingInfoCard() {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.info_outline_rounded),
                SizedBox(width: 10),
                Text(
                  'Live Tracking',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'FitTrack uses your device GPS to calculate actual movement distance and the device step counter to track steps during your workout. Stationary movement does not add GPS distance.',
              style: TextStyle(
                height: 1.5,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
