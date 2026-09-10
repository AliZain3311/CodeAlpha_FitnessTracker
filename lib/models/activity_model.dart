class Activity {
  final String id;
  final String userId;
  final String type;
  final String title;
  final int duration;

  // Exact duration for real-time workouts.
  // Null means this is an older/manual activity
  // that only has duration stored in minutes.
  final int? durationSeconds;

  final double calories;
  final int steps;
  final DateTime date;
  final String notes;

  const Activity({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.duration,
    this.durationSeconds,
    required this.calories,
    required this.steps,
    required this.date,
    required this.notes,
  });

  // Returns the most accurate available duration.
  int get effectiveDurationSeconds {
    if (durationSeconds != null && durationSeconds! > 0) {
      return durationSeconds!;
    }

    // Backward compatibility for existing
    // manually logged activities.
    return duration * 60;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'type': type,
      'title': title,
      'duration': duration,
      'durationSeconds': durationSeconds,
      'calories': calories,
      'steps': steps,
      'date': date.toIso8601String(),
      'notes': notes,
    };
  }

  factory Activity.fromMap(Map<String, dynamic> map) {
    final dynamic rawDurationSeconds = map['durationSeconds'];

    final int? parsedDurationSeconds = rawDurationSeconds is num
        ? rawDurationSeconds.toInt()
        : int.tryParse(rawDurationSeconds?.toString() ?? '');

    return Activity(
      id: map['id']?.toString() ?? '',
      userId: map['userId']?.toString() ?? '',
      type: map['type']?.toString() ?? 'Other',
      title: map['title']?.toString() ?? 'Activity',
      duration: (map['duration'] as num?)?.toInt() ?? 0,
      durationSeconds:
          parsedDurationSeconds != null && parsedDurationSeconds > 0
          ? parsedDurationSeconds
          : null,
      calories: (map['calories'] as num?)?.toDouble() ?? 0,
      steps: (map['steps'] as num?)?.toInt() ?? 0,
      date: DateTime.tryParse(map['date']?.toString() ?? '') ?? DateTime.now(),
      notes: map['notes']?.toString() ?? '',
    );
  }

  Activity copyWith({
    String? id,
    String? userId,
    String? type,
    String? title,
    int? duration,
    int? durationSeconds,
    double? calories,
    int? steps,
    DateTime? date,
    String? notes,
  }) {
    return Activity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      title: title ?? this.title,
      duration: duration ?? this.duration,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      calories: calories ?? this.calories,
      steps: steps ?? this.steps,
      date: date ?? this.date,
      notes: notes ?? this.notes,
    );
  }
}
