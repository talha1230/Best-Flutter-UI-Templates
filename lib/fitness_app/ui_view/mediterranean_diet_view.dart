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

    final bmr = CalorieCalculator.calculateBMR(
      weight: weight,
      height: height,
      age: age,
      isMale: true, // TODO: Add gender to user profile
    );

    final dailyCalories = CalorieCalculator.calculateDailyCalories(bmr: bmr);
    final macroTargets = CalorieCalculator.calculateMacroTargets(dailyCalories);

    return {
      'dailyCalories': dailyCalories,
      'macroTargets': macroTargets,
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
        final macroTargets = userData['macroTargets'];

        return Consumer<DiaryDataProvider>(
          builder: (context, diaryData, _) {
            final eatenCalories = diaryData.diaryData.eatenCalories;
            final burnedCalories = diaryData.diaryData.burnedCalories;
            final remainingCalories = dailyCalories - eatenCalories + burnedCalories;
            final dailyGoal = userData['dailyCalories'];
            final caloriesNeeded = dailyGoal - (eatenCalories - burnedCalories);

            // Calculate remaining macros
            final consumedMacros = diaryData.diaryData.macros;
            final remainingCarbs = macroTargets['carbs']! - consumedMacros.carbs;
            final remainingProtein = macroTargets['protein']! - consumedMacros.protein;
            final remainingFat = macroTargets['fat']! - consumedMacros.fat;

            return AnimatedBuilder(
              animation: animationController,
              builder: (context, _) {
                return _buildContent(
                  context,
                  eatenCalories,
                  burnedCalories,
                  remainingCalories,
                  remainingCarbs,
                  remainingProtein,
                  remainingFat,
                  caloriesNeeded, // Add this parameter
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
    double remainingCarbs,
    double remainingProtein,
    double remainingFat,
    double caloriesNeeded, // Add this parameter
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
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    color: FitnessAppTheme.white,
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(100.0),
                                    ),
                                    border: new Border.all(
                                        width: 4,
                                        color: FitnessAppTheme
                                            .nearlyDarkBlue
                                            .withOpacity(0.2)),
                                  ),
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Text(
                                        '${(remainingCalories * animation.value).toInt()}',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontFamily:
                                              FitnessAppTheme.fontName,
                                          fontWeight: FontWeight.normal,
                                          fontSize: 24,
                                          letterSpacing: 0.0,
                                          color: FitnessAppTheme
                                              .nearlyDarkBlue,
                                        ),
                                      ),
                                      Text(
                                        'Kcal left',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontFamily:
                                              FitnessAppTheme.fontName,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                          letterSpacing: 0.0,
                                          color: FitnessAppTheme.grey
                                              .withOpacity(0.5),
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
                                      colors: [
                                        FitnessAppTheme.nearlyDarkBlue,
                                        HexColor("#8A98E8"),
                                        HexColor("#8A98E8")
                                      ],
                                      angle: 140 +
                                          (360 - 140) *
                                              (1.0 - animation.value)),
                                  child: SizedBox(
                                    width: 108,
                                    height: 108,
                                  ),
                                ),
                              )
                            ],
                          ),
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
                          remainingCarbs,
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
                              remainingProtein,
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
                              remainingFat,
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

  Widget _buildMacroRow(String label, double remaining, Color color, double animValue) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: FitnessAppTheme.fontName,
            fontWeight: FontWeight.w500,
            fontSize: 16,
            letterSpacing: -0.2,
            color: FitnessAppTheme.darkText,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Container(
            height: 4,
            width: 70,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.all(Radius.circular(4.0)),
            ),
            child: Row(
              children: <Widget>[
                Container(
                  width: ((70 / 1.2) * animValue),
                  height: 4,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                      color,
                      color.withOpacity(0.5),
                    ]),
                    borderRadius: BorderRadius.all(Radius.circular(4.0)),
                  ),
                )
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(
            '${remaining.toInt()}g left',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: FitnessAppTheme.fontName,
              fontWeight: FontWeight.w600,
              fontSize: 12,
              color: FitnessAppTheme.grey.withOpacity(0.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressRing(double caloriesNeeded, double dailyGoal) {
    // Calculate progress percentage
    final progress = math.max(0.0, math.min(1.0, (dailyGoal - caloriesNeeded) / dailyGoal));
    final angle = 140 + (360 - 140) * progress;
    
    return CustomPaint(
      painter: CurvePainter(
        colors: [
          _getCalorieStatusColor(caloriesNeeded),
          HexColor("#8A98E8"),
          HexColor("#8A98E8"),
        ],
        angle: angle,
      ),
      child: const SizedBox(
        width: 108,
        height: 108,
      ),
    );
  }
}

class CurvePainter extends CustomPainter {
  final double? angle;
  final List<Color>? colors;

  CurvePainter({this.colors, this.angle = 140});

  @override
  void paint(Canvas canvas, Size size) {
    List<Color> colorsList = [];
    if (colors != null) {
      colorsList = colors ?? [];
    } else {
      colorsList.addAll([Colors.white, Colors.white]);
    }

    final shdowPaint = new Paint()
      ..color = Colors.black.withOpacity(0.4)
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14;
    final shdowPaintCenter = new Offset(size.width / 2, size.height / 2);
    final shdowPaintRadius =
        math.min(size.width / 2, size.height / 2) - (14 / 2);
    canvas.drawArc(
        new Rect.fromCircle(center: shdowPaintCenter, radius: shdowPaintRadius),
        degreeToRadians(278),
        degreeToRadians(360 - (365 - angle!)),
        false,
        shdowPaint);

    shdowPaint.color = Colors.grey.withOpacity(0.3);
    shdowPaint.strokeWidth = 16;
    canvas.drawArc(
        new Rect.fromCircle(center: shdowPaintCenter, radius: shdowPaintRadius),
        degreeToRadians(278),
        degreeToRadians(360 - (365 - angle!)),
        false,
        shdowPaint);

    shdowPaint.color = Colors.grey.withOpacity(0.2);
    shdowPaint.strokeWidth = 20;
    canvas.drawArc(
        new Rect.fromCircle(center: shdowPaintCenter, radius: shdowPaintRadius),
        degreeToRadians(278),
        degreeToRadians(360 - (365 - angle!)),
        false,
        shdowPaint);

    shdowPaint.color = Colors.grey.withOpacity(0.1);
    shdowPaint.strokeWidth = 22;
    canvas.drawArc(
        new Rect.fromCircle(center: shdowPaintCenter, radius: shdowPaintRadius),
        degreeToRadians(278),
        degreeToRadians(360 - (365 - angle!)),
        false,
        shdowPaint);

    final rect = new Rect.fromLTWH(0.0, 0.0, size.width, size.width);
    final gradient = new SweepGradient(
      startAngle: degreeToRadians(268),
      endAngle: degreeToRadians(270.0 + 360),
      tileMode: TileMode.repeated,
      colors: colorsList,
    );
    final paint = new Paint()
      ..shader = gradient.createShader(rect)
      ..strokeCap = StrokeCap.round // StrokeCap.round is not recommended.
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14;
    final center = new Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width / 2, size.height / 2) - (14 / 2);

    canvas.drawArc(
        new Rect.fromCircle(center: center, radius: radius),
        degreeToRadians(278),
        degreeToRadians(360 - (365 - angle!)),
        false,
        paint);

    final gradient1 = new SweepGradient(
      tileMode: TileMode.repeated,
      colors: [Colors.white, Colors.white],
    );

    var cPaint = new Paint();
    cPaint..shader = gradient1.createShader(rect);
    cPaint..color = Colors.white;
    cPaint..strokeWidth = 14 / 2;
    canvas.save();

    final centerToCircle = size.width / 2;
    canvas.save();

    canvas.translate(centerToCircle, centerToCircle);
    canvas.rotate(degreeToRadians(angle! + 2));

    canvas.save();
    canvas.translate(0.0, -centerToCircle + 14 / 2);
    canvas.drawCircle(new Offset(0, 0), 14 / 5, cPaint);

    canvas.restore();
    canvas.restore();
    canvas.restore();
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
