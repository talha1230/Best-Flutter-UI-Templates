import 'package:appwrite/appwrite.dart';
import 'appwrite_service.dart';

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
      await AppwriteService.databases.updateDocument(
        databaseId: AppwriteService.databaseId,
        collectionId: AppwriteService.userCollectionId,
        documentId: userId,
        data: profileData,
      );
    } catch (e) {
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
          'height': document.data['height'],
          'weight': document.data['weight'],
          'age': document.data['age'],
          'fitness_goal': document.data['fitness_goal'],
        };
      } catch (e) {
        print('Error fetching document: $e');
        return {
          'name': user.name,
          'email': user.email,
          'height': 0.0,
          'weight': 0.0,
          'age': 0,
          'fitness_goal': 'Not set',
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
}
