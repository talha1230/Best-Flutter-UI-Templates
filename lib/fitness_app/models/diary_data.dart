import 'macro_nutrients.dart';

class DiaryData {
  double eatenCalories;
  double burnedCalories;
  double totalCalorieGoal;
  int waterIntake;
  int waterGoal;
  List<Meal> meals;
  double weight;
  double height;
  MacroNutrients macros;
  final bool isMale;

  DiaryData({
    this.eatenCalories = 0,
    this.burnedCalories = 0,
    this.totalCalorieGoal = 2000,
    this.waterIntake = 0,
    this.waterGoal = 8,
    List<Meal>? meals,
    this.weight = 0,
    this.height = 0,
    MacroNutrients? macros,
    this.isMale = true,
  }) : this.meals = meals ?? [],
       this.macros = macros ?? MacroNutrients(carbs: 0, protein: 0, fat: 0);

  double get remainingCalories => totalCalorieGoal - eatenCalories;
  double get bmi => weight / ((height / 100) * (height / 100));
}

class Meal {
  final String id;
  final String name;
  final double calories;
  final MacroNutrients macros;
  final DateTime time;
  final MealStatus status;
  final String? reason;

  Meal({
    required this.id,
    required this.name,
    required this.calories,
    required this.macros,
    required this.time,
    this.status = MealStatus.pending,
    this.reason,
  });
}

enum MealStatus {
  pending,
  consumed,
  skipped
}
