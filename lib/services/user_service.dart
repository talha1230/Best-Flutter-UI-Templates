// lib/services/user_service.dart
import 'package:appwrite/models.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'appwrite_service.dart';
import 'database_service.dart';

class UserService {
  static const String _sessionKey = 'user_session';
  static User? currentUser;

  static Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hasSession = prefs.containsKey(_sessionKey);
      
      if (hasSession) {
        try {
          currentUser = await AppwriteService.account.get();
        } catch (e) {
          await clearSession();
        }
      }
    } catch (e) {
      currentUser = null;
    }
  }

  static Future<void> saveSession(Session session) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_sessionKey, session.userId);
      currentUser = await AppwriteService.account.get();
    } catch (e) {
      await clearSession();
      rethrow;
    }
  }

  static Future<void> clearSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_sessionKey);
      currentUser = null;
    } catch (e) {
      rethrow;
    }
  }

  static bool get isLoggedIn => currentUser != null;
}