class MacroNutrients {
  static const double CALORIES_PER_GRAM_CARBS = 4.0;
  static const double CALORIES_PER_GRAM_PROTEIN = 4.0;
  static const double CALORIES_PER_GRAM_FAT = 9.0;

  final double carbs;
  final double protein;
  final double fat;

  MacroNutrients({
    required this.carbs,
    required this.protein,
    required this.fat,
  }) {
    if (carbs < 0 || protein < 0 || fat < 0) {
      throw ArgumentError('Macronutrient values cannot be negative');
    }
  }

  double get calories => 
    (carbs * CALORIES_PER_GRAM_CARBS) +
    (protein * CALORIES_PER_GRAM_PROTEIN) +
    (fat * CALORIES_PER_GRAM_FAT);

  MacroNutrients operator +(MacroNutrients other) => MacroNutrients(
    carbs: carbs + other.carbs,
    protein: protein + other.protein,
    fat: fat + other.fat,
  );

  @override
  String toString() => 
    'MacroNutrients(carbs: ${carbs.toStringAsFixed(1)}g, ' +
    'protein: ${protein.toStringAsFixed(1)}g, ' +
    'fat: ${fat.toStringAsFixed(1)}g, ' +
    'calories: ${calories.round()} kcal)';
}
