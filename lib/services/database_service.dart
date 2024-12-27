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
      final document = await AppwriteService.databases.getDocument(
        databaseId: AppwriteService.databaseId,
        collectionId: AppwriteService.userCollectionId,
        documentId: userId,
      );
      return document.data;
    } catch (e) {
      rethrow;
    }
  }
}
