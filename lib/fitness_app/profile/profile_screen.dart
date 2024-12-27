import 'package:flutter/material.dart';
import '../fitness_app_theme.dart';
import '../../services/auth_service.dart';
import '../../services/appwrite_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final double _topHeight = 240.0;
  
  @override
  Widget build(BuildContext context) {
    return Container(
      color: FitnessAppTheme.background,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: <Widget>[
            _buildProfileContent(),
            _buildTopBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return SizedBox(
      height: _topHeight,
      child: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  FitnessAppTheme.nearlyDarkBlue,
                  FitnessAppTheme.nearlyBlue,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(32.0),
                bottomRight: Radius.circular(32.0),
              ),
            ),
          ),
          Positioned(
            top: 40,
            left: 0,
            right: 0,
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 60, color: FitnessAppTheme.nearlyBlue),
                ),
                const SizedBox(height: 10),
                Text(
                  'John Doe',
                  style: TextStyle(
                    color: FitnessAppTheme.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileContent() {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          SizedBox(height: _topHeight - 30),
          Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: <Widget>[
                _buildProfileCard(
                  'Personal Information',
                  [
                    _buildInfoRow('Email', 'john.doe@example.com'),
                    _buildInfoRow('Height', '175 cm'),
                    _buildInfoRow('Weight', '70 kg'),
                    _buildInfoRow('Age', '28'),
                  ],
                ),
                const SizedBox(height: 16),
                _buildProfileCard(
                  'Fitness Goals',
                  [
                    _buildInfoRow('Target Weight', '65 kg'),
                    _buildInfoRow('Weekly Goal', '3 workouts'),
                    _buildInfoRow('Daily Steps', '10,000'),
                  ],
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    await AuthService.logout();
                    Navigator.of(context).pushReplacementNamed('/login');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  ),
                  child: const Text('Logout'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard(String title, List<Widget> children) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: FitnessAppTheme.nearlyDarkBlue,
              ),
            ),
            const Divider(),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: FitnessAppTheme.grey,
              fontSize: 16,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: FitnessAppTheme.darkText,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
