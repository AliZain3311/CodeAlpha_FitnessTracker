import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/activity_model.dart';
import '../models/fitness_goals_model.dart';
import '../models/user_model.dart';
import '../services/activity_service.dart';
import '../services/auth_service.dart';
import '../services/fitness_goals_service.dart';
import 'activity_details_screen.dart';
import 'add_activity_screen.dart';
import 'fitness_goals_screen.dart';
import 'weekly_dashboard_screen.dart';

class DashboardScreen extends StatefulWidget {
  final VoidCallback? onLogout;

  const DashboardScreen({super.key, this.onLogout});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Activity> _activities = <Activity>[];

  FitnessGoals? _fitnessGoals;

  bool _isLoadingGoals = true;

  @override
  void initState() {
    super.initState();
    _loadActivities();
    _loadGoals();
  }

  void _loadActivities() {
    final String? userId = AuthService.currentUserId;

    if (userId == null) {
      setState(() {
        _activities = <Activity>[];
      });
      return;
    }

    final List<Activity> userActivities = ActivityService.getActivitiesForUser(
      userId,
    );

    userActivities.sort((a, b) => b.date.compareTo(a.date));

    setState(() {
      _activities = userActivities;
    });
  }

  Future<void> _loadGoals() async {
    final String? userId = AuthService.currentUserId;

    if (userId == null) {
      if (!mounted) {
        return;
      }

      setState(() {
        _fitnessGoals = null;
        _isLoadingGoals = false;
      });

      return;
    }

    final FitnessGoals goals = await FitnessGoalsService.getGoalsForUser(
      userId,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _fitnessGoals = goals;
      _isLoadingGoals = false;
    });
  }

  Future<void> _refreshDashboard() async {
    _loadActivities();
    await _loadGoals();
  }

  List<Activity> get _todayActivities {
    final DateTime now = DateTime.now();

    return _activities.where((activity) {
      return activity.date.year == now.year &&
          activity.date.month == now.month &&
          activity.date.day == now.day;
    }).toList();
  }

  int get _todayCalories {
    return _todayActivities.fold(
      0,
      (total, activity) => total + activity.calories.round(),
    );
  }

  int get _todaySteps {
    return _todayActivities.fold(
      0,
      (total, activity) => total + activity.steps,
    );
  }

  int get _todayDuration {
    return _todayActivities.fold(
      0,
      (total, activity) => total + activity.duration,
    );
  }

  int get _totalWorkouts {
    return _activities.length;
  }

  double _calculateProgress(double current, double target) {
    if (target <= 0) {
      return 0;
    }

    return (current / target).clamp(0.0, 1.0).toDouble();
  }

  int _calculatePercentage(double current, double target) {
    if (target <= 0) {
      return 0;
    }

    return ((current / target) * 100).round();
  }

  Future<void> _openAddActivity() async {
    final bool? activityAdded = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(builder: (_) => const AddActivityScreen()),
    );

    if (!mounted) {
      return;
    }

    if (activityAdded == true) {
      _loadActivities();
    }
  }

  Future<void> _openFitnessGoals() async {
    final bool? goalsUpdated = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(builder: (_) => const FitnessGoalsScreen()),
    );

    if (!mounted) {
      return;
    }

    if (goalsUpdated == true) {
      await _loadGoals();
    }
  }

  void _openActivityDetails(Activity activity) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ActivityDetailsScreen(activity: activity),
      ),
    );
  }

  void _openWeeklyDashboard() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const WeeklyDashboardScreen()),
    );
  }

  Future<void> _logout() async {
    await AuthService.logout();

    if (!mounted) {
      return;
    }

    widget.onLogout?.call();
  }

  Future<void> _confirmLogout() async {
    final bool? shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );

    if (shouldLogout == true) {
      await _logout();
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppUser? user = AuthService.getCurrentUser();

    final String userName = user?.name.isNotEmpty == true ? user!.name : 'User';

    final String firstName = userName.split(' ').first;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          'FitTrack',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            tooltip: 'Fitness Goals',
            onPressed: _openFitnessGoals,
            icon: const Icon(Icons.track_changes_rounded),
          ),
          IconButton(
            tooltip: 'Weekly Progress',
            onPressed: _openWeeklyDashboard,
            icon: const Icon(Icons.bar_chart_rounded),
          ),
          IconButton(
            tooltip: 'Refresh',
            onPressed: _refreshDashboard,
            icon: const Icon(Icons.refresh_rounded),
          ),
          IconButton(
            tooltip: 'Logout',
            onPressed: _confirmLogout,
            icon: const Icon(Icons.logout_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshDashboard,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
          children: [
            _buildWelcomeSection(context, firstName),
            const SizedBox(height: 22),
            _buildWeeklyProgressCard(context),
            const SizedBox(height: 18),
            _buildGoalsProgressCard(context),
            const SizedBox(height: 18),
            _buildSummaryGrid(context),
            const SizedBox(height: 28),
            _buildSectionHeader(
              context,
              title: 'Today\'s Activity',
              subtitle: '${_todayActivities.length} activities recorded',
            ),
            const SizedBox(height: 12),
            _buildTodayActivitySection(context),
            const SizedBox(height: 28),
            _buildSectionHeader(
              context,
              title: 'Recent Activities',
              subtitle: 'Your latest fitness records',
            ),
            const SizedBox(height: 12),
            _buildRecentActivities(context),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddActivity,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Log Activity'),
      ),
    );
  }

  Widget _buildWelcomeSection(BuildContext context, String firstName) {
    final Color primaryColor = Theme.of(context).colorScheme.primary;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryColor, primaryColor.withValues(alpha: 0.78)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.waving_hand_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Welcome back! 👋',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  firstName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'Let\'s keep moving today.',
                  style: TextStyle(color: Colors.white, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyProgressCard(BuildContext context) {
    final Color primaryColor = Theme.of(context).colorScheme.primary;

    return Card(
      elevation: 0,
      child: InkWell(
        onTap: _openWeeklyDashboard,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  Icons.bar_chart_rounded,
                  color: primaryColor,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Weekly Progress',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'View your last 7 days of fitness progress',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Icon(
                Icons.chevron_right_rounded,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGoalsProgressCard(BuildContext context) {
    final Color primaryColor = Theme.of(context).colorScheme.primary;

    if (_isLoadingGoals) {
      return Card(
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(Icons.track_changes_rounded, color: primaryColor),
                  const SizedBox(width: 10),
                  const Text(
                    'Today\'s Goals',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const SizedBox(
                height: 28,
                width: 28,
                child: CircularProgressIndicator(strokeWidth: 2.5),
              ),
            ],
          ),
        ),
      );
    }

    final FitnessGoals? goals = _fitnessGoals;

    if (goals == null) {
      return Card(
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Icon(Icons.track_changes_rounded, size: 42, color: primaryColor),
              const SizedBox(height: 10),
              const Text(
                'Set Your Fitness Goals',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              const Text(
                'Create daily targets to track your progress.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 14),
              OutlinedButton.icon(
                onPressed: _openFitnessGoals,
                icon: const Icon(Icons.flag_outlined),
                label: const Text('Set Goals'),
              ),
            ],
          ),
        ),
      );
    }

    final double stepsProgress = _calculateProgress(
      _todaySteps.toDouble(),
      goals.dailySteps.toDouble(),
    );

    final double caloriesProgress = _calculateProgress(
      _todayCalories.toDouble(),
      goals.dailyCalories,
    );

    final double durationProgress = _calculateProgress(
      _todayDuration.toDouble(),
      goals.dailyDuration.toDouble(),
    );

    final int stepsPercentage = _calculatePercentage(
      _todaySteps.toDouble(),
      goals.dailySteps.toDouble(),
    );

    final int caloriesPercentage = _calculatePercentage(
      _todayCalories.toDouble(),
      goals.dailyCalories,
    );

    final int durationPercentage = _calculatePercentage(
      _todayDuration.toDouble(),
      goals.dailyDuration.toDouble(),
    );

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.track_changes_rounded,
                    color: primaryColor,
                    size: 25,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Today\'s Goals',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Track your daily targets',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Edit Goals',
                  onPressed: _openFitnessGoals,
                  icon: const Icon(Icons.edit_outlined),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildGoalProgressItem(
              context,
              icon: Icons.directions_walk_rounded,
              title: 'Steps',
              current: '$_todaySteps',
              target: '${goals.dailySteps}',
              unit: 'steps',
              progress: stepsProgress,
              percentage: stepsPercentage,
            ),
            const SizedBox(height: 20),
            _buildGoalProgressItem(
              context,
              icon: Icons.local_fire_department_rounded,
              title: 'Calories',
              current: '$_todayCalories',
              target: '${goals.dailyCalories.round()}',
              unit: 'kcal',
              progress: caloriesProgress,
              percentage: caloriesPercentage,
            ),
            const SizedBox(height: 20),
            _buildGoalProgressItem(
              context,
              icon: Icons.timer_rounded,
              title: 'Workout Duration',
              current: '$_todayDuration',
              target: '${goals.dailyDuration}',
              unit: 'min',
              progress: durationProgress,
              percentage: durationPercentage,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalProgressItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String current,
    required String target,
    required String unit,
    required double progress,
    required int percentage,
  }) {
    final Color primaryColor = Theme.of(context).colorScheme.primary;

    final bool isCompleted = percentage >= 100;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 21, color: primaryColor),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (isCompleted) const Icon(Icons.check_circle_rounded, size: 19),
            const SizedBox(width: 5),
            Text(
              '$percentage%',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(value: progress, minHeight: 10),
        ),
        const SizedBox(height: 7),
        Row(
          children: [
            Text(
              '$current $unit',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
            const Spacer(),
            Text(
              'Goal: $target $unit',
              style: TextStyle(
                fontSize: 11,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryGrid(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 14,
      crossAxisSpacing: 14,
      childAspectRatio: 1.45,
      children: [
        _buildStatCard(
          context,
          icon: Icons.local_fire_department_rounded,
          title: 'Calories',
          value: '$_todayCalories',
          unit: 'kcal',
        ),
        _buildStatCard(
          context,
          icon: Icons.directions_walk_rounded,
          title: 'Steps',
          value: '$_todaySteps',
          unit: 'steps',
        ),
        _buildStatCard(
          context,
          icon: Icons.timer_rounded,
          title: 'Duration',
          value: '$_todayDuration',
          unit: 'min',
        ),
        _buildStatCard(
          context,
          icon: Icons.fitness_center_rounded,
          title: 'Workouts',
          value: '$_totalWorkouts',
          unit: 'total',
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required String unit,
  }) {
    final Color primaryColor = Theme.of(context).colorScheme.primary;

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, size: 22, color: primaryColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 5),
                Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Text(
                    unit,
                    style: TextStyle(
                      fontSize: 11,
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

  Widget _buildSectionHeader(
    BuildContext context, {
    required String title,
    required String subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            subtitle,
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTodayActivitySection(BuildContext context) {
    if (_todayActivities.isEmpty) {
      return _buildEmptyCard(
        context,
        icon: Icons.directions_run_rounded,
        title: 'No activity today',
        message: 'Start your fitness journey by logging an activity.',
      );
    }

    return Column(
      children: _todayActivities
          .take(3)
          .map((activity) => _buildActivityCard(context, activity))
          .toList(),
    );
  }

  Widget _buildRecentActivities(BuildContext context) {
    if (_activities.isEmpty) {
      return _buildEmptyCard(
        context,
        icon: Icons.history_rounded,
        title: 'No recent activities',
        message: 'Your logged activities will appear here.',
      );
    }

    return Column(
      children: _activities
          .take(5)
          .map((activity) => _buildActivityCard(context, activity))
          .toList(),
    );
  }

  Widget _buildActivityCard(BuildContext context, Activity activity) {
    final Color primaryColor = Theme.of(context).colorScheme.primary;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: () {
          _openActivityDetails(activity);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  _getActivityIcon(activity.type),
                  color: primaryColor,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activity.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${activity.type} • ${activity.duration} min',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${activity.calories.round()} kcal',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('dd MMM').format(activity.date),
                    style: TextStyle(
                      fontSize: 11,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String message,
  }) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          children: [
            Icon(icon, size: 46, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getActivityIcon(String type) {
    switch (type.toLowerCase()) {
      case 'running':
        return Icons.directions_run_rounded;
      case 'walking':
        return Icons.directions_walk_rounded;
      case 'cycling':
        return Icons.directions_bike_rounded;
      case 'swimming':
        return Icons.pool_rounded;
      case 'gym':
      case 'strength':
      case 'weight training':
        return Icons.fitness_center_rounded;
      case 'yoga':
        return Icons.self_improvement_rounded;
      case 'sports':
        return Icons.sports_soccer_rounded;
      default:
        return Icons.sports_rounded;
    }
  }
}
