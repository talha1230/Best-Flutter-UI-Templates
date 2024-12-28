import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../fitness_app_theme.dart';
import '../../../services/diary_data_provider.dart';

class WaterView extends StatelessWidget {
  final AnimationController? mainScreenAnimationController;
  final Animation<double>? mainScreenAnimation;
  final int waterIntake;
  final int waterGoal;
  final Function(int) onWaterIntakeChanged;

  const WaterView({
    Key? key,
    required this.mainScreenAnimationController,
    required this.mainScreenAnimation,
    required this.waterIntake,
    required this.waterGoal,
    required this.onWaterIntakeChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<DiaryDataProvider>(
      builder: (context, provider, child) {
        final waterIntake = provider.diaryData.waterIntake;
        final waterGoal = provider.diaryData.waterGoal;

        return AnimatedBuilder(
          animation: mainScreenAnimationController!,
          builder: (BuildContext context, Widget? child) {
            return FadeTransition(
              opacity: mainScreenAnimation!,
              child: Transform(
                transform: Matrix4.translationValues(
                    0.0, 30 * (1.0 - mainScreenAnimation!.value), 0.0),
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
                          topRight: Radius.circular(8.0)),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                            color: FitnessAppTheme.grey.withOpacity(0.2),
                            offset: Offset(1.1, 1.1),
                            blurRadius: 10.0),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 16),
                      child: Column(
                        children: [
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      'Water Intake',
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                        fontFamily: FitnessAppTheme.fontName,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 18,
                                        letterSpacing: 0.0,
                                        color: FitnessAppTheme.darkText,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: LinearProgressIndicator(
                                        value: provider.diaryData.waterIntake / provider.diaryData.waterGoal,
                                        backgroundColor: FitnessAppTheme.nearlyDarkBlue.withOpacity(0.2),
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          FitnessAppTheme.nearlyDarkBlue,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Text(
                                        '${provider.diaryData.waterIntake} of ${provider.diaryData.waterGoal} glasses',
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          fontFamily: FitnessAppTheme.fontName,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 14,
                                          letterSpacing: 0.0,
                                          color: FitnessAppTheme.grey.withOpacity(0.5),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          if (waterIntake >= waterGoal)
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'Daily water goal reached! 🎉',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              IconButton(
                                icon: Icon(Icons.remove_circle),
                                color: FitnessAppTheme.nearlyDarkBlue,
                                onPressed: waterIntake > 0
                                    ? () => onWaterIntakeChanged(waterIntake - 1)
                                    : null,
                              ),
                              Text(
                                '$waterIntake / $waterGoal glasses',
                                style: TextStyle(fontSize: 18),
                              ),
                              IconButton(
                                icon: Icon(Icons.add_circle),
                                color: FitnessAppTheme.nearlyDarkBlue,
                                onPressed: waterIntake < waterGoal
                                    ? () => onWaterIntakeChanged(waterIntake + 1)
                                    : null,
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
      },
    );
  }
}
