import 'package:flutter/material.dart';
import '../fitness_app_theme.dart';
import '../models/diary_data.dart';

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
            child: SizedBox(
              height: 130,
              child: Padding(
                padding: const EdgeInsets.only(
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
                    child: Row(
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
}
