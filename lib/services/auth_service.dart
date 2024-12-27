import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'appwrite_service.dart';
import 'user_service.dart';

class AuthService {
  static Future<User> createAccount({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final user = await AppwriteService.account.create(
        userId: ID.unique(),
        email: email,
        password: password,
        name: name,
      );
      return user;
    } catch (e) {
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
      rethrow;
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
