import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'appwrite_service.dart';
import 'user_service.dart';
import 'database_service.dart';

class AuthService {
  static Future<User> createAccount({
    required String email,
    required String password,
    required String name,
    required double height,
    required double weight,
    required int age,
    required String fitnessGoal,
  }) async {
    try {
      final user = await AppwriteService.account.create(
        userId: ID.unique(),
        email: email,
        password: password,
        name: name,
      );

      print('Created auth user with ID: ${user.$id}'); // Debug print

      // Create user profile in database using the same ID
      await DatabaseService.createUserProfile(
        userId: user.$id, // Important: Use the same ID
        name: name,
        email: email,
        height: height,
        weight: weight,
        age: age,
        fitnessGoal: fitnessGoal,
      );

      return user;
    } catch (e) {
      print('Error in createAccount: $e'); // Debug print
      rethrow;
    }
  }

  static Future<Session> login({
    required String email,
    required String password,
  }) async {
    try {
      final session = await AppwriteService.account.createEmailSession(
        email: email,
        password: password,
      );
      return session;
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  static Future<void> logout() async {
    try {
      await AppwriteService.account.deleteSession(sessionId: 'current');
      await UserService.clearSession();
    } catch (e) {
      rethrow;
    }
  }
}
