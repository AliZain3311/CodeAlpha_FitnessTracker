import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/activity_model.dart';
import '../services/activity_service.dart';
import '../services/auth_service.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

enum StatisticsPeriod { today, week, month }

class _StatisticsScreenState extends State<StatisticsScreen> {
  StatisticsPeriod _selectedPeriod = StatisticsPeriod.week;

  List<Activity> _activities = <Activity>[];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    final String? userId = AuthService.currentUserId;

    if (userId == null) {
      if (!mounted) return;

      setState(() {
        _activities = <Activity>[];
        _isLoading = false;
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
      _isLoading = false;
    });
  }

  DateTime _startOfToday() {
    final DateTime now = DateTime.now();

    return DateTime(now.year, now.month, now.day);
  }

  DateTime _startOfWeek() {
    final DateTime today = _startOfToday();

    final int daysFromMonday = today.weekday - DateTime.monday;

    return today.subtract(Duration(days: daysFromMonday));
  }

  DateTime _startOfMonth() {
    final DateTime now = DateTime.now();

    return DateTime(now.year, now.month, 1);
  }

  List<Activity> get _filteredActivities {
    final DateTime startDate;

    switch (_selectedPeriod) {
      case StatisticsPeriod.today:
        startDate = _startOfToday();
        break;

      case StatisticsPeriod.week:
        startDate = _startOfWeek();
        break;

      case StatisticsPeriod.month:
        startDate = _startOfMonth();
        break;
    }

    return _activities.where((activity) {
      return !activity.date.isBefore(startDate);
    }).toList();
  }

  int get _totalSteps {
    return _filteredActivities.fold<int>(
      0,
      (sum, activity) => sum + activity.steps,
    );
  }

  double get _totalCalories {
    return _filteredActivities.fold<double>(
      0,
      (sum, activity) => sum + activity.calories,
    );
  }

  int get _totalDurationSeconds {
    return _filteredActivities.fold<int>(
      0,
      (sum, activity) => sum + activity.effectiveDurationSeconds,
    );
  }

  int get _totalActivities {
    return _filteredActivities.length;
  }

  double get _totalDistance {
    return _filteredActivities.fold<double>(
      0,
      (sum, activity) => sum + _activityDistance(activity),
    );
  }

  double _activityDistance(Activity activity) {
    final dynamic activityMap = activity.toMap();

    final dynamic rawDistance = activityMap['distanceKm'];

    if (rawDistance is num && rawDistance > 0) {
      return rawDistance.toDouble();
    }

    if (activity.steps > 0) {
      return activity.steps * 0.00075;
    }

    return 0;
  }

  String _formatDuration(int totalSeconds) {
    if (totalSeconds <= 0) {
      return '0s';
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

  String _periodLabel() {
    switch (_selectedPeriod) {
      case StatisticsPeriod.today:
        return 'Today';

      case StatisticsPeriod.week:
        return 'This Week';

      case StatisticsPeriod.month:
        return 'This Month';
    }
  }

  String _formatNumber(int number) {
    return NumberFormat('#,###').format(number);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      appBar: AppBar(
        title: const Text(
          'Statistics',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: const Color(0xFF172033),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _loadStatistics,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadStatistics,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderCard(),

          const SizedBox(height: 20),

          _buildPeriodSelector(),

          const SizedBox(height: 20),

          _buildStatsGrid(),

          const SizedBox(height: 24),

          _buildActivityChart(),

          const SizedBox(height: 24),

          _buildActivityBreakdown(),

          const SizedBox(height: 24),

          _buildRecentActivity(),
        ],
      ),
    );
  }

  Widget _buildHeaderCard() {
    final currentUser = AuthService.getCurrentUser();

    final String userName = currentUser?.name.trim().isNotEmpty == true
        ? currentUser!.name.trim()
        : 'there';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2563EB), Color(0xFF4F46E5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: const Color(0xFF2563EB).withOpacity(0.20),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              // ignore: deprecated_member_use
              color: Colors.white.withOpacity(0.17),
              borderRadius: BorderRadius.circular(17),
            ),
            child: const Icon(
              Icons.insights_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),

          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your ${_periodLabel()} Progress',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  'Keep moving, $userName',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    // ignore: deprecated_member_use
                    color: Colors.white.withOpacity(0.88),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          _periodButton('Today', StatisticsPeriod.today),
          _periodButton('Week', StatisticsPeriod.week),
          _periodButton('Month', StatisticsPeriod.month),
        ],
      ),
    );
  }

  Widget _periodButton(String title, StatisticsPeriod period) {
    final bool selected = _selectedPeriod == period;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          setState(() {
            _selectedPeriod = period;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.symmetric(vertical: 13),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF2563EB) : Colors.transparent,
            borderRadius: BorderRadius.circular(13),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: selected ? Colors.white : const Color(0xFF667085),
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 14,
      mainAxisSpacing: 14,

      // More vertical room for
      // smaller Android screens.
      childAspectRatio: 0.95,

      children: [
        _statCard(
          title: 'Steps',
          value: _formatNumber(_totalSteps),
          icon: Icons.directions_walk_rounded,
          iconColor: const Color(0xFF2563EB),
        ),
        _statCard(
          title: 'Calories',
          value: '${_totalCalories.toStringAsFixed(0)} kcal',
          icon: Icons.local_fire_department_rounded,
          iconColor: const Color(0xFFEF4444),
        ),
        _statCard(
          title: 'Duration',
          value: _formatDuration(_totalDurationSeconds),
          icon: Icons.timer_rounded,
          iconColor: const Color(0xFF7C3AED),
        ),
        _statCard(
          title: 'Distance',
          value: '${_totalDistance.toStringAsFixed(2)} km',
          icon: Icons.route_rounded,
          iconColor: const Color(0xFF059669),
        ),
      ],
    );
  }

  Widget _statCard({
    required String title,
    required String value,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE8ECF3)),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.035),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              // ignore: deprecated_member_use
              color: iconColor.withOpacity(0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 21),
          ),

          const SizedBox(height: 10),

          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF667085),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 4),

          Expanded(
            child: Align(
              alignment: Alignment.bottomLeft,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  value,
                  maxLines: 1,
                  style: const TextStyle(
                    color: Color(0xFF172033),
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityChart() {
    final List<FlSpot> spots = _buildWeeklyChartData();

    final double highestValue = spots.isEmpty
        ? 0
        : spots.map((spot) => spot.y).reduce((a, b) => a > b ? a : b);

    final double maxY = highestValue <= 0 ? 10 : highestValue + 10;

    return _sectionCard(
      title: 'Activity Overview',
      icon: Icons.show_chart_rounded,
      child: Column(
        children: [
          const SizedBox(height: 5),

          SizedBox(
            height: 220,
            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: maxY,

                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: _chartInterval(maxY),
                ),

                borderData: FlBorderData(show: false),

                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 36,
                      interval: _chartInterval(maxY),
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: const TextStyle(
                            color: Color(0xFF98A2B3),
                            fontSize: 10,
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        final int index = value.toInt();

                        if (index < 0 || index >= 7) {
                          return const SizedBox();
                        }

                        final DateTime day = _startOfWeek().add(
                          Duration(days: index),
                        );

                        final String label = DateFormat('E').format(day);

                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            label.substring(0, 1),
                            style: const TextStyle(
                              color: Color(0xFF98A2B3),
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    barWidth: 3,
                    color: const Color(0xFF2563EB),
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      // ignore: deprecated_member_use
                      color: const Color(0xFF2563EB).withOpacity(0.10),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  double _chartInterval(double maxY) {
    if (maxY <= 10) {
      return 2;
    }

    if (maxY <= 50) {
      return 10;
    }

    if (maxY <= 100) {
      return 20;
    }

    return (maxY / 5).ceilToDouble();
  }

  List<FlSpot> _buildWeeklyChartData() {
    final DateTime weekStart = _startOfWeek();

    final List<FlSpot> spots = <FlSpot>[];

    for (int index = 0; index < 7; index++) {
      final DateTime day = DateTime(
        weekStart.year,
        weekStart.month,
        weekStart.day + index,
      );

      final DateTime nextDay = day.add(const Duration(days: 1));

      final double minutes = _activities
          .where(
            (activity) =>
                !activity.date.isBefore(day) && activity.date.isBefore(nextDay),
          )
          .fold<double>(
            0,
            (sum, activity) => sum + activity.effectiveDurationSeconds / 60,
          );

      spots.add(FlSpot(index.toDouble(), minutes));
    }

    return spots;
  }

  Widget _buildActivityBreakdown() {
    final Map<String, int> typeCounts = <String, int>{};

    for (final Activity activity in _filteredActivities) {
      typeCounts[activity.type] = (typeCounts[activity.type] ?? 0) + 1;
    }

    final List<MapEntry<String, int>> entries = typeCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return _sectionCard(
      title: 'Activity Breakdown',
      icon: Icons.pie_chart_rounded,
      child: entries.isEmpty
          ? _emptyState(
              icon: Icons.fitness_center_rounded,
              message: 'No activities recorded for this period.',
            )
          : Column(
              children: entries
                  .map(
                    (entry) =>
                        _breakdownRow(entry.key, entry.value, _totalActivities),
                  )
                  .toList(),
            ),
    );
  }

  Widget _breakdownRow(String type, int count, int total) {
    final double progress = total <= 0 ? 0 : count / total;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  type,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF344054),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$count ${count == 1 ? 'activity' : 'activities'}',
                style: const TextStyle(
                  color: Color(0xFF667085),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: const Color(0xFFE9EEF6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity() {
    final List<Activity> recent = <Activity>[..._filteredActivities]
      ..sort((a, b) => b.date.compareTo(a.date));

    final List<Activity> visible = recent.take(5).toList();

    return _sectionCard(
      title: 'Recent Activities',
      icon: Icons.history_rounded,
      child: visible.isEmpty
          ? _emptyState(
              icon: Icons.directions_run_rounded,
              message: 'No activity found for this period.',
            )
          : Column(
              children: visible
                  .map((activity) => _activityRow(activity))
                  .toList(),
            ),
    );
  }

  Widget _activityRow(Activity activity) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFEFF4FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.fitness_center_rounded,
              color: Color(0xFF2563EB),
              size: 21,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF172033),
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  '${activity.type} • ${DateFormat('dd MMM, hh:mm a').format(activity.date)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF667085),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${activity.calories.toStringAsFixed(0)} kcal',
                style: const TextStyle(
                  color: Color(0xFFEF4444),
                  fontWeight: FontWeight.w700,
                  fontSize: 10,
                ),
              ),

              const SizedBox(height: 3),

              Text(
                _formatDuration(activity.effectiveDurationSeconds),
                style: const TextStyle(color: Color(0xFF667085), fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE8ECF3)),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.035),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF4FF),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(icon, color: const Color(0xFF2563EB), size: 20),
              ),

              const SizedBox(width: 11),

              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF172033),
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          child,
        ],
      ),
    );
  }

  Widget _emptyState({required IconData icon, required String message}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 15),
      child: Column(
        children: [
          Icon(icon, size: 42, color: const Color(0xFFB8C0CC)),

          const SizedBox(height: 10),

          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF667085),
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
