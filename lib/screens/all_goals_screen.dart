import 'package:flutter/material.dart';

import '../models/activity_model.dart';
import '../models/fitness_goals_model.dart';
import '../services/activity_service.dart';
import '../services/auth_service.dart';
import '../services/fitness_goals_service.dart';

class AllGoalsScreen extends StatefulWidget {
  const AllGoalsScreen({super.key});

  @override
  State<AllGoalsScreen> createState() => _AllGoalsScreenState();
}

class _AllGoalsScreenState extends State<AllGoalsScreen> {
  List<FitnessGoals> _pendingGoals = [];
  List<FitnessGoals> _completedGoals = [];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGoals();
  }

  Future<void> _loadGoals() async {
    final String? userId = AuthService.currentUserId;

    if (userId == null) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      return;
    }

    final FitnessGoals? savedGoals = await FitnessGoalsService.getGoalsForUser(
      userId,
    );

    final List<Activity> activities = ActivityService.getActivitiesForUser(
      userId,
    );

    if (savedGoals == null) {
      if (mounted) {
        setState(() {
          _pendingGoals = [];
          _completedGoals = [];
          _isLoading = false;
        });
      }
      return;
    }

    final bool isCompleted = activities.any(
      (activity) => activity.notes.contains('Goal Workout Completed: true'),
    );

    if (!mounted) return;

    setState(() {
      if (isCompleted) {
        _completedGoals = [savedGoals];
        _pendingGoals = [];
      } else {
        _pendingGoals = [savedGoals];
        _completedGoals = [];
      }

      _isLoading = false;
    });
  }

  Future<void> _refreshGoals() async {
    setState(() {
      _isLoading = true;
    });

    await _loadGoals();
  }

  Widget _buildGoalCard(FitnessGoals goals, {required bool completed}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: completed
                      ? Colors.green.withValues(alpha: 0.12)
                      : Colors.blue.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  completed ? Icons.check_circle_rounded : Icons.flag_rounded,
                  color: completed ? Colors.green : Colors.blue,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  completed ? 'Completed Goal' : 'Active Goal',
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF172033),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: completed
                      ? Colors.green.withValues(alpha: 0.10)
                      : Colors.blue.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  completed ? 'Complete' : 'Pending',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: completed ? Colors.green : Colors.blue,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 22),

          if (goals.dailySteps > 0)
            _buildGoalRow(
              icon: Icons.directions_walk_rounded,
              title: 'Daily Steps',
              value: '${goals.dailySteps} steps',
            ),

          if (goals.dailyCalories > 0)
            _buildGoalRow(
              icon: Icons.local_fire_department_rounded,
              title: 'Daily Calories',
              value: '${goals.dailyCalories.toStringAsFixed(0)} kcal',
            ),

          if (goals.dailyDuration > 0)
            _buildGoalRow(
              icon: Icons.timer_rounded,
              title: 'Daily Duration',
              value: '${goals.dailyDuration} minutes',
            ),

          if (goals.dailyDistanceKm > 0)
            _buildGoalRow(
              icon: Icons.route_rounded,
              title: 'Daily Distance',
              value: '${goals.dailyDistanceKm.toStringAsFixed(1)} km',
            ),
        ],
      ),
    );
  }

  Widget _buildGoalRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Icon(icon, size: 21, color: const Color(0xFF526DFF)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF667085),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF172033),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required int count,
    required IconData icon,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, right: 4, bottom: 14),
      child: Row(
        children: [
          Icon(icon, color: color, size: 23),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color(0xFF172033),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState({
    required String title,
    required String message,
    required IconData icon,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE7EAF0)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 48, color: const Color(0xFF98A2B3)),
          const SizedBox(height: 14),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Color(0xFF344054),
            ),
          ),
          const SizedBox(height: 7),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              height: 1.5,
              color: Color(0xFF667085),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final int totalGoals = _pendingGoals.length + _completedGoals.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        title: const Text(
          'All Goals',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        centerTitle: false,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF172033),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _refreshGoals,
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _refreshGoals,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF526DFF), Color(0xFF7B61FF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(26),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(17),
                          ),
                          child: const Icon(
                            Icons.track_changes_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Your Fitness Goals',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 19,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                '$totalGoals goal${totalGoals == 1 ? '' : 's'} in total',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.85),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  _buildSectionHeader(
                    title: 'Pending',
                    count: _pendingGoals.length,
                    icon: Icons.flag_rounded,
                    color: Colors.blue,
                  ),

                  if (_pendingGoals.isEmpty)
                    _buildEmptyState(
                      title: 'No Pending Goals',
                      message: 'You currently have no active fitness goal.',
                      icon: Icons.flag_outlined,
                    )
                  else
                    ..._pendingGoals.map(
                      (goal) => _buildGoalCard(goal, completed: false),
                    ),

                  const SizedBox(height: 8),

                  _buildSectionHeader(
                    title: 'Complete',
                    count: _completedGoals.length,
                    icon: Icons.check_circle_rounded,
                    color: Colors.green,
                  ),

                  if (_completedGoals.isEmpty)
                    _buildEmptyState(
                      title: 'No Completed Goals',
                      message: 'Goals you complete will appear here.',
                      icon: Icons.emoji_events_outlined,
                    )
                  else
                    ..._completedGoals.map(
                      (goal) => _buildGoalCard(goal, completed: true),
                    ),
                ],
              ),
            ),
    );
  }
}
