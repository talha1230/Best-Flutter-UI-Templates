import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'appwrite_service.dart';
import 'user_service.dart';
import 'database_service.dart';

class AuthService {
  static Future<models.User> createAccount({
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

  static Future<models.Session> login({
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
      await clearLoginCredentials(); // Add this line to clear saved credentials
      await _clearAllStoredData(); // Add this new method call
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> _clearAllStoredData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clear all stored preferences
  }

  static Future<bool> hasValidSession() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionJson = prefs.getString('user_session');
    if (sessionJson != null) {
      try {
        final Map<String, dynamic> sessionMap = jsonDecode(sessionJson);
        final session = models.Session.fromMap(sessionMap);
        // Check if session is expired (24 hours)
        final createdAt = DateTime.parse(session.$createdAt);
        return DateTime.now().difference(createdAt).inHours < 24;
      } catch (e) {
        await prefs.remove('user_session');
      }
    }
    return false;
  }

  static Future<models.Session?> getLastSession() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionJson = prefs.getString('user_session');
    if (sessionJson != null) {
      try {
        final Map<String, dynamic> sessionMap = jsonDecode(sessionJson);
        return models.Session.fromMap(sessionMap);
      } catch (e) {
        await prefs.remove('user_session');
      }
    }
    return null;
  }

  static Future<void> saveLoginCredentials(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('saved_email', email);
    // Note: In production, you should use secure storage for passwords
    await prefs.setString('saved_password', base64Encode(utf8.encode(password)));
    await prefs.setBool('remember_me', true);
  }

  static Future<void> clearLoginCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('saved_email');
    await prefs.remove('saved_password');
    await prefs.remove('remember_me');
  }

  static Future<Map<String, String?>> getSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('saved_email');
    final encodedPassword = prefs.getString('saved_password');
    final password = encodedPassword != null 
        ? utf8.decode(base64Decode(encodedPassword)) 
        : null;

    return {
      'email': email,
      'password': password,
    };
  }

  static Future<bool> isRememberMeEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('remember_me') ?? false;
  }
}
