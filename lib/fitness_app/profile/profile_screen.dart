import 'package:flutter/material.dart';
import '../../../services/auth_service.dart';
import '../../../services/database_service.dart';
import '../../../services/user_service.dart';
import '../fitness_app_theme.dart';

class ProfileScreen extends StatelessWidget {
  double calculateBMI(double weight, double height) {
    // Convert height from cm to meters
    double heightInMeters = height / 100;
    return weight / (heightInMeters * heightInMeters);
  }

  String getBMIStatus(double bmi) {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }

  Widget _buildBMICard(double height, double weight) {
    final bmi = calculateBMI(weight, height);
    final status = getBMIStatus(bmi);
    final color = status == 'Normal' ? Colors.green 
                 : status == 'Underweight' ? Colors.orange
                 : Colors.red;

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'BMI Calculator',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your BMI: ${bmi.toStringAsFixed(1)}',
              style: TextStyle(fontSize: 24, color: color),
            ),
            Text(
              'Status: $status',
              style: TextStyle(fontSize: 18, color: color),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FitnessAppTheme.background,
      body: SafeArea(
        child: FutureBuilder<Map<String, dynamic>>(
          future: UserService.userId != null 
              ? DatabaseService.getUserProfile(UserService.userId!)
              : Future.error('User not logged in'),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              print('Profile Error: ${snapshot.error}'); // Debug print
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Error: ${snapshot.error}'),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pushReplacementNamed('/login'),
                      child: const Text('Return to Login'),
                    ),
                  ],
                ),
              );
            }

            final userData = snapshot.data!;
            final height = double.parse(userData['height'].toString());
            final weight = double.parse(userData['weight'].toString());

            return SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text('Profile', style: FitnessAppTheme.title),
                  ),
                  _buildBMICard(height, weight),
                  _buildProfileInfo('Name', userData['name']),
                  _buildProfileInfo('Email', userData['email']),
                  _buildProfileInfo('Height', '${height.toStringAsFixed(1)} cm'),
                  _buildProfileInfo('Weight', '${weight.toStringAsFixed(1)} kg'),
                  _buildProfileInfo('Age', '${userData['age']}'),
                  _buildProfileInfo('Fitness Goal', userData['fitness_goal']),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ElevatedButton(
                      onPressed: () => _showLogoutDialog(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: const Text('Logout', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildProfileInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        child: ListTile(
          title: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(value),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await AuthService.logout();
                if (context.mounted) {
                  Navigator.of(context).pushReplacementNamed('/login');
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Logout failed: ${e.toString()}')),
                  );
                }
              }
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
