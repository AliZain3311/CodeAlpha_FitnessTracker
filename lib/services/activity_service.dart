import 'package:hive_flutter/hive_flutter.dart';

import '../models/activity_model.dart';

class ActivityService {
  static const String _boxName = 'fittrack_activities_box';

  static const String _activitiesKey = 'activities';

  static Future<void> init() async {
    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.openBox(_boxName);
    }
  }

  static Box get _box {
    if (!Hive.isBoxOpen(_boxName)) {
      throw StateError(
        'ActivityService is not initialized. '
        'Call ActivityService.init() first.',
      );
    }

    return Hive.box(_boxName);
  }

  static List<Activity> getAllActivities() {
    if (!Hive.isBoxOpen(_boxName)) {
      return <Activity>[];
    }

    final dynamic data = _box.get(_activitiesKey, defaultValue: <dynamic>[]);

    if (data is! List) {
      return <Activity>[];
    }

    return data
        .whereType<Map>()
        .map((item) => Activity.fromMap(Map<String, dynamic>.from(item)))
        .toList();
  }

  static List<Activity> getActivitiesForUser(String userId) {
    return getAllActivities()
        .where((activity) => activity.userId == userId)
        .toList();
  }

  static Future<void> addActivity(Activity activity) async {
    await init();

    final List<Activity> activities = getAllActivities();

    activities.add(activity);

    await _saveActivities(activities);
  }

  /// Updates an activity only when the activity
  /// belongs to the supplied user.
  ///
  /// Returns true when the activity was updated.
  /// Returns false when the activity does not
  /// exist or does not belong to the user.
  static Future<bool> updateActivity({
    required Activity updatedActivity,
    required String userId,
  }) async {
    await init();

    final List<Activity> activities = getAllActivities();

    final int index = activities.indexWhere(
      (activity) =>
          activity.id == updatedActivity.id && activity.userId == userId,
    );

    if (index == -1) {
      return false;
    }

    // Preserve the authenticated user's ID.
    activities[index] = updatedActivity.copyWith(userId: userId);

    await _saveActivities(activities);

    return true;
  }

  /// Deletes an activity only when the activity
  /// belongs to the supplied user.
  ///
  /// Returns true when the activity was deleted.
  /// Returns false when the activity does not
  /// exist or does not belong to the user.
  static Future<bool> deleteActivity({
    required String activityId,
    required String userId,
  }) async {
    await init();

    final List<Activity> activities = getAllActivities();

    final int originalLength = activities.length;

    activities.removeWhere(
      (activity) => activity.id == activityId && activity.userId == userId,
    );

    if (activities.length == originalLength) {
      return false;
    }

    await _saveActivities(activities);

    return true;
  }

  static Future<void> deleteUserActivities(String userId) async {
    await init();

    final List<Activity> activities = getAllActivities();

    activities.removeWhere((activity) => activity.userId == userId);

    await _saveActivities(activities);
  }

  static Future<void> clearAllActivities() async {
    await init();

    await _box.delete(_activitiesKey);
  }

  static Future<void> _saveActivities(List<Activity> activities) async {
    await _box.put(
      _activitiesKey,
      activities.map((activity) => activity.toMap()).toList(),
    );
  }
}
