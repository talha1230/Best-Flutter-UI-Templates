class CalorieCalculator {
  static const double ACTIVITY_SEDENTARY = 1.2;
  static const double ACTIVITY_LIGHT = 1.375;
  static const double ACTIVITY_MODERATE = 1.55;
  static const double ACTIVITY_ACTIVE = 1.725;
  static const double ACTIVITY_VERY_ACTIVE = 1.9;

  static double calculateBMI({required double weight, required double height}) {
    return weight / ((height / 100) * (height / 100));
  }

  static double calculateBMR({
    required double weight,
    required double height,
    required int age,
    required bool isMale,
  }) {
    // Mifflin-St Jeor Equation
    double bmr = (10 * weight) + (6.25 * height) - (5 * age);
    return isMale ? bmr + 5 : bmr - 161;
  }

  static double calculateDailyCalories({
    required double bmr,
    required String activityLevel,
  }) {
    // Activity multipliers
    final multipliers = {
      'sedentary': 1.2,      // Little or no exercise
      'light': 1.375,        // Light exercise 1-3 days/week
      'moderate': 1.55,      // Moderate exercise 3-5 days/week
      'active': 1.725,       // Heavy exercise 6-7 days/week
      'very_active': 1.9,    // Very heavy exercise, physical job
    };

    return bmr * (multipliers[activityLevel] ?? 1.2);
  }

  static Map<String, double> calculateMacroTargets(double dailyCalories) {
    // Macro distribution: 40% carbs, 30% protein, 30% fat
    return {
      'carbs': (dailyCalories * 0.4) / 4,    // 4 calories per gram
      'protein': (dailyCalories * 0.3) / 4,   // 4 calories per gram
      'fat': (dailyCalories * 0.3) / 9,       // 9 calories per gram
    };
  }

  static double adjustCaloriesForGoal(double calories, String goal) {
    switch (goal) {
      case 'lose':
        return calories - 500;  // 500 calorie deficit
      case 'gain':
        return calories + 500;  // 500 calorie surplus
      default:
        return calories;        // maintain weight
    }
  }
}
