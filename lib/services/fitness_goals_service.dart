import 'package:hive_flutter/hive_flutter.dart';

import '../models/fitness_goals_model.dart';

class FitnessGoalsService {
  static const String _boxName = 'fittrack_fitness_goals_box';

  static const String _goalsKey = 'fitness_goals';

  static Future<void> init() async {
    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.openBox(_boxName);
    }
  }

  static Box get _box {
    if (!Hive.isBoxOpen(_boxName)) {
      throw StateError(
        'FitnessGoalsService is not initialized. '
        'Call FitnessGoalsService.init() first.',
      );
    }

    return Hive.box(_boxName);
  }

  /// Returns all saved fitness goals.
  static List<FitnessGoals> getAllGoals() {
    if (!Hive.isBoxOpen(_boxName)) {
      return <FitnessGoals>[];
    }

    final dynamic data = _box.get(_goalsKey, defaultValue: <dynamic>[]);

    if (data is! List) {
      return <FitnessGoals>[];
    }

    return data
        .whereType<Map>()
        .map((item) => FitnessGoals.fromMap(Map<String, dynamic>.from(item)))
        .toList();
  }

  /// Returns goals for the specified user.
  ///
  /// If the user does not have saved goals,
  /// default goals are created and returned.
  static Future<FitnessGoals> getGoalsForUser(String userId) async {
    await init();

    final List<FitnessGoals> allGoals = getAllGoals();

    for (final FitnessGoals goals in allGoals) {
      if (goals.userId == userId) {
        return goals;
      }
    }

    final FitnessGoals defaultGoals = FitnessGoals(
      userId: userId,
      dailySteps: 10000,
      dailyCalories: 500,
      dailyDuration: 60,
    );

    allGoals.add(defaultGoals);

    await _saveGoals(allGoals);

    return defaultGoals;
  }

  /// Saves or updates goals for a specific user.
  ///
  /// Existing goals belonging to another user
  /// cannot be modified through this method.
  static Future<void> saveGoals(FitnessGoals goals) async {
    await init();

    final List<FitnessGoals> allGoals = getAllGoals();

    final int index = allGoals.indexWhere(
      (item) => item.userId == goals.userId,
    );

    if (index == -1) {
      allGoals.add(goals);
    } else {
      allGoals[index] = goals;
    }

    await _saveGoals(allGoals);
  }

  /// Updates goals only for the supplied user.
  ///
  /// Returns true when the goals were updated.
  /// Returns false when no goals exist for that user.
  static Future<bool> updateGoals({
    required String userId,
    required FitnessGoals updatedGoals,
  }) async {
    await init();

    final List<FitnessGoals> allGoals = getAllGoals();

    final int index = allGoals.indexWhere((goals) => goals.userId == userId);

    if (index == -1) {
      return false;
    }

    allGoals[index] = updatedGoals.copyWith(userId: userId);

    await _saveGoals(allGoals);

    return true;
  }

  /// Deletes goals only for the supplied user.
  ///
  /// Returns true when goals were deleted.
  /// Returns false when no goals were found.
  static Future<bool> deleteGoals(String userId) async {
    await init();

    final List<FitnessGoals> allGoals = getAllGoals();

    final int originalLength = allGoals.length;

    allGoals.removeWhere((goals) => goals.userId == userId);

    if (allGoals.length == originalLength) {
      return false;
    }

    await _saveGoals(allGoals);

    return true;
  }

  /// Deletes all goals.
  ///
  /// This method is intended for local data
  /// cleanup/testing and is not used for
  /// normal user operations.
  static Future<void> clearAllGoals() async {
    await init();

    await _box.delete(_goalsKey);
  }

  static Future<void> _saveGoals(List<FitnessGoals> goals) async {
    await _box.put(_goalsKey, goals.map((goal) => goal.toMap()).toList());
  }
}
