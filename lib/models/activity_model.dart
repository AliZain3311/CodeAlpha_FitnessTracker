class Activity {
  final String id;
  final String userId;
  final String type;
  final String title;
  final int duration;
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
    required this.calories,
    required this.steps,
    required this.date,
    required this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'type': type,
      'title': title,
      'duration': duration,
      'calories': calories,
      'steps': steps,
      'date': date.toIso8601String(),
      'notes': notes,
    };
  }

  factory Activity.fromMap(Map<String, dynamic> map) {
    return Activity(
      id: map['id']?.toString() ?? '',
      userId: map['userId']?.toString() ?? '',
      type: map['type']?.toString() ?? 'Other',
      title: map['title']?.toString() ?? 'Activity',
      duration: (map['duration'] as num?)?.toInt() ?? 0,
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
      calories: calories ?? this.calories,
      steps: steps ?? this.steps,
      date: date ?? this.date,
      notes: notes ?? this.notes,
    );
  }
}
