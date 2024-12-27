import 'package:flutter/material.dart';
import 'database_service.dart';
import 'user_service.dart';

class UserDataProvider extends ChangeNotifier {
  Map<String, dynamic>? _userData;
  bool _isLoading = false;

  Map<String, dynamic>? get userData => _userData;
  bool get isLoading => _isLoading;

  Future<void> loadUserData() async {
    if (UserService.userId == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      _userData = await DatabaseService.getUserProfile(UserService.userId!);
    } catch (e) {
      print('Error loading user data: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateUserData(Map<String, dynamic> newData) async {
    if (UserService.userId == null) return;

    try {
      await DatabaseService.updateUserProfile(
        userId: UserService.userId!,
        profileData: newData,
      );
      await loadUserData();
    } catch (e) {
      print('Error updating user data: $e');
    }
  }
}
