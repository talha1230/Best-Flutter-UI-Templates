// lib/services/user_service.dart
import 'package:appwrite/models.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'appwrite_service.dart';
import 'database_service.dart';

class UserService {
  static bool isLoggedIn = false;
  static String? _userId;
  static const String _userIdKey = 'userId';
  static const String _sessionKey = 'session';

  static String? get userId => _userId;

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
      isLoggedIn = prefs.getString(_sessionKey) != null;
      _userId = prefs.getString(_userIdKey);
    } catch (e) {
      currentUser = null;
    }
  }

  static Future<void> saveSession(Session session) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_sessionKey, session.toString());
      await prefs.setString(_userIdKey, session.userId);
      _userId = session.userId;
      isLoggedIn = true;
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
      await prefs.remove(_userIdKey);
      _userId = null;
      isLoggedIn = false;
      currentUser = null;
    } catch (e) {
      rethrow;
    }
  }
}