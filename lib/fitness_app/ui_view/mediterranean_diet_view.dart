import 'package:FITBACK/fitness_app/fitness_app_theme.dart';
import 'package:FITBACK/main.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../models/diary_data.dart';  // Add this import for MacroNutrients
import '../../services/calorie_calculator.dart';
import '../../services/database_service.dart';
import '../../services/user_service.dart';
import 'package:provider/provider.dart';
import '../../services/diary_data_provider.dart';
import '../models/macro_nutrients.dart';

class MediterranesnDietView extends StatelessWidget {
  final AnimationController animationController;
  final Animation<double> animation;
  final double calories;
  final MacroNutrients macros;

  const MediterranesnDietView({
    Key? key,
    required this.animationController,
    required this.animation,
    required this.calories,
    required this.macros,
  }) : super(key: key);

  Future<Map<String, dynamic>> _loadUserData() async {
    final userData = await DatabaseService.getUserProfile(UserService.userId!);
    final weight = double.parse(userData['weight'].toString());
    final height = double.parse(userData['height'].toString());
    final age = int.parse(userData['age'].toString());
    final isMale = userData['gender'] == 'male';
    final activityLevel = userData['activityLevel'] ?? 'moderate';
    final goal = userData['goal'] ?? 'maintain';

    final bmi = CalorieCalculator.calculateBMI(
      weight: weight,
      height: height,
    );

    final bmr = CalorieCalculator.calculateBMR(
      weight: weight,
      height: height,
      age: age,
      isMale: isMale,
    );

    final baseCalories = CalorieCalculator.calculateDailyCalories(
      bmr: bmr,
      activityLevel: activityLevel,
    );

    final dailyCalories = CalorieCalculator.adjustCaloriesForGoal(
      baseCalories,
      goal,
    );

    final macroTargets = CalorieCalculator.calculateMacroTargets(dailyCalories);

    return {
      'bmi': bmi,
      'dailyCalories': dailyCalories,
      'macroTargets': macroTargets,
      'baseCalories': baseCalories,
    };
  }

  Color _getCalorieStatusColor(double caloriesNeeded) {
    if (caloriesNeeded <= 0) {
      return Colors.green; // On track or exceeded goal
    } else if (caloriesNeeded <= 300) {
      return Colors.orange; // Close to goal
    }
    return Colors.red; // Far from goal
  }

  String _getCalorieStatusMessage(double caloriesNeeded) {
    if (caloriesNeeded <= 0) {
      return 'Goal reached! ${(-caloriesNeeded).toInt()} Kcal over';
    }
    return '${caloriesNeeded.toInt()} Kcal to reach goal';
  }

  Color _getProgressColor(double caloriesLeft, double goal) {
    if (caloriesLeft >= 0) {
      return Colors.green; // Within goal
    } else if (caloriesLeft >= -200) {
      return Colors.orange; // Slightly over
    }
    return Colors.red; // Far over
  }

  String _getProgressMessage(double caloriesLeft) {
    if (caloriesLeft >= 0) {
      return 'Goal reached! Keep it up!';
    } else if (caloriesLeft >= -200) {
      return 'Almost there!';
    }
    return 'Over by ${(-caloriesLeft).toInt()} Kcal';
  }

  double _calculateProgress(double caloriesLeft, double goal) {
    // If no calories consumed, return 0
    if (goal <= 0) return 0.0;
    
    // Calculate consumed calories
    double consumed = goal - caloriesLeft;
    if (consumed <= 0) return 0.0;
    
    // Calculate progress percentage
    double progress = consumed / goal;
    
    // Ensure progress is between 0 and 1
    return progress.clamp(0.0, 1.0);
  }

  Widget _buildCalorieStatus(double caloriesNeeded) {
    final color = _getCalorieStatusColor(caloriesNeeded);
    final message = _getCalorieStatusMessage(caloriesNeeded);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            caloriesNeeded <= 0 ? Icons.check_circle : Icons.info_outline,
            color: color,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            message,
            style: TextStyle(
              color: color,
              fontFamily: FitnessAppTheme.fontName,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressRing(double caloriesNeeded, double dailyGoal) {
    final color = _getCalorieStatusColor(caloriesNeeded);
    
    // Calculate actual calories consumed
    double caloriesConsumed = dailyGoal - caloriesNeeded;
    
    // Calculate true progress ratio (0 to 1)
    double progressRatio = 0.0;
    if (dailyGoal > 0) {
      progressRatio = (caloriesConsumed / dailyGoal).clamp(0.0, 1.0);
    }

    // Constants for arc drawing
    const double startAngle = -90.0; // Start from top
    const double maxSweepAngle = 360.0; // Full circle sweep
    
    // Calculate sweep angle based on progress
    final double sweepAngle = maxSweepAngle * progressRatio;

    print('Progress Debug:');
    print('Daily Goal: $dailyGoal kcal');
    print('Calories Consumed: $caloriesConsumed kcal');
    print('Progress Ratio: ${(progressRatio * 100).toStringAsFixed(2)}%');
    print('Start Angle: $startAngle°');
    print('Sweep Angle: $sweepAngle°');

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: FitnessAppTheme.white,
              borderRadius: BorderRadius.circular(100.0),
              border: Border.all(
                width: 4,
                color: color.withOpacity(0.2),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${caloriesNeeded.abs().toInt()}',
                  style: TextStyle(
                    fontFamily: FitnessAppTheme.fontName,
                    fontWeight: FontWeight.normal,
                    fontSize: 24,
                    color: color,
                  ),
                ),
                Text(
                  caloriesNeeded >= 0 ? 'Kcal left' : 'Kcal over',
                  style: TextStyle(
                    fontFamily: FitnessAppTheme.fontName,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: color.withOpacity(0.5),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getProgressMessage(caloriesNeeded),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10,
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: CustomPaint(
            painter: CurvePainter(
              colors: [color, color.withOpacity(0.8), color.withOpacity(0.6)],
              startAngle: startAngle,
              sweepAngle: sweepAngle,
              progress: progressRatio,
              dailyGoal: dailyGoal,
              caloriesConsumed: caloriesConsumed,
            ),
            child: const SizedBox(
              width: 108,
              height: 108,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _loadUserData(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final userData = snapshot.data!;
        final dailyCalories = userData['dailyCalories'];
        final macroTargets = userData['macroTargets'] as MacroTargets;

        return Consumer<DiaryDataProvider>(
          builder: (context, diaryData, _) {
            final eatenCalories = diaryData.diaryData.eatenCalories;
            final burnedCalories = diaryData.diaryData.burnedCalories;
            final remainingCalories = dailyCalories - eatenCalories + burnedCalories;
            final dailyGoal = userData['dailyCalories'];
            final caloriesNeeded = dailyGoal - (eatenCalories - burnedCalories);

            // Calculate macro progress
            final macroProgress = CalorieCalculator.calculateMacroProgress(
              macroTargets,
              diaryData.diaryData.macros,
            );

            return AnimatedBuilder(
              animation: animationController,
              builder: (context, _) {
                return _buildContent(
                  context,
                  eatenCalories,
                  burnedCalories,
                  remainingCalories,
                  macroProgress,
                  caloriesNeeded,
                  dailyGoal,
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildContent(
    BuildContext context,
    double eatenCalories,
    double burnedCalories,
    double remainingCalories,
    MacroProgress macroProgress,
    double caloriesNeeded,
    double dailyGoal,
  ) {
    // Replace hardcoded values with actual data
    return FadeTransition(
      opacity: animation,
      child: Transform(
        transform: Matrix4.translationValues(0.0, 30 * (1.0 - animation.value), 0.0),
        child: Padding(
          padding: const EdgeInsets.only(
              left: 24, right: 24, top: 16, bottom: 18),
          child: Container(
            decoration: BoxDecoration(
              color: FitnessAppTheme.white,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8.0),
                  bottomLeft: Radius.circular(8.0),
                  bottomRight: Radius.circular(8.0),
                  topRight: Radius.circular(68.0)),
              boxShadow: <BoxShadow>[
                BoxShadow(
                    color: FitnessAppTheme.grey.withOpacity(0.2),
                    offset: Offset(1.1, 1.1),
                    blurRadius: 10.0),
              ],
            ),
            child: Column(
              children: <Widget>[
                Padding(
                  padding:
                      const EdgeInsets.only(top: 16, left: 16, right: 16),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: 8, right: 8, top: 4),
                          child: Column(
                            children: <Widget>[
                              _buildCalorieRow('Eaten', eatenCalories, HexColor('#87A0E5')),
                              SizedBox(
                                height: 8,
                              ),
                              _buildCalorieRow('Burned', burnedCalories, HexColor('#F56E98')),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: Center(
                          child: _buildProgressRing(caloriesNeeded, dailyGoal),
                        ),
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      left: 24, right: 24, top: 8, bottom: 8),
                  child: Container(
                    height: 2,
                    decoration: BoxDecoration(
                      color: FitnessAppTheme.background,
                      borderRadius: BorderRadius.all(Radius.circular(4.0)),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      left: 24, right: 24, top: 8, bottom: 16),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: _buildMacroRow(
                          'Carbs',
                          macroProgress,
                          HexColor('#87A0E5'),
                          animation.value,
                        ),
                      ),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            _buildMacroRow(
                              'Protein',
                              macroProgress,
                              HexColor('#F56E98'),
                              animation.value,
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            _buildMacroRow(
                              'Fat',
                              macroProgress,
                              HexColor('#F1B440'),
                              animation.value,
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: _buildCalorieStatus(caloriesNeeded),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Add helper methods for building rows
  Widget _buildCalorieRow(String label, double calories, Color color) {
    return Row(
      children: <Widget>[
        Container(
          height: 48,
          width: 2,
          decoration: BoxDecoration(
            color: color.withOpacity(0.5),
            borderRadius: BorderRadius.all(Radius.circular(4.0)),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 2),
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: FitnessAppTheme.fontName,
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                    letterSpacing: -0.1,
                    color: FitnessAppTheme.grey.withOpacity(0.5),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  SizedBox(
                    width: 28,
                    height: 28,
                    child: Image.asset("assets/fitness_app/eaten.png"),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 3),
                    child: Text(
                      '${(calories * animation.value).toInt()}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: FitnessAppTheme.fontName,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: FitnessAppTheme.darkerText,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 3),
                    child: Text(
                      'Kcal',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: FitnessAppTheme.fontName,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        letterSpacing: -0.2,
                        color: FitnessAppTheme.grey.withOpacity(0.5),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        )
      ],
    );
  }

  Widget _buildMacroRow(String label, MacroProgress progress, Color color, double animValue) {
    final MacroData macroData = _getMacroData(label, progress);
    final bool isOver = macroData.remaining < 0;
    
    final String displayText = isOver 
        ? '${macroData.remaining.abs().toStringAsFixed(1)}g over'
        : '${macroData.remaining.toStringAsFixed(1)}g left';

    final double progressValue = macroData.percentage;
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '${label} (${macroData.consumed.toStringAsFixed(1)}/${macroData.target.toStringAsFixed(1)}g)',
              style: TextStyle(
                fontFamily: FitnessAppTheme.fontName,
                fontWeight: FontWeight.w500,
                fontSize: 14,
                letterSpacing: -0.2,
                color: FitnessAppTheme.darkText,
              ),
            ),
            if (isOver) const SizedBox(width: 4),
            if (isOver)
              Tooltip(
                message: 'Exceeded ${label.toLowerCase()} target',
                child: Icon(
                  Icons.warning,
                  size: 16,
                  color: Colors.orange,
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: 70,
          child: Stack(
            children: [
              // Background
              Container(
                height: 4,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              // Progress
              Container(
                height: 4,
                width: 70 * progressValue * animValue,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      isOver ? Colors.orange : color,
                      isOver ? Colors.orange.withOpacity(0.5) : color.withOpacity(0.5),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          displayText,
          style: TextStyle(
            fontFamily: FitnessAppTheme.fontName,
            fontWeight: FontWeight.w600,
            fontSize: 12,
            color: isOver ? Colors.orange : FitnessAppTheme.grey.withOpacity(0.5),
          ),
        ),
      ],
    );
  }

  MacroData _getMacroData(String label, MacroProgress progress) {
    switch (label.toLowerCase()) {
      case 'carbs':
        return MacroData(
          consumed: progress.carbsConsumed,
          target: progress.carbsTarget,
          remaining: progress.carbsRemaining,
          percentage: progress.carbsPercentage,
        );
      case 'protein':
        return MacroData(
          consumed: progress.proteinConsumed,
          target: progress.proteinTarget,
          remaining: progress.proteinRemaining,
          percentage: progress.proteinPercentage,
        );
      case 'fat':
        return MacroData(
          consumed: progress.fatConsumed,
          target: progress.fatTarget,
          remaining: progress.fatRemaining,
          percentage: progress.fatPercentage,
        );
      default:
        throw ArgumentError('Unknown macro type: $label');
    }
  }
}

class MacroData {
  final double consumed;
  final double target;
  final double remaining;
  final double percentage;

  const MacroData({
    required this.consumed,
    required this.target,
    required this.remaining,
    required this.percentage,
  });
}

class CurvePainter extends CustomPainter {
  final List<Color>? colors;
  final double startAngle;
  final double sweepAngle;
  final double progress;
  final double dailyGoal;
  final double caloriesConsumed;

  CurvePainter({
    this.colors,
    this.startAngle = -90.0,
    this.sweepAngle = 0.0,
    this.progress = 0.0,
    this.dailyGoal = 0.0,
    this.caloriesConsumed = 0.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (caloriesConsumed <= 0 || dailyGoal <= 0) {
      _drawEmptyRing(canvas, size);
      return;
    }

    _drawProgressRing(canvas, size);
  }

  void _drawEmptyRing(Canvas canvas, Size size) {
    final emptyPaint = Paint()
      ..color = Colors.grey.withOpacity(0.2)
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14;
    
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width / 2, size.height / 2) - (14 / 2);
    
    canvas.drawCircle(center, radius, emptyPaint);
  }

  void _drawProgressRing(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width / 2, size.height / 2) - (14 / 2);
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Draw background ring
    final bgPaint = Paint()
      ..color = Colors.grey.withOpacity(0.2)
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    
    canvas.drawCircle(center, radius, bgPaint);

    // Draw progress arc
    if (sweepAngle > 0) {
      final paint = Paint()
        ..shader = SweepGradient(
          colors: colors ?? [Colors.blue, Colors.blue.withOpacity(0.8)],
          startAngle: degreeToRadians(startAngle),
          endAngle: degreeToRadians(startAngle + sweepAngle),
        ).createShader(rect)
        ..strokeWidth = 14
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      canvas.drawArc(
        rect,
        degreeToRadians(startAngle),
        degreeToRadians(sweepAngle),
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }

  double degreeToRadians(double degree) {
    var redian = (math.pi / 180) * degree;
    return redian;
  }
}
