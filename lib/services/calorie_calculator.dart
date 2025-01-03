import '../fitness_app/models/macro_nutrients.dart';
import 'dart:developer' as developer;

class CalorieCalculator {
  static const double ACTIVITY_SEDENTARY = 1.2;
  static const double ACTIVITY_LIGHT = 1.375;
  static const double ACTIVITY_MODERATE = 1.55;
  static const double ACTIVITY_ACTIVE = 1.725;
  static const double ACTIVITY_VERY_ACTIVE = 1.9;

  // Macronutrient calorie constants
  static const double CALORIES_PER_GRAM_PROTEIN = 4.0;
  static const double CALORIES_PER_GRAM_CARBS = 4.0;
  static const double CALORIES_PER_GRAM_FAT = 9.0;

  // Default macro ratios (40/30/30)
  static const double DEFAULT_CARB_RATIO = 0.4;
  static const double DEFAULT_PROTEIN_RATIO = 0.3;
  static const double DEFAULT_FAT_RATIO = 0.3;

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

  static MacroTargets calculateMacroTargets(double dailyCalories) {
    // Calculate grams based on calorie distribution and proper conversion ratios
    final carbsCalories = dailyCalories * DEFAULT_CARB_RATIO;
    final proteinCalories = dailyCalories * DEFAULT_PROTEIN_RATIO;
    final fatCalories = dailyCalories * DEFAULT_FAT_RATIO;

    final targets = MacroTargets(
      carbs: (carbsCalories / CALORIES_PER_GRAM_CARBS).round(),
      protein: (proteinCalories / CALORIES_PER_GRAM_PROTEIN).round(),
      fat: (fatCalories / CALORIES_PER_GRAM_FAT).round(),
    );

    // Debug logging
    developer.log('''
Macro Targets Calculation:
Daily Calories: $dailyCalories
Carbs: ${targets.carbs}g (${carbsCalories.round()} kcal)
Protein: ${targets.protein}g (${proteinCalories.round()} kcal)
Fat: ${targets.fat}g (${fatCalories.round()} kcal)
''');

    return targets;
  }

  static MacroNutrients calculateMacrosFromCalories(double calories) {
    final macros = MacroNutrients(
      carbs: (calories * DEFAULT_CARB_RATIO) / CALORIES_PER_GRAM_CARBS,
      protein: (calories * DEFAULT_PROTEIN_RATIO) / CALORIES_PER_GRAM_PROTEIN,
      fat: (calories * DEFAULT_FAT_RATIO) / CALORIES_PER_GRAM_FAT,
    );

    // Debug logging
    developer.log('''
Calories to Macros Conversion:
Calories: $calories
Carbs: ${macros.carbs.toStringAsFixed(1)}g (${(macros.carbs * CALORIES_PER_GRAM_CARBS).round()} kcal)
Protein: ${macros.protein.toStringAsFixed(1)}g (${(macros.protein * CALORIES_PER_GRAM_PROTEIN).round()} kcal)
Fat: ${macros.fat.toStringAsFixed(1)}g (${(macros.fat * CALORIES_PER_GRAM_FAT).round()} kcal)
Total Calories: ${macros.calories.round()} kcal
''');

    return macros;
  }

  static MacroProgress calculateMacroProgress(MacroTargets targets, MacroNutrients consumed) {
    // Add validation to ensure consumed values are non-negative
    final validatedConsumed = MacroNutrients(
      carbs: consumed.carbs.clamp(0, double.infinity),
      protein: consumed.protein.clamp(0, double.infinity),
      fat: consumed.fat.clamp(0, double.infinity),
    );

    final progress = MacroProgress(
      carbsConsumed: validatedConsumed.carbs,
      proteinConsumed: validatedConsumed.protein,
      fatConsumed: validatedConsumed.fat,
      carbsTarget: targets.carbs.toDouble(),
      proteinTarget: targets.protein.toDouble(),
      fatTarget: targets.fat.toDouble(),
    );

    // Debug logging
    developer.log('''
Macro Progress:
Carbs: ${progress.carbsConsumed}g / ${progress.carbsTarget}g (${progress.carbsPercentage * 100}%)
Protein: ${progress.proteinConsumed}g / ${progress.proteinTarget}g (${progress.proteinPercentage * 100}%)
Fat: ${progress.fatConsumed}g / ${progress.fatTarget}g (${progress.fatPercentage * 100}%)
''');

    return progress;
  }

  static bool validateMacroNutrients(MacroNutrients macros, double expectedCalories) {
    final calculatedCalories = macros.calories;
    final tolerance = expectedCalories * 0.05; // 5% tolerance

    return (calculatedCalories - expectedCalories).abs() <= tolerance;
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

class MacroTargets {
  final int carbs;
  final int protein;
  final int fat;

  MacroTargets({
    required this.carbs,
    required this.protein,
    required this.fat,
  });
}

class MacroProgress {
  final double carbsConsumed;
  final double proteinConsumed;
  final double fatConsumed;
  final double carbsTarget;
  final double proteinTarget;
  final double fatTarget;

  const MacroProgress({
    required this.carbsConsumed,
    required this.proteinConsumed,
    required this.fatConsumed,
    required this.carbsTarget,
    required this.proteinTarget,
    required this.fatTarget,
  });

  double get carbsRemaining => carbsTarget - carbsConsumed;
  double get proteinRemaining => proteinTarget - proteinConsumed;
  double get fatRemaining => fatTarget - fatConsumed;

  bool get isOverCarbs => carbsRemaining < 0;
  bool get isOverProtein => proteinRemaining < 0;
  bool get isOverFat => fatRemaining < 0;

  double get carbsPercentage => (carbsConsumed / carbsTarget).clamp(0.0, 1.0);
  double get proteinPercentage => (proteinConsumed / proteinTarget).clamp(0.0, 1.0);
  double get fatPercentage => (fatConsumed / fatTarget).clamp(0.0, 1.0);
}
