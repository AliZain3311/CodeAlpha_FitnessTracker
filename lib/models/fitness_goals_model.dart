class FitnessGoals {
  final String userId;
  final int dailySteps;
  final double dailyCalories;
  final int dailyDuration;

  const FitnessGoals({
    required this.userId,
    required this.dailySteps,
    required this.dailyCalories,
    required this.dailyDuration,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'dailySteps': dailySteps,
      'dailyCalories': dailyCalories,
      'dailyDuration': dailyDuration,
    };
  }

  factory FitnessGoals.fromMap(Map<String, dynamic> map) {
    return FitnessGoals(
      userId: map['userId']?.toString() ?? '',
      dailySteps: (map['dailySteps'] as num?)?.toInt() ?? 10000,
      dailyCalories: (map['dailyCalories'] as num?)?.toDouble() ?? 500,
      dailyDuration: (map['dailyDuration'] as num?)?.toInt() ?? 60,
    );
  }

  FitnessGoals copyWith({
    String? userId,
    int? dailySteps,
    double? dailyCalories,
    int? dailyDuration,
  }) {
    return FitnessGoals(
      userId: userId ?? this.userId,
      dailySteps: dailySteps ?? this.dailySteps,
      dailyCalories: dailyCalories ?? this.dailyCalories,
      dailyDuration: dailyDuration ?? this.dailyDuration,
    );
  }
}
