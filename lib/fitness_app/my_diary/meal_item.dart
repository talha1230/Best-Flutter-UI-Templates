import 'package:flutter/material.dart';
import '../fitness_app_theme.dart';
import '../models/diary_data.dart';
import 'package:provider/provider.dart';
import '../../services/diary_data_provider.dart';

class MealItem extends StatelessWidget {
  final Meal meal;
  final AnimationController? animationController;
  final Animation<double>? animation;

  const MealItem({
    Key? key,
    required this.meal,
    this.animationController,
    this.animation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animationController!,
      builder: (BuildContext context, Widget? child) {
        return FadeTransition(
          opacity: animation!,
          child: Transform(
            transform: Matrix4.translationValues(
                100 * (1.0 - animation!.value), 0.0, 0.0),
            child: Container(  // Changed from SizedBox to Container
              constraints: BoxConstraints(minHeight: 180),  // Use constraints instead of fixed height
              margin: const EdgeInsets.only(
                  left: 24, right: 24, top: 16, bottom: 18),
              child: Container(
                decoration: BoxDecoration(
                  color: FitnessAppTheme.white,
                  borderRadius: BorderRadius.circular(8.0),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: FitnessAppTheme.grey.withOpacity(0.2),
                      offset: const Offset(1.1, 1.1),
                      blurRadius: 10.0,
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,  // Add this
                    children: [
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  meal.name,
                                  style: const TextStyle(
                                    fontFamily: FitnessAppTheme.fontName,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Row(
                                    children: <Widget>[
                                      _buildMacroInfo('Carbs', meal.macros.carbs),
                                      const SizedBox(width: 10),
                                      _buildMacroInfo('Protein', meal.macros.protein),
                                      const SizedBox(width: 10),
                                      _buildMacroInfo('Fat', meal.macros.fat),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: <Widget>[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                    '${meal.calories.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      fontFamily: FitnessAppTheme.fontName,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                      color: FitnessAppTheme.darkerText,
                                    ),
                                  ),
                                  const Text(
                                    ' kcal',
                                    style: TextStyle(
                                      fontFamily: FitnessAppTheme.fontName,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                      letterSpacing: -0.2,
                                      color: FitnessAppTheme.grey,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                _formatTime(meal.time),
                                style: const TextStyle(
                                  fontFamily: FitnessAppTheme.fontName,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12,
                                  letterSpacing: 0.0,
                                  color: FitnessAppTheme.grey,
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                      _buildStatusBar(context),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _showEditDialog(context),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _showDeleteConfirmation(context),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMacroInfo(String label, double value) {
    return Row(
      children: <Widget>[
        Text(
          '$label: ',
          style: const TextStyle(
            fontFamily: FitnessAppTheme.fontName,
            fontWeight: FontWeight.w500,
            fontSize: 12,
            letterSpacing: 0.0,
            color: FitnessAppTheme.grey,
          ),
        ),
        Text(
          '${value.toStringAsFixed(1)}g',
          style: const TextStyle(
            fontFamily: FitnessAppTheme.fontName,
            fontWeight: FontWeight.w600,
            fontSize: 12,
            letterSpacing: 0.0,
            color: FitnessAppTheme.darkerText,
          ),
        ),
      ],
    );
  }

  String _formatTime(DateTime time) {
    String period = time.hour >= 12 ? 'PM' : 'AM';
    int hour = time.hour > 12 ? time.hour - 12 : time.hour;
    hour = hour == 0 ? 12 : hour;
    return '${hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')} $period';
  }

  Widget _buildStatusBar(BuildContext context) {
    final color = meal.status == MealStatus.consumed
        ? Colors.green
        : meal.status == MealStatus.skipped
            ? Colors.red
            : Colors.grey;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: LinearProgressIndicator(
                value: meal.status == MealStatus.pending ? 0 : 1,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
            const SizedBox(width: 8),
            DropdownButton<MealStatus>(
              value: meal.status,
              onChanged: (newStatus) => _updateStatus(context, newStatus!),
              items: MealStatus.values.map((status) {
                return DropdownMenuItem(
                  value: status,
                  child: Text(status.name.toUpperCase()),
                );
              }).toList(),
            ),
          ],
        ),
        if (meal.reason != null && meal.status == MealStatus.skipped)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              'Reason: ${meal.reason}',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

  void _updateStatus(BuildContext context, MealStatus newStatus) async {
    String? reason;
    if (newStatus == MealStatus.skipped) {
      reason = await showDialog<String>(
        context: context,
        builder: (context) => _ReasonDialog(),
      );
      if (reason == null) return;  // User cancelled
    }

    final updatedMeal = Meal(
      id: meal.id,
      name: meal.name,
      calories: meal.calories,
      macros: meal.macros,
      time: meal.time,
      status: newStatus,
      reason: reason,
    );

    try {
      await context.read<DiaryDataProvider>().updateMeal(meal.id, updatedMeal);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update meal status: $e')),
      );
    }
  }

  void _showEditDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Meal'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                initialValue: meal.name,
                decoration: const InputDecoration(labelText: 'Name'),
                onChanged: (value) {
                  // Add edit logic here
                },
              ),
              // Add more fields as needed
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Add save logic here
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Meal'),
        content: const Text('Are you sure you want to delete this meal?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<DiaryDataProvider>().deleteMeal(meal.id);
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

}

class _ReasonDialog extends StatefulWidget {
  @override
  _ReasonDialogState createState() => _ReasonDialogState();
}

class _ReasonDialogState extends State<_ReasonDialog> {
  final _reasonController = TextEditingController();

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Skip Reason'),
      content: TextField(
        controller: _reasonController,
        decoration: const InputDecoration(
          hintText: 'Why are you skipping this meal?',
          border: OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, _reasonController.text),
          child: const Text('Save'),
        ),
      ],
    );
  }
}
