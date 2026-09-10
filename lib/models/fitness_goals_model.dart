class FitnessGoals {
  final String userId;
  final int dailySteps;
  final double dailyCalories;
  final int dailyDuration;

  // Daily distance goal in kilometers.
  final double dailyDistanceKm;

  const FitnessGoals({
    required this.userId,
    required this.dailySteps,
    required this.dailyCalories,
    required this.dailyDuration,
    required this.dailyDistanceKm,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'dailySteps': dailySteps,
      'dailyCalories': dailyCalories,
      'dailyDuration': dailyDuration,
      'dailyDistanceKm': dailyDistanceKm,
    };
  }

  factory FitnessGoals.fromMap(Map<String, dynamic> map) {
    final dynamic rawDistance = map['dailyDistanceKm'];

    final double parsedDistance = rawDistance is num
        ? rawDistance.toDouble()
        : double.tryParse(rawDistance?.toString() ?? '') ?? 5.0;

    return FitnessGoals(
      userId: map['userId']?.toString() ?? '',
      dailySteps: (map['dailySteps'] as num?)?.toInt() ?? 10000,
      dailyCalories: (map['dailyCalories'] as num?)?.toDouble() ?? 500,
      dailyDuration: (map['dailyDuration'] as num?)?.toInt() ?? 60,
      dailyDistanceKm: parsedDistance > 0 ? parsedDistance : 5.0,
    );
  }

  FitnessGoals copyWith({
    String? userId,
    int? dailySteps,
    double? dailyCalories,
    int? dailyDuration,
    double? dailyDistanceKm,
  }) {
    return FitnessGoals(
      userId: userId ?? this.userId,
      dailySteps: dailySteps ?? this.dailySteps,
      dailyCalories: dailyCalories ?? this.dailyCalories,
      dailyDuration: dailyDuration ?? this.dailyDuration,
      dailyDistanceKm: dailyDistanceKm ?? this.dailyDistanceKm,
    );
  }
}
