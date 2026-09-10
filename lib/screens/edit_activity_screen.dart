import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/activity_model.dart';
import '../services/activity_service.dart';
import '../services/auth_service.dart';

class EditActivityScreen extends StatefulWidget {
  final Activity activity;

  const EditActivityScreen({super.key, required this.activity});

  @override
  State<EditActivityScreen> createState() => _EditActivityScreenState();
}

class _EditActivityScreenState extends State<EditActivityScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _durationController;
  late final TextEditingController _caloriesController;
  late final TextEditingController _stepsController;
  late final TextEditingController _notesController;

  final List<String> _activityTypes = [
    'Running',
    'Walking',
    'Cycling',
    'Swimming',
    'Gym',
    'Strength',
    'Yoga',
    'Sports',
    'Other',
  ];

  late String _selectedType;
  late DateTime _selectedDate;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController(text: widget.activity.title);

    _durationController = TextEditingController(
      text: widget.activity.duration.toString(),
    );

    _caloriesController = TextEditingController(
      text: widget.activity.calories.toString(),
    );

    _stepsController = TextEditingController(
      text: widget.activity.steps.toString(),
    );

    _notesController = TextEditingController(text: widget.activity.notes);

    _selectedType = _activityTypes.contains(widget.activity.type)
        ? widget.activity.type
        : 'Other';

    _selectedDate = widget.activity.date;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _durationController.dispose();
    _caloriesController.dispose();
    _stepsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  String? _validateTitle(String? value) {
    final String title = value?.trim() ?? '';

    if (title.isEmpty) {
      return 'Please enter an activity title.';
    }

    if (title.length < 2) {
      return 'Title must be at least 2 characters.';
    }

    return null;
  }

  String? _validateDuration(String? value) {
    final String duration = value?.trim() ?? '';

    if (duration.isEmpty) {
      return 'Please enter duration.';
    }

    final int? parsedDuration = int.tryParse(duration);

    if (parsedDuration == null) {
      return 'Please enter a valid number.';
    }

    if (parsedDuration <= 0) {
      return 'Duration must be greater than 0.';
    }

    return null;
  }

  String? _validateCalories(String? value) {
    final String calories = value?.trim() ?? '';

    if (calories.isEmpty) {
      return 'Please enter calories.';
    }

    final double? parsedCalories = double.tryParse(calories);

    if (parsedCalories == null) {
      return 'Please enter a valid number.';
    }

    if (parsedCalories < 0) {
      return 'Calories cannot be negative.';
    }

    return null;
  }

  String? _validateSteps(String? value) {
    final String steps = value?.trim() ?? '';

    if (steps.isEmpty) {
      return 'Please enter steps.';
    }

    final int? parsedSteps = int.tryParse(steps);

    if (parsedSteps == null) {
      return 'Please enter a valid number.';
    }

    if (parsedSteps < 0) {
      return 'Steps cannot be negative.';
    }

    return null;
  }

  Future<void> _selectDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (pickedDate == null) {
      return;
    }

    setState(() {
      _selectedDate = pickedDate;
    });
  }

  Future<void> _updateActivity() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final String? currentUserId = AuthService.currentUserId;

    if (currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please login before updating an activity.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Screen-level ownership check.
    if (widget.activity.userId != currentUserId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You can only edit your own activity.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final Activity updatedActivity = widget.activity.copyWith(
      type: _selectedType,
      title: _titleController.text.trim(),
      duration: int.parse(_durationController.text.trim()),
      calories: double.parse(_caloriesController.text.trim()),
      steps: int.parse(_stepsController.text.trim()),
      date: _selectedDate,
      notes: _notesController.text.trim(),
      userId: currentUserId,
    );

    final bool updated = await ActivityService.updateActivity(
      updatedActivity: updatedActivity,
      userId: currentUserId,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _isSaving = false;
    });

    if (!updated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Activity could not be updated.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Activity updated successfully!'),
        behavior: SnackBarBehavior.floating,
      ),
    );

    // Return the complete updated object
    // to Activity Details screen.
    Navigator.of(context).pop(updatedActivity);
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edit Activity',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 54,
                            height: 54,
                            decoration: BoxDecoration(
                              color: primaryColor.withValues(alpha: 0.14),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.edit_rounded,
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
                                  'Update your workout',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Change the details of your fitness activity.',
                                  style: TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    DropdownButtonFormField<String>(
                      initialValue: _selectedType,
                      decoration: InputDecoration(
                        labelText: 'Activity Type',
                        prefixIcon: const Icon(Icons.category_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      items: _activityTypes
                          .map(
                            (String type) => DropdownMenuItem<String>(
                              value: type,
                              child: Text(type),
                            ),
                          )
                          .toList(),
                      onChanged: (String? value) {
                        if (value == null) {
                          return;
                        }

                        setState(() {
                          _selectedType = value;
                        });
                      },
                    ),

                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _titleController,
                      textCapitalization: TextCapitalization.sentences,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: 'Activity Title',
                        hintText: 'e.g. Morning Run',
                        prefixIcon: const Icon(Icons.title_rounded),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      validator: _validateTitle,
                    ),

                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _durationController,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: 'Duration',
                        hintText: 'Enter duration in minutes',
                        prefixIcon: const Icon(Icons.timer_outlined),
                        suffixText: 'min',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      validator: _validateDuration,
                    ),

                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _caloriesController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: 'Calories Burned',
                        hintText: 'Enter calories burned',
                        prefixIcon: const Icon(
                          Icons.local_fire_department_outlined,
                        ),
                        suffixText: 'kcal',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      validator: _validateCalories,
                    ),

                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _stepsController,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: 'Steps',
                        hintText: 'Enter number of steps',
                        prefixIcon: const Icon(Icons.directions_walk_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      validator: _validateSteps,
                    ),

                    const SizedBox(height: 16),

                    InkWell(
                      onTap: _selectDate,
                      borderRadius: BorderRadius.circular(14),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Activity Date',
                          prefixIcon: const Icon(Icons.calendar_today_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          DateFormat('dd MMMM yyyy').format(_selectedDate),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _notesController,
                      textCapitalization: TextCapitalization.sentences,
                      maxLines: 4,
                      maxLength: 300,
                      decoration: InputDecoration(
                        labelText: 'Notes',
                        hintText: 'Add any additional notes...',
                        alignLabelWithHint: true,
                        prefixIcon: const Padding(
                          padding: EdgeInsets.only(bottom: 60),
                          child: Icon(Icons.notes_outlined),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    SizedBox(
                      height: 54,
                      child: FilledButton.icon(
                        onPressed: _isSaving ? null : _updateActivity,
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
                            : const Icon(Icons.save_rounded),
                        label: Text(
                          _isSaving ? 'Updating...' : 'Update Activity',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
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
      ),
    );
  }
}
