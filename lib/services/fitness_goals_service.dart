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
  ///
  /// Only goals that were actually saved by a user
  /// are returned. No default goal is created here.
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

  /// Returns the saved goals for a specific user.
  ///
  /// If the user has never created a goal, this returns null.
  /// This is important because "no goal" and "goal = 0"
  /// must not be treated as the same saved goal.
  static Future<FitnessGoals?> getGoalsForUser(String userId) async {
    await init();

    final List<FitnessGoals> allGoals = getAllGoals();

    for (final FitnessGoals goals in allGoals) {
      if (goals.userId == userId) {
        return goals;
      }
    }

    return null;
  }

  /// Returns true when the user has a saved goal.
  static Future<bool> hasGoalForUser(String userId) async {
    final FitnessGoals? goals = await getGoalsForUser(userId);

    return goals != null;
  }

  /// Saves a new goal or replaces the existing
  /// goal for the specified user.
  ///
  /// A zero-value goal is allowed to be stored,
  /// but the UI should normally use null/no goal
  /// to represent that no goal has been created.
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
  /// Returns false when no saved goals exist.
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

  /// Deletes the saved goal for the supplied user.
  ///
  /// This means the user has no active goal.
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

  /// Deletes all saved goals.
  ///
  /// Intended for local cleanup/testing only.
  /// Normal user operations should use deleteGoals().
  static Future<void> clearAllGoals() async {
    await init();

    await _box.delete(_goalsKey);
  }

  static Future<void> _saveGoals(List<FitnessGoals> goals) async {
    await _box.put(_goalsKey, goals.map((goal) => goal.toMap()).toList());
  }
}
