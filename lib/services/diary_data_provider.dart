import 'package:flutter/material.dart';
import '../fitness_app/models/diary_data.dart';
import 'database_service.dart';
import 'user_service.dart';
import 'package:appwrite/models.dart';
import '../fitness_app/models/macro_nutrients.dart';

class DiaryDataProvider extends ChangeNotifier {
  DiaryData _diaryData = DiaryData();
  bool _isLoading = false;
  String? _error;
  bool _initialized = false;

  DiaryData get diaryData => _diaryData;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get initialized => _initialized;

  Future<void> loadDiaryData() async {
    if (UserService.userId == null) return;
    if (_isLoading) return;  // Prevent multiple simultaneous loads

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final userData = await DatabaseService.getUserProfile(UserService.userId!);
      final userMeals = await DatabaseService.getUserMeals(
        UserService.userId!,
        date: DateTime.now(),
      ) as List<Meal>;  // Add type cast

      _diaryData = DiaryData(
        weight: double.parse(userData['weight'].toString()),
        height: double.parse(userData['height'].toString()),
        waterIntake: int.parse(userData['water_intake'].toString()),
        waterGoal: int.parse(userData['water_goal'].toString()),
        meals: userMeals,
        eatenCalories: userMeals.fold<double>(0, (sum, Meal meal) => sum + meal.calories),  // Add type
        macros: _calculateTotalMacros(userMeals),
      );
      
      _initialized = true;
      _error = null;
    } catch (e) {
      print('Error loading diary data: $e');
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addMeal(Meal meal) async {
    try {
      // Save to database first and get the ID
      final mealId = await DatabaseService.saveMeal(UserService.userId!, meal);

      // Create a new meal with the ID
      final savedMeal = Meal(
        id: mealId,
        name: meal.name,
        calories: meal.calories,
        macros: meal.macros,
        time: meal.time,
        status: meal.status,
        reason: meal.reason,
      );

      // If successful, update local state
      if (_diaryData.meals == null) {
        _diaryData.meals = [];
      }
      _diaryData.meals.add(savedMeal);
      _diaryData.eatenCalories += savedMeal.calories;
      
      // Update macros by creating a new instance
      _diaryData.macros = _diaryData.macros + savedMeal.macros;
      
      notifyListeners();
    } catch (e) {
      print('Error adding meal: $e');
      rethrow;
    }
  }

  Future<void> updateMeal(String mealId, Meal updatedMeal) async {
    try {
      if (UserService.userId == null) throw Exception('User not logged in');
      
      await DatabaseService.updateMeal(
        userId: UserService.userId!,
        mealId: mealId,
        meal: updatedMeal,
      );
      
      final index = _diaryData.meals.indexWhere((m) => m.id == mealId);
      if (index != -1) {
        _diaryData.meals[index] = updatedMeal;
        _updateTotals();
        notifyListeners();
      }
    } catch (e) {
      print('Error updating meal: $e');
      rethrow;
    }
  }

  Future<void> deleteMeal(String mealId) async {
    try {
      // Remove from local state first
      final mealIndex = _diaryData.meals.indexWhere((m) => m.id == mealId);
      if (mealIndex == -1) {
        throw Exception('Meal not found in local state');
      }
      
      final deletedMeal = _diaryData.meals[mealIndex];
      
      // Try to delete from database first
      try {
        await DatabaseService.deleteMeal(mealId);
        // If successful, update local state
        _diaryData.meals.removeAt(mealIndex);
        _updateTotals();
        notifyListeners();
      } catch (e) {
        print('Error deleting meal from database: $e');
        throw Exception('Failed to delete meal: $e');
      }
    } catch (e) {
      print('Error in deleteMeal: $e');
      rethrow;
    }
  }

  void _updateTotals() {
    // Calculate total calories from consumed meals
    _diaryData.eatenCalories = _diaryData.meals
        .where((m) => m.status == MealStatus.consumed)
        .fold<double>(0, (sum, meal) => sum + meal.calories);
        
    // Calculate total macros from consumed meals
    _diaryData.macros = _diaryData.meals
        .where((m) => m.status == MealStatus.consumed)
        .fold<MacroNutrients>(
          MacroNutrients(carbs: 0, protein: 0, fat: 0), // Fixed: Added required parameters
          (sum, meal) => sum + meal.macros,
        );
  }

  Future<void> updateWaterIntake(int glasses) async {
    if (glasses < 0) {
      print('Cannot set negative water intake');
      return;
    }

    if (glasses > _diaryData.waterGoal) {
      print('Cannot exceed water intake goal of ${_diaryData.waterGoal} glasses');
      return;
    }

    try {
      // Update database first
      await DatabaseService.updateUserProfile(
        userId: UserService.userId!,
        profileData: {
          'water_intake': glasses,
        },
      );

      // If successful, update local state
      _diaryData.waterIntake = glasses;
      notifyListeners();
    } catch (e) {
      print('Error updating water intake: $e');
      // Show error message to user
      throw Exception('Failed to update water intake');
    }
  }

  Future<void> updateWaterGoal(int newGoal) async {
    if (newGoal <= 0) {
      print('Water goal must be positive');
      return;
    }

    try {
      await DatabaseService.updateUserProfile(
        userId: UserService.userId!,
        profileData: {
          'water_goal': newGoal,
        },
      );

      _diaryData.waterGoal = newGoal;
      if (_diaryData.waterIntake > newGoal) {
        await updateWaterIntake(newGoal);
      }
      notifyListeners();
    } catch (e) {
      print('Error updating water goal: $e');
      throw Exception('Failed to update water goal');
    }
  }

  Future<void> updateCaloriesBurned(double calories) async {
    _diaryData.burnedCalories = calories;
    notifyListeners();
    await _saveDiaryData();
  }

  Future<void> _saveDiaryData() async {
    if (UserService.userId == null) return;

    try {
      await DatabaseService.updateUserProfile(
        userId: UserService.userId!,
        profileData: {
          'water_intake': _diaryData.waterIntake,
          // Add other fields only after adding them to Appwrite collection
        },
      );
    } catch (e) {
      print('Error saving diary data: $e');
    }
  }

  void reset() {
    _diaryData = DiaryData(
      macros: MacroNutrients(carbs: 0, protein: 0, fat: 0), // Fixed: Added required parameters
      // ...other parameters...
    );
    _initialized = false;
    _isLoading = false;
    _error = null;
    notifyListeners();
  }

  MacroNutrients _calculateTotalMacros(List<Meal> userMeals) {
    return userMeals.fold<MacroNutrients>(
      MacroNutrients(carbs: 0, protein: 0, fat: 0), // Fixed: Added required parameters
      (sum, meal) => sum + meal.macros,
    );
  }
}
