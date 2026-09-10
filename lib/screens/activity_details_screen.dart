import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/activity_model.dart';
import '../services/activity_service.dart';
import '../services/auth_service.dart';
import 'edit_activity_screen.dart';

class ActivityDetailsScreen extends StatefulWidget {
  final Activity activity;

  const ActivityDetailsScreen({super.key, required this.activity});

  @override
  State<ActivityDetailsScreen> createState() => _ActivityDetailsScreenState();
}

class _ActivityDetailsScreenState extends State<ActivityDetailsScreen> {
  late Activity _activity;

  @override
  void initState() {
    super.initState();

    _activity = widget.activity;
  }

  Future<void> _openEditActivity() async {
    final Activity? updatedActivity = await Navigator.of(context)
        .push<Activity?>(
          MaterialPageRoute<Activity?>(
            builder: (_) => EditActivityScreen(activity: _activity),
          ),
        );

    if (!mounted) {
      return;
    }

    if (updatedActivity != null) {
      setState(() {
        _activity = updatedActivity;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Activity details updated.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _deleteActivity() async {
    final String? currentUserId = AuthService.currentUserId;

    if (currentUserId == null) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please login before deleting an activity.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Extra ownership check at screen level.
    if (_activity.userId != currentUserId) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You can only delete your own activity.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Activity?'),
          content: const Text(
            'This activity will be permanently '
            'removed from your fitness records.',
          ),
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
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) {
      return;
    }

    final bool deleted = await ActivityService.deleteActivity(
      activityId: _activity.id,
      userId: currentUserId,
    );

    if (!mounted) {
      return;
    }

    if (!deleted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Activity could not be deleted.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Activity deleted successfully.'),
        behavior: SnackBarBehavior.floating,
      ),
    );

    // Return true to Dashboard so it can
    // reload the activity list.
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Activity Details',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Edit Activity',
            onPressed: _openEditActivity,
            icon: const Icon(Icons.edit_rounded),
          ),
          IconButton(
            tooltip: 'Delete Activity',
            onPressed: _deleteActivity,
            icon: const Icon(Icons.delete_outline_rounded),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          primaryColor,
                          primaryColor.withValues(alpha: 0.78),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 78,
                          height: 78,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _getActivityIcon(_activity.type),
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _activity.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _activity.type,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  _buildMetricCard(
                    context,
                    icon: Icons.timer_outlined,
                    title: 'Duration',
                    value: _formatDuration(_activity.effectiveDurationSeconds),
                  ),

                  _buildMetricCard(
                    context,
                    icon: Icons.local_fire_department_outlined,
                    title: 'Calories Burned',
                    value: '${_activity.calories.round()} kcal',
                  ),

                  _buildMetricCard(
                    context,
                    icon: Icons.directions_walk_outlined,
                    title: 'Steps',
                    value: '${_activity.steps}',
                  ),

                  _buildMetricCard(
                    context,
                    icon: Icons.calendar_today_outlined,
                    title: 'Activity Date',
                    value: DateFormat('dd MMMM yyyy').format(_activity.date),
                  ),

                  if (_activity.notes.trim().isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Card(
                      elevation: 0,
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.notes_outlined, color: primaryColor),
                                const SizedBox(width: 10),
                                const Text(
                                  'Notes',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _activity.notes,
                              style: const TextStyle(fontSize: 14, height: 1.5),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 20),

                  SizedBox(
                    height: 52,
                    child: OutlinedButton.icon(
                      onPressed: _openEditActivity,
                      icon: const Icon(Icons.edit_rounded),
                      label: const Text(
                        'Edit Activity',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  SizedBox(
                    height: 52,
                    child: OutlinedButton.icon(
                      onPressed: _deleteActivity,
                      icon: const Icon(Icons.delete_outline_rounded),
                      label: const Text(
                        'Delete Activity',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.error,
                        side: BorderSide(
                          color: Theme.of(
                            context,
                          ).colorScheme.error.withValues(alpha: 0.5),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatDuration(int totalSeconds) {
    if (totalSeconds <= 0) {
      return '0 sec';
    }

    final int hours = totalSeconds ~/ 3600;
    final int minutes = (totalSeconds % 3600) ~/ 60;
    final int seconds = totalSeconds % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    }

    if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    }

    return '${seconds}s';
  }

  Widget _buildMetricCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
  }) {
    final Color primaryColor = Theme.of(context).colorScheme.primary;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
        leading: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: primaryColor.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(icon, color: primaryColor),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 3),
          child: Text(
            value,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
          ),
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
