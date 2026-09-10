class WeeklyStats {
  final DateTime date;
  final int activityCount;
  final int duration;
  final double calories;
  final int steps;

  const WeeklyStats({
    required this.date,
    required this.activityCount,
    required this.duration,
    required this.calories,
    required this.steps,
  });

  WeeklyStats copyWith({
    DateTime? date,
    int? activityCount,
    int? duration,
    double? calories,
    int? steps,
  }) {
    return WeeklyStats(
      date: date ?? this.date,
      activityCount: activityCount ?? this.activityCount,
      duration: duration ?? this.duration,
      calories: calories ?? this.calories,
      steps: steps ?? this.steps,
    );
  }
}
