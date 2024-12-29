
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/user_service.dart';
import 'services/diary_data_provider.dart';

class LogoutButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () async {
        await UserService.logout();
        context.read<DiaryDataProvider>().reset();  // Add this line
        Navigator.pushReplacementNamed(context, '/login');
      },
      icon: Icon(Icons.logout),
    );
  }
}