class CalorieCalculator {
  static const double ACTIVITY_SEDENTARY = 1.2;
  static const double ACTIVITY_LIGHT = 1.375;
  static const double ACTIVITY_MODERATE = 1.55;
  static const double ACTIVITY_ACTIVE = 1.725;
  static const double ACTIVITY_VERY_ACTIVE = 1.9;

  static double calculateBMR({
    required double weight,
    required double height,
    required int age,
    required bool isMale,
  }) {
    if (isMale) {
      return 88.362 + (13.397 * weight) + (4.799 * height) - (5.677 * age);
    } else {
      return 447.593 + (9.247 * weight) + (3.098 * height) - (4.330 * age);
    }
  }

  static double calculateDailyCalories({
    required double bmr,
    double activityMultiplier = ACTIVITY_MODERATE,
  }) {
    return bmr * activityMultiplier;
  }

  static Map<String, double> calculateMacroTargets(double totalCalories) {
    // 50% carbs, 30% protein, 20% fat
    final carbCalories = totalCalories * 0.5;
    final proteinCalories = totalCalories * 0.3;
    final fatCalories = totalCalories * 0.2;

    return {
      'carbs': carbCalories / 4, // 4 calories per gram of carbs
      'protein': proteinCalories / 4, // 4 calories per gram of protein
      'fat': fatCalories / 9, // 9 calories per gram of fat
    };
  }
}
