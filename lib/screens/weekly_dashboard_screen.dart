import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/weekly_stats_model.dart';
import '../services/auth_service.dart';
import '../services/weekly_stats_service.dart';

class WeeklyDashboardScreen extends StatefulWidget {
  const WeeklyDashboardScreen({super.key});

  @override
  State<WeeklyDashboardScreen> createState() => _WeeklyDashboardScreenState();
}

class _WeeklyDashboardScreenState extends State<WeeklyDashboardScreen> {
  List<WeeklyStats> _weeklyStats = <WeeklyStats>[];

  @override
  void initState() {
    super.initState();
    _loadWeeklyStats();
  }

  void _loadWeeklyStats() {
    final String? userId = AuthService.currentUserId;

    if (userId == null) {
      setState(() {
        _weeklyStats = <WeeklyStats>[];
      });
      return;
    }

    final List<WeeklyStats> stats = WeeklyStatsService.getLast7DaysStats(
      userId,
    );

    setState(() {
      _weeklyStats = stats;
    });
  }

  int get _totalActivities {
    return _weeklyStats.fold(0, (total, day) => total + day.activityCount);
  }

  int get _totalDuration {
    return _weeklyStats.fold(0, (total, day) => total + day.duration);
  }

  int get _totalSteps {
    return _weeklyStats.fold(0, (total, day) => total + day.steps);
  }

  int get _totalCalories {
    return _weeklyStats.fold(0, (total, day) => total + day.calories.round());
  }

  double get _averageCalories {
    if (_weeklyStats.isEmpty) {
      return 0;
    }

    return WeeklyStatsService.getAverageDailyCalories(
      AuthService.currentUserId ?? '',
    );
  }

  double get _averageSteps {
    if (_weeklyStats.isEmpty) {
      return 0;
    }

    return WeeklyStatsService.getAverageDailySteps(
      AuthService.currentUserId ?? '',
    );
  }

  double get _averageDuration {
    if (_weeklyStats.isEmpty) {
      return 0;
    }

    return WeeklyStatsService.getAverageDailyDuration(
      AuthService.currentUserId ?? '',
    );
  }

  WeeklyStats? get _mostActiveDay {
    final String? userId = AuthService.currentUserId;

    if (userId == null) {
      return null;
    }

    return WeeklyStatsService.getMostActiveDay(userId);
  }

  WeeklyStats? get _highestCaloriesDay {
    final String? userId = AuthService.currentUserId;

    if (userId == null) {
      return null;
    }

    return WeeklyStatsService.getHighestCaloriesDay(userId);
  }

  WeeklyStats? get _highestStepsDay {
    final String? userId = AuthService.currentUserId;

    if (userId == null) {
      return null;
    }

    return WeeklyStatsService.getHighestStepsDay(userId);
  }

  bool get _hasActivityData {
    return _totalActivities > 0;
  }

  double get _maxCalories {
    if (_weeklyStats.isEmpty) {
      return 100;
    }

    final double maxValue = _weeklyStats.fold(
      0.0,
      (max, day) => day.calories > max ? day.calories : max,
    );

    if (maxValue <= 0) {
      return 100;
    }

    return _roundedChartMax(maxValue);
  }

  double get _maxSteps {
    if (_weeklyStats.isEmpty) {
      return 1000;
    }

    final int maxValue = _weeklyStats.fold(
      0,
      (max, day) => day.steps > max ? day.steps : max,
    );

    if (maxValue <= 0) {
      return 1000;
    }

    return _roundedChartMax(maxValue.toDouble());
  }

  double get _maxDuration {
    if (_weeklyStats.isEmpty) {
      return 60;
    }

    final int maxValue = _weeklyStats.fold(
      0,
      (max, day) => day.duration > max ? day.duration : max,
    );

    if (maxValue <= 0) {
      return 60;
    }

    return _roundedChartMax(maxValue.toDouble());
  }

  double _roundedChartMax(double value) {
    if (value <= 10) {
      return 20;
    }

    if (value <= 50) {
      return 100;
    }

    if (value <= 100) {
      return 200;
    }

    if (value <= 500) {
      return 1000;
    }

    if (value <= 1000) {
      return 2000;
    }

    if (value <= 5000) {
      return 10000;
    }

    return value * 1.2;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Weekly Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _loadWeeklyStats,
            icon: const Icon(Icons.refresh_rounded),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _loadWeeklyStats();
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          children: [
            _buildHeader(context),
            const SizedBox(height: 20),
            _buildSummaryGrid(context),
            const SizedBox(height: 28),
            _buildInsightsSection(context),
            const SizedBox(height: 28),
            _buildChartCard(
              context,
              title: 'Calories Burned',
              subtitle: 'Daily calories for the last 7 days',
              icon: Icons.local_fire_department_rounded,
              chart: _buildCaloriesChart(context),
            ),
            const SizedBox(height: 18),
            _buildChartCard(
              context,
              title: 'Steps',
              subtitle: 'Daily steps for the last 7 days',
              icon: Icons.directions_walk_rounded,
              chart: _buildStepsChart(context),
            ),
            const SizedBox(height: 18),
            _buildChartCard(
              context,
              title: 'Workout Duration',
              subtitle: 'Daily workout minutes for the last 7 days',
              icon: Icons.timer_rounded,
              chart: _buildDurationChart(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final Color primaryColor = Theme.of(context).colorScheme.primary;

    final String dateRange = _weeklyStats.isEmpty
        ? 'Last 7 days'
        : '${DateFormat('dd MMM').format(_weeklyStats.first.date)}'
              ' - '
              '${DateFormat('dd MMM yyyy').format(_weeklyStats.last.date)}';

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
              Icons.bar_chart_rounded,
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
                  'Weekly Progress',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  dateRange,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
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
        _buildSummaryCard(
          context,
          icon: Icons.fitness_center_rounded,
          title: 'Activities',
          value: '$_totalActivities',
          unit: 'workouts',
        ),
        _buildSummaryCard(
          context,
          icon: Icons.local_fire_department_rounded,
          title: 'Calories',
          value: '$_totalCalories',
          unit: 'kcal',
        ),
        _buildSummaryCard(
          context,
          icon: Icons.directions_walk_rounded,
          title: 'Steps',
          value: '$_totalSteps',
          unit: 'steps',
        ),
        _buildSummaryCard(
          context,
          icon: Icons.timer_rounded,
          title: 'Duration',
          value: '$_totalDuration',
          unit: 'min',
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
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
                Flexible(
                  child: Text(
                    value,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 5),
                Padding(
                  padding: const EdgeInsets.only(bottom: 3),
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

  Widget _buildInsightsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Performance Insights',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5),
        Text(
          'A quick look at your weekly performance',
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 14),
        if (!_hasActivityData)
          _buildNoInsightsCard(context)
        else
          Column(
            children: [
              _buildInsightCard(
                context,
                icon: Icons.emoji_events_rounded,
                title: 'Most Active Day',
                value: _mostActiveDay == null
                    ? 'No activity'
                    : DateFormat('EEEE').format(_mostActiveDay!.date),
                subtitle: _mostActiveDay == null
                    ? 'No workouts recorded'
                    : '${_mostActiveDay!.activityCount} '
                          'workout${_mostActiveDay!.activityCount == 1 ? '' : 's'}',
              ),
              const SizedBox(height: 10),
              _buildInsightCard(
                context,
                icon: Icons.local_fire_department_rounded,
                title: 'Average Calories',
                value: '${_averageCalories.round()} kcal',
                subtitle: 'per day',
              ),
              const SizedBox(height: 10),
              _buildInsightCard(
                context,
                icon: Icons.directions_walk_rounded,
                title: 'Average Steps',
                value: _formatNumber(_averageSteps.round()),
                subtitle: 'steps per day',
              ),
              const SizedBox(height: 10),
              _buildInsightCard(
                context,
                icon: Icons.timer_rounded,
                title: 'Average Duration',
                value: '${_averageDuration.round()} min',
                subtitle: 'per day',
              ),
              const SizedBox(height: 10),
              _buildInsightCard(
                context,
                icon: Icons.local_fire_department_outlined,
                title: 'Best Calorie Day',
                value: _highestCaloriesDay == null
                    ? 'No data'
                    : DateFormat('EEE').format(_highestCaloriesDay!.date),
                subtitle: _highestCaloriesDay == null
                    ? 'No calories recorded'
                    : '${_highestCaloriesDay!.calories.round()} kcal burned',
              ),
              const SizedBox(height: 10),
              _buildInsightCard(
                context,
                icon: Icons.directions_walk_outlined,
                title: 'Best Steps Day',
                value: _highestStepsDay == null
                    ? 'No data'
                    : DateFormat('EEE').format(_highestStepsDay!.date),
                subtitle: _highestStepsDay == null
                    ? 'No steps recorded'
                    : '${_formatNumber(_highestStepsDay!.steps)} steps',
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildInsightCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
  }) {
    final Color primaryColor = Theme.of(context).colorScheme.primary;

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: primaryColor),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoInsightsCard(BuildContext context) {
    final Color primaryColor = Theme.of(context).colorScheme.primary;

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          children: [
            Icon(Icons.insights_rounded, size: 48, color: primaryColor),
            const SizedBox(height: 12),
            const Text(
              'No activity data yet',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              'Start logging activities to see your weekly insights.',
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

  Widget _buildChartCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Widget chart,
  }) {
    final Color primaryColor = Theme.of(context).colorScheme.primary;

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: primaryColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 11,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(height: 230, child: chart),
          ],
        ),
      ),
    );
  }

  Widget _buildCaloriesChart(BuildContext context) {
    final Color primaryColor = Theme.of(context).colorScheme.primary;

    return LineChart(
      LineChartData(
        minY: 0,
        maxY: _maxCalories,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: _chartInterval(_maxCalories),
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
              reservedSize: 42,
              interval: _chartInterval(_maxCalories),
              getTitlesWidget: (value, meta) {
                return Text(
                  _formatAxisValue(value),
                  style: TextStyle(
                    fontSize: 9,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
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
                return _buildDayTitle(context, value);
              },
            ),
          ),
        ),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (touchedSpots) {
              return touchedSpots
                  .map((spot) {
                    final int index = spot.x.round();

                    if (index < 0 || index >= _weeklyStats.length) {
                      return null;
                    }

                    final WeeklyStats day = _weeklyStats[index];

                    return LineTooltipItem(
                      '${DateFormat('EEE').format(day.date)}\n'
                      '${day.calories.round()} kcal',
                      const TextStyle(fontWeight: FontWeight.bold),
                    );
                  })
                  .whereType<LineTooltipItem>()
                  .toList();
            },
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: _weeklyStats
                .asMap()
                .entries
                .map(
                  (entry) => FlSpot(entry.key.toDouble(), entry.value.calories),
                )
                .toList(),
            isCurved: true,
            barWidth: 3,
            color: primaryColor,
            dotData: FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: primaryColor.withValues(alpha: 0.10),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepsChart(BuildContext context) {
    final Color primaryColor = Theme.of(context).colorScheme.primary;

    return BarChart(
      BarChartData(
        minY: 0,
        maxY: _maxSteps,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: _chartInterval(_maxSteps),
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
              reservedSize: 42,
              interval: _chartInterval(_maxSteps),
              getTitlesWidget: (value, meta) {
                return Text(
                  _formatAxisValue(value),
                  style: TextStyle(
                    fontSize: 9,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                return _buildDayTitle(context, value);
              },
            ),
          ),
        ),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              if (groupIndex < 0 || groupIndex >= _weeklyStats.length) {
                return null;
              }

              final WeeklyStats day = _weeklyStats[groupIndex];

              return BarTooltipItem(
                '${DateFormat('EEE').format(day.date)}\n'
                '${day.steps} steps',
                const TextStyle(fontWeight: FontWeight.bold),
              );
            },
          ),
        ),
        barGroups: _weeklyStats.asMap().entries.map((entry) {
          return BarChartGroupData(
            x: entry.key,
            barRods: [
              BarChartRodData(
                toY: entry.value.steps.toDouble(),
                width: 18,
                color: primaryColor,
                borderRadius: BorderRadius.circular(5),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDurationChart(BuildContext context) {
    final Color primaryColor = Theme.of(context).colorScheme.primary;

    return LineChart(
      LineChartData(
        minY: 0,
        maxY: _maxDuration,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: _chartInterval(_maxDuration),
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
              reservedSize: 42,
              interval: _chartInterval(_maxDuration),
              getTitlesWidget: (value, meta) {
                return Text(
                  _formatAxisValue(value),
                  style: TextStyle(
                    fontSize: 9,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
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
                return _buildDayTitle(context, value);
              },
            ),
          ),
        ),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (touchedSpots) {
              return touchedSpots
                  .map((spot) {
                    final int index = spot.x.round();

                    if (index < 0 || index >= _weeklyStats.length) {
                      return null;
                    }

                    final WeeklyStats day = _weeklyStats[index];

                    return LineTooltipItem(
                      '${DateFormat('EEE').format(day.date)}\n'
                      '${day.duration} min',
                      const TextStyle(fontWeight: FontWeight.bold),
                    );
                  })
                  .whereType<LineTooltipItem>()
                  .toList();
            },
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: _weeklyStats
                .asMap()
                .entries
                .map(
                  (entry) => FlSpot(
                    entry.key.toDouble(),
                    entry.value.duration.toDouble(),
                  ),
                )
                .toList(),
            isCurved: true,
            barWidth: 3,
            color: primaryColor,
            dotData: FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: primaryColor.withValues(alpha: 0.10),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayTitle(BuildContext context, double value) {
    final int index = value.round();

    if (index < 0 || index >= _weeklyStats.length) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(
        DateFormat('EEE').format(_weeklyStats[index].date),
        style: TextStyle(
          fontSize: 9,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  double _chartInterval(double maxY) {
    if (maxY <= 100) {
      return 20;
    }

    if (maxY <= 500) {
      return 100;
    }

    if (maxY <= 1000) {
      return 200;
    }

    if (maxY <= 5000) {
      return 1000;
    }

    return maxY / 5;
  }

  String _formatAxisValue(double value) {
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}k';
    }

    return value.round().toString();
  }

  String _formatNumber(int value) {
    return NumberFormat('#,###').format(value);
  }
}
