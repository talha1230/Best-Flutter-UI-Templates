class DiaryData {
  double eatenCalories;
  double burnedCalories;
  double totalCalorieGoal;
  int waterIntake;
  int waterGoal;
  List<Meal> meals;  // Changed from const [] to []
  double weight;
  double height;
  MacroNutrients macros;
  final bool isMale; // Add this property

  DiaryData({
    this.eatenCalories = 0,
    this.burnedCalories = 0,
    this.totalCalorieGoal = 2000,
    this.waterIntake = 0,
    this.waterGoal = 8,
    List<Meal>? meals,  // Make meals optional
    this.weight = 0,
    this.height = 0,
    MacroNutrients? macros,
    this.isMale = true, // Default to male for now
  }) : this.meals = meals ?? [],  // Initialize as empty mutable list
       this.macros = macros ?? MacroNutrients();

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

// Add this enum
enum MealStatus {
  pending,
  consumed,
  skipped
}

class MacroNutrients {
  double carbs;
  double protein;
  double fat;

  MacroNutrients({
    this.carbs = 0,
    this.protein = 0,
    this.fat = 0,
  });
}
