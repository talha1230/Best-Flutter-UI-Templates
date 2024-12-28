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
  }) : this.meals = meals ?? [],  // Initialize as empty mutable list
       this.macros = macros ?? MacroNutrients();

  double get remainingCalories => totalCalorieGoal - eatenCalories;
  double get bmi => weight / ((height / 100) * (height / 100));
}

class Meal {
  String id;  // Add this
  String name;
  double calories;
  MacroNutrients macros;
  DateTime time;
  MealStatus status;  // Add this
  String? reason;     // Add this

  Meal({
    this.id = '',    // Add this
    required this.name,
    required this.calories,
    required this.macros,
    required this.time,
    this.status = MealStatus.pending,  // Add this
    this.reason,                       // Add this
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
