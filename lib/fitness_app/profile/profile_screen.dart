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
      appBar: AppBar(
        title: Text('Profile', style: FitnessAppTheme.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            onPressed: () => _showLogoutDialog(context),
          ),
        ],
        elevation: 0,
        backgroundColor: FitnessAppTheme.background,
      ),
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
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: FitnessAppTheme.nearlyDarkBlue,
                    child: Text(
                      userData['name'][0].toUpperCase(),
                      style: const TextStyle(fontSize: 40, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    userData['name'],
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    userData['email'],
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildBMICard(height, weight),
                  Container(
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 10,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildProfileInfoNew('Height', '${height.toStringAsFixed(1)} cm', Icons.height),
                        _buildDivider(),
                        _buildProfileInfoNew('Weight', '${weight.toStringAsFixed(1)} kg', Icons.monitor_weight),
                        _buildDivider(),
                        _buildProfileInfoNew('Age', '${userData['age']}', Icons.calendar_today),
                        _buildDivider(),
                        _buildProfileInfoNew('Goal', userData['fitness_goal'], Icons.flag),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20), // Bottom padding for navigation bar
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildProfileInfoNew(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: FitnessAppTheme.nearlyDarkBlue, size: 24),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: Colors.grey[200],
      indent: 56,
      endIndent: 16,
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
