import 'package:flutter/material.dart';

import '../models/fitness_goals_model.dart';
import '../services/auth_service.dart';
import '../services/fitness_goals_service.dart';

class FitnessGoalsScreen extends StatefulWidget {
  const FitnessGoalsScreen({super.key});

  @override
  State<FitnessGoalsScreen> createState() => _FitnessGoalsScreenState();
}

class _FitnessGoalsScreenState extends State<FitnessGoalsScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _stepsController = TextEditingController();

  final TextEditingController _caloriesController = TextEditingController();

  final TextEditingController _durationController = TextEditingController();

  final TextEditingController _distanceController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    _loadGoals();
  }

  @override
  void dispose() {
    _stepsController.dispose();
    _caloriesController.dispose();
    _durationController.dispose();
    _distanceController.dispose();

    super.dispose();
  }

  Future<void> _loadGoals() async {
    final String? userId = AuthService.currentUserId;

    if (userId == null) {
      _setDefaultFields();

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }

      return;
    }

    final FitnessGoals? goals = await FitnessGoalsService.getGoalsForUser(
      userId,
    );

    if (!mounted) {
      return;
    }

    if (goals == null) {
      _setDefaultFields();
    } else {
      _stepsController.text = goals.dailySteps.toString();

      _caloriesController.text = goals.dailyCalories.toStringAsFixed(0);

      _durationController.text = goals.dailyDuration.toString();

      _distanceController.text = goals.dailyDistanceKm.toStringAsFixed(
        goals.dailyDistanceKm % 1 == 0 ? 0 : 1,
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _setDefaultFields() {
    _stepsController.text = '0';
    _caloriesController.text = '0';
    _durationController.text = '0';
    _distanceController.text = '0';
  }

  String? _validateSteps(String? value) {
    final String text = value?.trim() ?? '';

    if (text.isEmpty) {
      return 'Please enter your steps goal.';
    }

    final int? steps = int.tryParse(text);

    if (steps == null) {
      return 'Please enter a valid number.';
    }

    if (steps < 0) {
      return 'Steps goal cannot be negative.';
    }

    if (steps > 100000) {
      return 'Steps goal cannot exceed 100,000.';
    }

    return null;
  }

  String? _validateCalories(String? value) {
    final String text = value?.trim() ?? '';

    if (text.isEmpty) {
      return 'Please enter your calories goal.';
    }

    final double? calories = double.tryParse(text);

    if (calories == null) {
      return 'Please enter a valid number.';
    }

    if (calories < 0) {
      return 'Calories goal cannot be negative.';
    }

    if (calories > 10000) {
      return 'Calories goal cannot exceed 10,000.';
    }

    return null;
  }

  String? _validateDuration(String? value) {
    final String text = value?.trim() ?? '';

    if (text.isEmpty) {
      return 'Please enter your duration goal.';
    }

    final int? duration = int.tryParse(text);

    if (duration == null) {
      return 'Please enter a valid number.';
    }

    if (duration < 0) {
      return 'Duration goal cannot be negative.';
    }

    if (duration > 1440) {
      return 'Duration goal cannot exceed 1,440 minutes.';
    }

    return null;
  }

  String? _validateDistance(String? value) {
    final String text = value?.trim() ?? '';

    if (text.isEmpty) {
      return 'Please enter your distance goal.';
    }

    final double? distance = double.tryParse(text);

    if (distance == null) {
      return 'Please enter a valid number.';
    }

    if (distance < 0) {
      return 'Distance goal cannot be negative.';
    }

    if (distance > 100) {
      return 'Distance goal cannot exceed 100 km.';
    }

    return null;
  }

  Future<void> _saveGoals() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final String? userId = AuthService.currentUserId;

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please login before updating your goals.'),
          behavior: SnackBarBehavior.floating,
        ),
      );

      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final FitnessGoals updatedGoals = FitnessGoals(
        userId: userId,
        dailySteps: int.parse(_stepsController.text.trim()),
        dailyCalories: double.parse(_caloriesController.text.trim()),
        dailyDuration: int.parse(_durationController.text.trim()),
        dailyDistanceKm: double.parse(_distanceController.text.trim()),
      );

      await FitnessGoalsService.saveGoals(updatedGoals);

      if (!mounted) {
        return;
      }

      setState(() {
        _isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Fitness goals saved successfully!'),
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to save goals: $error'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _resetToDefaults() {
    setState(() {
      _stepsController.text = '0';
      _caloriesController.text = '0';
      _durationController.text = '0';
      _distanceController.text = '0';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Default goals restored to 0. Tap Save Goals to apply them.',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Fitness Goals',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(22),
                            decoration: BoxDecoration(
                              color: primaryColor.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(22),
                            ),
                            child: Column(
                              children: [
                                Container(
                                  width: 72,
                                  height: 72,
                                  decoration: BoxDecoration(
                                    color: primaryColor.withValues(alpha: 0.14),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.track_changes_rounded,
                                    color: primaryColor,
                                    size: 38,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                const Text(
                                  'Set Your Daily Goals',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Create realistic targets and stay consistent with your fitness journey.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          _buildGoalLabel(
                            icon: Icons.directions_walk_rounded,
                            title: 'Daily Steps',
                            subtitle: 'Target number of steps per day',
                          ),

                          const SizedBox(height: 10),

                          TextFormField(
                            controller: _stepsController,
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.next,
                            decoration: InputDecoration(
                              hintText: 'e.g. 10000',
                              suffixText: 'steps',
                              prefixIcon: const Icon(
                                Icons.directions_walk_outlined,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            validator: _validateSteps,
                          ),

                          const SizedBox(height: 22),

                          _buildGoalLabel(
                            icon: Icons.local_fire_department_rounded,
                            title: 'Daily Calories',
                            subtitle: 'Target calories to burn per day',
                          ),

                          const SizedBox(height: 10),

                          TextFormField(
                            controller: _caloriesController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            textInputAction: TextInputAction.next,
                            decoration: InputDecoration(
                              hintText: 'e.g. 500',
                              suffixText: 'kcal',
                              prefixIcon: const Icon(
                                Icons.local_fire_department_outlined,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            validator: _validateCalories,
                          ),

                          const SizedBox(height: 22),

                          _buildGoalLabel(
                            icon: Icons.timer_rounded,
                            title: 'Daily Workout Duration',
                            subtitle: 'Target workout time per day',
                          ),

                          const SizedBox(height: 10),

                          TextFormField(
                            controller: _durationController,
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.next,
                            decoration: InputDecoration(
                              hintText: 'e.g. 60',
                              suffixText: 'minutes',
                              prefixIcon: const Icon(Icons.timer_outlined),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            validator: _validateDuration,
                          ),

                          const SizedBox(height: 22),

                          _buildGoalLabel(
                            icon: Icons.route_rounded,
                            title: 'Daily Distance',
                            subtitle: 'Target distance to cover per day',
                          ),

                          const SizedBox(height: 10),

                          TextFormField(
                            controller: _distanceController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            textInputAction: TextInputAction.done,
                            decoration: InputDecoration(
                              hintText: 'e.g. 5',
                              suffixText: 'km',
                              prefixIcon: const Icon(Icons.route_outlined),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            validator: _validateDistance,
                            onFieldSubmitted: (_) {
                              if (!_isSaving) {
                                _saveGoals();
                              }
                            },
                          ),

                          const SizedBox(height: 28),

                          SizedBox(
                            height: 54,
                            child: FilledButton.icon(
                              onPressed: _isSaving ? null : _saveGoals,
                              style: FilledButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              icon: _isSaving
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                      ),
                                    )
                                  : const Icon(Icons.save_outlined),
                              label: Text(
                                _isSaving ? 'Saving...' : 'Save Goals',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          OutlinedButton.icon(
                            onPressed: _isSaving ? null : _resetToDefaults,
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            icon: const Icon(Icons.restart_alt_rounded),
                            label: const Text('Restore Default Goals'),
                          ),

                          const SizedBox(height: 18),

                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Theme.of(
                                  context,
                                ).colorScheme.outlineVariant,
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.info_outline_rounded),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Your goals are saved separately for your account. You can update them anytime.',
                                    style: TextStyle(fontSize: 13, height: 1.4),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildGoalLabel({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 24, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
