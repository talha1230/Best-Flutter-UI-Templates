import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';  // Add this import
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../services/diary_data_provider.dart';
import '../fitness_app/fitness_app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    // Add delay to prevent immediate auto-login
    Future.delayed(Duration.zero, _initializeLogin);
  }

  Future<void> _initializeLogin() async {
    // Only attempt auto-login if not already logged out
    final prefs = await SharedPreferences.getInstance();
    final wasLoggedOut = prefs.getBool('manually_logged_out') ?? false;
    
    if (!wasLoggedOut) {
      await _loadSavedCredentials();
    } else {
      // Clear the flag
      await prefs.remove('manually_logged_out');
    }
  }

  Future<void> _loadSavedCredentials() async {
    final credentials = await AuthService.getSavedCredentials();
    final rememberMe = await AuthService.isRememberMeEnabled();
    
    if (mounted && credentials['email'] != null && credentials['password'] != null) {
      setState(() {
        _emailController.text = credentials['email']!;
        _passwordController.text = credentials['password']!;
        _rememberMe = rememberMe;
      });
      
      if (rememberMe) {
        _handleLogin(); // Auto login if remember me was enabled
      }
    }
  }

  Future<void> _handleLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final session = await AuthService.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      
      if (_rememberMe) {
        await AuthService.saveLoginCredentials(
          _emailController.text.trim(),
          _passwordController.text,
        );
      } else {
        await AuthService.clearLoginCredentials();
      }

      await UserService.saveSession(session);

      if (mounted) {
        // Initialize diary data (including water intake) after successful login
        await context.read<DiaryDataProvider>().loadDiaryData();
        
        // Show loading indicator while data is being loaded
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Loading your data...')),
        );

        // Navigate to home screen
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login failed: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              FitnessAppTheme.darkCharcoal,
              FitnessAppTheme.lightCharcoal,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  Image.asset(
                    'assets/fitness_app/bacmy2024.png',
                    height: 120,
                  ),
                  const SizedBox(height: 40),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: FitnessAppTheme.primaryGold.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildTextField(_emailController, 'Email', Icons.email, isEmail: true),
                        const SizedBox(height: 16),
                        _buildTextField(_passwordController, 'Password', Icons.lock, isPassword: true),
                        const SizedBox(height: 8),
                        _buildRememberMeSwitch(),
                        const SizedBox(height: 24),
                        _buildLoginButton(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildRegisterLink(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRememberMeSwitch() {
    return Row(
      children: [
        Switch(
          value: _rememberMe,
          onChanged: (value) => setState(() => _rememberMe = value),
          activeColor: FitnessAppTheme.primaryGold,
        ),
        const Text(
          'Remember me',
          style: TextStyle(color: FitnessAppTheme.darkCharcoal),
        ),
      ],
    );
  }

  Widget _buildRegisterLink() {
    return TextButton(
      onPressed: () => Navigator.of(context).pushNamed('/register'),
      child: Text(
        'Don\'t have an account? Register',
        style: TextStyle(
          color: FitnessAppTheme.accentGold,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  // Update the login button style
  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: FitnessAppTheme.primaryGold,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 5,
        ),
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                'Login',
                style: TextStyle(
                  color: FitnessAppTheme.darkCharcoal,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool isPassword = false,
    bool isEmail = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
      style: const TextStyle(color: FitnessAppTheme.nearlyDarkBlue),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: FitnessAppTheme.nearlyDarkBlue),
        labelText: label,
        labelStyle: TextStyle(color: FitnessAppTheme.nearlyDarkBlue.withOpacity(0.8)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: FitnessAppTheme.nearlyDarkBlue.withOpacity(0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: FitnessAppTheme.nearlyDarkBlue, width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}
