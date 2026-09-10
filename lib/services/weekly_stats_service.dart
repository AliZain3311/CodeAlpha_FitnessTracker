import '../models/activity_model.dart';
import '../models/weekly_stats_model.dart';
import 'activity_service.dart';

class WeeklyStatsService {
  /// Returns statistics for the last 7 days,
  /// including today.
  ///
  /// Only activities belonging to the supplied
  /// userId are included.
  static List<WeeklyStats> getLast7DaysStats(String userId) {
    final List<Activity> userActivities = ActivityService.getActivitiesForUser(
      userId,
    );

    final DateTime today = _dateOnly(DateTime.now());

    final List<WeeklyStats> weeklyStats = <WeeklyStats>[];

    for (int dayOffset = 6; dayOffset >= 0; dayOffset--) {
      final DateTime date = today.subtract(Duration(days: dayOffset));

      final List<Activity> dailyActivities = userActivities.where((activity) {
        final DateTime activityDate = _dateOnly(activity.date);

        return activityDate.year == date.year &&
            activityDate.month == date.month &&
            activityDate.day == date.day;
      }).toList();

      final int activityCount = dailyActivities.length;

      final int duration = dailyActivities.fold(
        0,
        (total, activity) => total + activity.duration,
      );

      final double calories = dailyActivities.fold(
        0.0,
        (total, activity) => total + activity.calories,
      );

      final int steps = dailyActivities.fold(
        0,
        (total, activity) => total + activity.steps,
      );

      weeklyStats.add(
        WeeklyStats(
          date: date,
          activityCount: activityCount,
          duration: duration,
          calories: calories,
          steps: steps,
        ),
      );
    }

    return weeklyStats;
  }

  /// Total number of activities for the last 7 days.
  static int getWeeklyActivityCount(String userId) {
    final List<WeeklyStats> stats = getLast7DaysStats(userId);

    return stats.fold(0, (total, day) => total + day.activityCount);
  }

  /// Total workout duration for the last 7 days.
  static int getWeeklyDuration(String userId) {
    final List<WeeklyStats> stats = getLast7DaysStats(userId);

    return stats.fold(0, (total, day) => total + day.duration);
  }

  /// Total calories burned for the last 7 days.
  static double getWeeklyCalories(String userId) {
    final List<WeeklyStats> stats = getLast7DaysStats(userId);

    return stats.fold(0.0, (total, day) => total + day.calories);
  }

  /// Total steps for the last 7 days.
  static int getWeeklySteps(String userId) {
    final List<WeeklyStats> stats = getLast7DaysStats(userId);

    return stats.fold(0, (total, day) => total + day.steps);
  }

  /// Average calories burned per day.
  static double getAverageDailyCalories(String userId) {
    final List<WeeklyStats> stats = getLast7DaysStats(userId);

    if (stats.isEmpty) {
      return 0;
    }

    final double totalCalories = stats.fold(
      0.0,
      (total, day) => total + day.calories,
    );

    return totalCalories / stats.length;
  }

  /// Average steps per day.
  static double getAverageDailySteps(String userId) {
    final List<WeeklyStats> stats = getLast7DaysStats(userId);

    if (stats.isEmpty) {
      return 0;
    }

    final int totalSteps = stats.fold(0, (total, day) => total + day.steps);

    return totalSteps / stats.length;
  }

  /// Average workout duration per day.
  static double getAverageDailyDuration(String userId) {
    final List<WeeklyStats> stats = getLast7DaysStats(userId);

    if (stats.isEmpty) {
      return 0;
    }

    final int totalDuration = stats.fold(
      0,
      (total, day) => total + day.duration,
    );

    return totalDuration / stats.length;
  }

  /// Returns the day with the highest number
  /// of recorded activities.
  ///
  /// Returns null when there is no activity
  /// during the last 7 days.
  static WeeklyStats? getMostActiveDay(String userId) {
    final List<WeeklyStats> stats = getLast7DaysStats(userId);

    if (stats.isEmpty) {
      return null;
    }

    WeeklyStats? mostActiveDay;

    for (final WeeklyStats day in stats) {
      if (day.activityCount == 0) {
        continue;
      }

      if (mostActiveDay == null ||
          day.activityCount > mostActiveDay.activityCount) {
        mostActiveDay = day;
      } else if (day.activityCount == mostActiveDay.activityCount &&
          day.duration > mostActiveDay.duration) {
        // If activity counts are equal,
        // use workout duration as a tiebreaker.
        mostActiveDay = day;
      }
    }

    return mostActiveDay;
  }

  /// Returns the day with the highest calories.
  ///
  /// Returns null when no calories were recorded.
  static WeeklyStats? getHighestCaloriesDay(String userId) {
    final List<WeeklyStats> stats = getLast7DaysStats(userId);

    if (stats.isEmpty) {
      return null;
    }

    WeeklyStats? highestCaloriesDay;

    for (final WeeklyStats day in stats) {
      if (day.calories <= 0) {
        continue;
      }

      if (highestCaloriesDay == null ||
          day.calories > highestCaloriesDay.calories) {
        highestCaloriesDay = day;
      }
    }

    return highestCaloriesDay;
  }

  /// Returns the day with the highest steps.
  ///
  /// Returns null when no steps were recorded.
  static WeeklyStats? getHighestStepsDay(String userId) {
    final List<WeeklyStats> stats = getLast7DaysStats(userId);

    if (stats.isEmpty) {
      return null;
    }

    WeeklyStats? highestStepsDay;

    for (final WeeklyStats day in stats) {
      if (day.steps <= 0) {
        continue;
      }

      if (highestStepsDay == null || day.steps > highestStepsDay.steps) {
        highestStepsDay = day;
      }
    }

    return highestStepsDay;
  }

  /// Returns the date without time information.
  static DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
}
