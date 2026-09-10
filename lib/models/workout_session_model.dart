class WorkoutSession {
  final String id;
  final String userId;
  final String activityType;
  final DateTime startTime;
  final DateTime? endTime;
  final Duration duration;
  final double distanceKm;
  final int steps;
  final double calories;
  final bool isCompleted;

  const WorkoutSession({
    required this.id,
    required this.userId,
    required this.activityType,
    required this.startTime,
    required this.endTime,
    required this.duration,
    required this.distanceKm,
    required this.steps,
    required this.calories,
    required this.isCompleted,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'activityType': activityType,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'durationSeconds': duration.inSeconds,
      'distanceKm': distanceKm,
      'steps': steps,
      'calories': calories,
      'isCompleted': isCompleted,
    };
  }

  factory WorkoutSession.fromMap(Map<String, dynamic> map) {
    final int durationSeconds = (map['durationSeconds'] as num?)?.toInt() ?? 0;

    return WorkoutSession(
      id: map['id']?.toString() ?? '',
      userId: map['userId']?.toString() ?? '',
      activityType: map['activityType']?.toString() ?? 'Running',
      startTime:
          DateTime.tryParse(map['startTime']?.toString() ?? '') ??
          DateTime.now(),
      endTime: map['endTime'] == null
          ? null
          : DateTime.tryParse(map['endTime'].toString()),
      duration: Duration(seconds: durationSeconds),
      distanceKm: (map['distanceKm'] as num?)?.toDouble() ?? 0,
      steps: (map['steps'] as num?)?.toInt() ?? 0,
      calories: (map['calories'] as num?)?.toDouble() ?? 0,
      isCompleted: map['isCompleted'] as bool? ?? false,
    );
  }

  WorkoutSession copyWith({
    String? id,
    String? userId,
    String? activityType,
    DateTime? startTime,
    DateTime? endTime,
    Duration? duration,
    double? distanceKm,
    int? steps,
    double? calories,
    bool? isCompleted,
  }) {
    return WorkoutSession(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      activityType: activityType ?? this.activityType,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      duration: duration ?? this.duration,
      distanceKm: distanceKm ?? this.distanceKm,
      steps: steps ?? this.steps,
      calories: calories ?? this.calories,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
