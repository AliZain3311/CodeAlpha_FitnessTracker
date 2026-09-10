import 'package:flutter/material.dart';

import '../models/activity_model.dart';
import '../models/user_model.dart';
import '../services/activity_service.dart';
import '../services/auth_service.dart';
import '../widgets/app_drawer.dart';
import 'add_activity_screen.dart';
import 'workout_tracker_screen.dart';

class DashboardScreen extends StatefulWidget {
  final VoidCallback? onLogout;

  const DashboardScreen({super.key, this.onLogout});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Activity> _activities = <Activity>[];

  @override
  void initState() {
    super.initState();
    _loadActivities();
  }

  void _loadActivities() {
    final String? userId = AuthService.currentUserId;

    if (userId == null) {
      if (!mounted) return;

      setState(() {
        _activities = <Activity>[];
      });

      return;
    }

    final List<Activity> activities = ActivityService.getActivitiesForUser(
      userId,
    );

    activities.sort((a, b) => b.date.compareTo(a.date));

    if (!mounted) return;

    setState(() {
      _activities = activities;
    });
  }

  Future<void> _refreshDashboard() async {
    _loadActivities();

    await Future<void>.delayed(const Duration(milliseconds: 250));
  }

  List<Activity> get _todayActivities {
    final DateTime now = DateTime.now();

    return _activities.where((activity) {
      return activity.date.year == now.year &&
          activity.date.month == now.month &&
          activity.date.day == now.day;
    }).toList();
  }

  int get _todaySteps {
    return _todayActivities.fold<int>(
      0,
      (total, activity) => total + activity.steps,
    );
  }

  int get _todayCalories {
    return _todayActivities.fold<int>(
      0,
      (total, activity) => total + activity.calories.round(),
    );
  }

  int get _todayDurationSeconds {
    return _todayActivities.fold<int>(
      0,
      (total, activity) => total + activity.effectiveDurationSeconds,
    );
  }

  int get _todayWorkoutCount {
    return _todayActivities.length;
  }

  String _formatDuration(int totalSeconds) {
    if (totalSeconds <= 0) {
      return '0 sec';
    }

    final int hours = totalSeconds ~/ 3600;

    final int minutes = (totalSeconds % 3600) ~/ 60;

    final int seconds = totalSeconds % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }

    if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    }

    return '${seconds}s';
  }

  Future<void> _openWorkoutTracker() async {
    final bool? workoutCompleted = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(builder: (_) => const WorkoutTrackerScreen()),
    );

    if (!mounted) return;

    if (workoutCompleted == true) {
      _loadActivities();
    }
  }

  Future<void> _openAddActivity() async {
    final bool? activityAdded = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(builder: (_) => const AddActivityScreen()),
    );

    if (!mounted) return;

    if (activityAdded == true) {
      _loadActivities();
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppUser? user = AuthService.getCurrentUser();

    final String userName = user?.name.trim().isNotEmpty == true
        ? user!.name.trim()
        : 'User';

    final String firstName = userName.split(' ').first;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,

      drawer: AppDrawer(onLogout: widget.onLogout ?? () {}),

      appBar: AppBar(
        elevation: 0,
        centerTitle: false,
        backgroundColor: Theme.of(context).colorScheme.surface,

        leading: Builder(
          builder: (context) {
            return IconButton(
              tooltip: 'Menu',
              icon: const Icon(Icons.menu_rounded, size: 29),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),

        title: const Text(
          'FitTrack',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
        ),

        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _refreshDashboard,
            icon: const Icon(Icons.refresh_rounded, size: 26),
          ),
          const SizedBox(width: 6),
        ],
      ),

      body: RefreshIndicator(
        onRefresh: _refreshDashboard,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),

          padding: const EdgeInsets.fromLTRB(20, 14, 20, 35),

          children: [
            _buildWelcomeCard(context, firstName),

            const SizedBox(height: 20),

            _buildRealTimeWorkoutCard(context),

            const SizedBox(height: 22),

            _buildTodayOverview(context),

            const SizedBox(height: 22),

            _buildLogActivityCard(context),

            const SizedBox(height: 18),

            _buildMotivationCard(context),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeCard(BuildContext context, String firstName) {
    final Color primaryColor = Theme.of(context).colorScheme.primary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryColor, primaryColor.withValues(alpha: 0.78)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.18),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.17),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.waving_hand_rounded,
              color: Colors.white,
              size: 31,
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Welcome back! 👋',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  firstName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 27,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 5),

                const Text(
                  'Ready to move today?',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.white, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRealTimeWorkoutCard(BuildContext context) {
    final Color primaryColor = Theme.of(context).colorScheme.primary;

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: _openWorkoutTracker,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.11),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.play_arrow_rounded,
                  color: primaryColor,
                  size: 36,
                ),
              ),

              const SizedBox(width: 16),

              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Start Real-Time Workout',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    SizedBox(height: 6),

                    Text(
                      'Track your movement, steps, distance and calories live.',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12, height: 1.45),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              Icon(Icons.chevron_right_rounded, color: primaryColor, size: 29),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTodayOverview(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Today\'s Overview',
          style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800),
        ),

        const SizedBox(height: 5),

        Text(
          'Your key fitness numbers for today',
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),

        const SizedBox(height: 14),

        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,

          children: [
            _buildOverviewCard(
              context,
              icon: Icons.directions_walk_rounded,
              title: 'Steps',
              value: '$_todaySteps',
              unit: 'steps',
            ),

            _buildOverviewCard(
              context,
              icon: Icons.local_fire_department_rounded,
              title: 'Calories',
              value: '$_todayCalories',
              unit: 'kcal',
            ),

            _buildOverviewCard(
              context,
              icon: Icons.timer_rounded,
              title: 'Duration',
              value: _formatDuration(_todayDurationSeconds),
              unit: 'today',
            ),

            _buildOverviewCard(
              context,
              icon: Icons.fitness_center_rounded,
              title: 'Workouts',
              value: '$_todayWorkoutCount',
              unit: 'today',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOverviewCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required String unit,
  }) {
    final Color primaryColor = Theme.of(context).colorScheme.primary;

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: primaryColor, size: 22),
            ),

            const SizedBox(height: 10),

            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),

            const SizedBox(height: 3),

            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      value,
                      maxLines: 1,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 5),

                Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Text(
                    unit,
                    style: TextStyle(
                      fontSize: 10,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogActivityCard(BuildContext context) {
    final Color primaryColor = Theme.of(context).colorScheme.primary;

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: _openAddActivity,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(Icons.add_rounded, color: primaryColor, size: 28),
              ),

              const SizedBox(width: 14),

              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Log Activity',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    SizedBox(height: 4),

                    Text(
                      'Manually record your workout',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),

              Icon(Icons.chevron_right_rounded, color: primaryColor, size: 27),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMotivationCard(BuildContext context) {
    final Color primaryColor = Theme.of(context).colorScheme.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: primaryColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: primaryColor.withValues(alpha: 0.10)),
      ),
      child: Row(
        children: [
          Icon(Icons.favorite_rounded, color: primaryColor, size: 22),

          const SizedBox(width: 10),

          const Expanded(
            child: Text(
              'Small steps every day lead to big results.',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
