import 'package:appwrite/appwrite.dart';
import 'appwrite_service.dart';
import '../fitness_app/models/diary_data.dart';  // Add this import

class DatabaseService {
  static Future<void> createWorkout({
    required String userId,
    required String workoutName,
    required List<String> exercises,
    required DateTime date,
  }) async {
    try {
      await AppwriteService.databases.createDocument(
        databaseId: AppwriteService.databaseId,
        collectionId: AppwriteService.workoutCollectionId,
        documentId: ID.unique(),
        data: {
          'user_id': userId,
          'workout_name': workoutName,
          'exercises': exercises,
          'date': date.toIso8601String(),
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> createMealPlan({
    required String userId,
    required String mealName,
    required int calories,
    required DateTime date,
  }) async {
    try {
      await AppwriteService.databases.createDocument(
        databaseId: AppwriteService.databaseId,
        collectionId: AppwriteService.mealsCollectionId,
        documentId: ID.unique(),
        data: {
          'user_id': userId,
          'meal_name': mealName,
          'calories': calories,
          'date': date.toIso8601String(),
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> updateUserProfile({
    required String userId,
    required Map<String, dynamic> profileData,
  }) async {
    try {
      print('Updating profile with data: $profileData');
      
      // Only include fields that exist in the Appwrite collection
      final validData = {
        if (profileData.containsKey('water_intake')) 
          'water_intake': profileData['water_intake'],
        if (profileData.containsKey('height')) 
          'height': profileData['height'],
        if (profileData.containsKey('weight')) 
          'weight': profileData['weight'],
        if (profileData.containsKey('age')) 
          'age': profileData['age'],
        if (profileData.containsKey('fitness_goal')) 
          'fitness_goal': profileData['fitness_goal'],
        if (profileData.containsKey('gender')) 
          'gender': profileData['gender'],
        if (profileData.containsKey('activityLevel')) 
          'activityLevel': profileData['activityLevel'],
        if (profileData.containsKey('goal')) 
          'goal': profileData['goal'],
      };

      print('Filtered valid data to update: $validData');

      await AppwriteService.databases.updateDocument(
        databaseId: AppwriteService.databaseId,
        collectionId: AppwriteService.userCollectionId,
        documentId: userId,
        data: validData,
      );
    } catch (e) {
      print('Error updating profile: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> getUserProfile(String userId) async {
    try {
      print('==== Getting User Profile ====');
      print('User ID: $userId');
      
      // Get auth user data
      final user = await AppwriteService.account.get();
      print('Auth user data: ${user.name}, ${user.email}');
      
      try {
        final document = await AppwriteService.databases.getDocument(
          databaseId: AppwriteService.databaseId,
          collectionId: AppwriteService.userCollectionId,
          documentId: userId,
        );
        
        print('Found database document: ${document.data}');
        
        return {
          'name': user.name,
          'email': user.email,
          'height': document.data['height'] ?? 0.0,
          'weight': document.data['weight'] ?? 0.0,
          'age': document.data['age'] ?? 0,
          'fitness_goal': document.data['fitness_goal'] ?? 'Not set',
          'water_intake': document.data['water_intake'] ?? 0,
          'water_goal': document.data['water_goal'] ?? 8,
        };
      } catch (e) {
        // If no document exists, create one with default values
        final defaultData = {
          'water_intake': 0,
          'water_goal': 8,
          'height': 0.0,
          'weight': 0.0,
          'age': 0,
          'fitness_goal': 'Not set',
        };
        
        await updateUserProfile(userId: userId, profileData: defaultData);
        return {
          'name': user.name,
          'email': user.email,
          ...defaultData,
        };
      }
    } catch (e) {
      print('Error in getUserProfile: $e');
      rethrow;
    }
  }

  static Future<void> createUserProfile({
    required String userId,
    required String name,
    required String email,
    required double height,
    required double weight,
    required int age,
    required String fitnessGoal,
  }) async {
    try {
      print('==== Creating User Profile ====');
      print('Database ID: ${AppwriteService.databaseId}');
      print('Collection ID: ${AppwriteService.userCollectionId}');
      print('User ID: $userId');
      print('Height: $height');
      print('Weight: $weight');
      print('Age: $age');
      print('Goal: $fitnessGoal');
      
      final data = {
        'height': height,
        'weight': weight,
        'age': age,
        'fitness_goal': fitnessGoal,
      };
      
      print('Data to be stored: $data');
      
      final result = await AppwriteService.databases.createDocument(
        databaseId: AppwriteService.databaseId,
        collectionId: AppwriteService.userCollectionId,
        documentId: userId,
        data: data,
      );
      
      print('Document created successfully');
      print('Created document data: ${result.data}');
    } catch (e) {
      print('Error creating profile: $e');
      print('Stack trace: ${StackTrace.current}');
      rethrow;
    }
  }

  static Future<String> saveMeal(String userId, Meal meal) async {
    try {
      print('Saving meal to collection: ${AppwriteService.mealsCollectionId}');
      
      final data = {
        'user_id': userId,
        'name': meal.name,
        'calories': meal.calories,
        'carbs': meal.macros.carbs,
        'protein': meal.macros.protein,
        'fat': meal.macros.fat,
        'time_hour': meal.time.hour,
        'time_minute': meal.time.minute,
        'date': formatDateForDb(meal.time),
        'status': meal.status.name,  // Add this
        'reason': meal.reason,       // Add this
      };
      
      print('Attempting to save meal data: $data');

      final result = await AppwriteService.databases.createDocument(
        databaseId: AppwriteService.databaseId,
        collectionId: AppwriteService.mealsCollectionId,
        documentId: ID.unique(),
        data: data,
      );

      print('Meal saved successfully: ${result.$id}');
      return result.$id; // Return the document ID
    } catch (e) {
      print('Error saving meal: $e');
      rethrow;
    }
  }

  static String formatDateForDb(DateTime date) {
    return date.toIso8601String().split('T')[0];
  }

  static Future<void> updateMeal({
    required String userId,
    required String mealId,
    required Meal meal,
  }) async {
    try {
      print('Updating meal with ID: $mealId');
      final data = {
        'user_id': userId,
        'name': meal.name,
        'calories': meal.calories,
        'carbs': meal.macros.carbs,
        'protein': meal.macros.protein,
        'fat': meal.macros.fat,
        'time_hour': meal.time.hour,
        'time_minute': meal.time.minute,
        'date': formatDateForDb(meal.time),
        'status': meal.status.name,
        'reason': meal.reason,
      };

      print('Attempting to update meal with data: $data');

      await AppwriteService.databases.updateDocument(
        databaseId: AppwriteService.databaseId,
        collectionId: AppwriteService.mealsCollectionId,
        documentId: mealId,
        data: data,
      );
      
      print('Meal updated successfully');
    } catch (e) {
      print('Error updating meal in database: $e');
      rethrow;
    }
  }

  static Future<void> deleteMeal(String mealId) async {
    try {
      print('Attempting to delete meal with ID: $mealId');
      print('Using database ID: ${AppwriteService.databaseId}');
      print('Using collection ID: ${AppwriteService.mealsCollectionId}');

      // First verify the document exists
      try {
        await AppwriteService.databases.getDocument(
          databaseId: AppwriteService.databaseId,
          collectionId: AppwriteService.mealsCollectionId,
          documentId: mealId,
        );
      } catch (e) {
        print('Error checking meal existence: $e');
        if (e is AppwriteException && e.code == 404) {
          throw Exception('Meal not found');
        }
        rethrow;
      }

      // Then delete it
      await AppwriteService.databases.deleteDocument(
        databaseId: AppwriteService.databaseId,
        collectionId: AppwriteService.mealsCollectionId,
        documentId: mealId,
      );
      
      print('Successfully deleted meal');
    } catch (e) {
      print('Error deleting meal: $e');
      if (e is AppwriteException) {
        throw Exception('Failed to delete meal: ${e.message}');
      }
      rethrow;
    }
  }

  static Future<List<Meal>> getUserMeals(String userId, {DateTime? date}) async {
    try {
      print('Fetching meals for user: $userId');
      if (date != null) {
        print('Filtering by date: ${date.toIso8601String().split('T')[0]}');
      }

      final queries = [
        Query.equal('user_id', userId),
      ];
      
      if (date != null) {
        queries.add(Query.equal('date', date.toIso8601String().split('T')[0]));
      }

      final response = await AppwriteService.databases.listDocuments(
        databaseId: AppwriteService.databaseId,
        collectionId: AppwriteService.mealsCollectionId,
        queries: queries,
      );

      print('Found ${response.documents.length} meals');
      return response.documents.map((doc) {
        final mealTime = DateTime(
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day,
          doc.data['time_hour'],
          doc.data['time_minute'],
        );
        
        return Meal(
          id: doc.$id,
          name: doc.data['name'],
          calories: doc.data['calories'].toDouble(),
          macros: MacroNutrients(
            carbs: doc.data['carbs'].toDouble(),
            protein: doc.data['protein'].toDouble(),
            fat: doc.data['fat'].toDouble(),
          ),
          time: mealTime,
          status: MealStatus.values.firstWhere(
            (s) => s.name == (doc.data['status'] ?? 'pending'),
            orElse: () => MealStatus.pending,
          ),
          reason: doc.data['reason'],
        );
      }).toList();
    } catch (e, stackTrace) {
      print('Error getting meals: $e');
      print('Stack trace: $stackTrace');
      return [];
    }
  }
}
