import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../fitness_app/fitness_app_theme.dart';
import '../widgets/animated_logo.dart';
import '../widgets/animated_background.dart';
import '../widgets/animated_form_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> with SingleTickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _ageController = TextEditingController();
  final _fitnessGoalController = TextEditingController();
  bool _isLoading = false;

  late AnimationController _formAnimationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  int _passwordStrength = 0;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _formAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _formAnimationController,
      curve: Curves.easeOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _formAnimationController,
      curve: Curves.easeIn,
    ));

    _formAnimationController.forward();
  }

  @override
  void dispose() {
    _formAnimationController.dispose();
    super.dispose();
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 8) return 'Password must be at least 8 characters';
    
    _passwordStrength = 0;
    if (value.contains(RegExp(r'[A-Z]'))) _passwordStrength++;
    if (value.contains(RegExp(r'[a-z]'))) _passwordStrength++;
    if (value.contains(RegExp(r'[0-9]'))) _passwordStrength++;
    if (value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) _passwordStrength++;
    
    return null;
  }

  Future<void> _handleRegister() async {
    if (_emailController.text.isEmpty || 
        _passwordController.text.isEmpty || 
        _nameController.text.isEmpty ||
        _heightController.text.isEmpty ||
        _weightController.text.isEmpty ||
        _ageController.text.isEmpty ||
        _fitnessGoalController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      print('Starting registration with:');
      print('Height: ${_heightController.text}');
      print('Weight: ${_weightController.text}');
      print('Age: ${_ageController.text}');
      print('Goal: ${_fitnessGoalController.text}');

      final user = await AuthService.createAccount(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        name: _nameController.text.trim(),
        height: double.tryParse(_heightController.text) ?? 0.0,
        weight: double.tryParse(_weightController.text) ?? 0.0,
        age: int.tryParse(_ageController.text) ?? 0,
        fitnessGoal: _fitnessGoalController.text.trim(),
      );
      
      print('User registered with ID: ${user.$id}');
      
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration successful! Please login.')),
        );
      }
    } catch (e) {
      print('Registration error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration failed: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  const Hero(
                    tag: 'app_logo',
                    child: Logo(
                      isDarkMode: true,
                      size: 200, // Increased from 120 to 200
                    ),
                  ),
                  const SizedBox(height: 30),
                  SlideTransition(
                    position: _slideAnimation,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: _buildRegistrationForm(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRegistrationForm() {
    return Container(
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
      child: Form(
        key: _formKey,
        child: ListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            AnimatedFormField(
              controller: _nameController,
              label: 'Name',
              icon: Icons.person,
              validator: (value) => value?.isEmpty ?? true ? 'Name is required' : null,
            ),
            const SizedBox(height: 16),
            AnimatedFormField(
              controller: _emailController,
              label: 'Email',
              icon: Icons.email,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Email is required';
                if (!value!.contains('@')) return 'Invalid email format';
                return null;
              },
            ),
            const SizedBox(height: 16),
            AnimatedFormField(
              controller: _passwordController,
              label: 'Password',
              icon: Icons.lock,
              isPassword: true,
              obscureText: _obscurePassword,
              onTogglePassword: () => setState(() => _obscurePassword = !_obscurePassword),
              validator: _validatePassword,
            ),
            if (_passwordController.text.isNotEmpty) ...[
              const SizedBox(height: 8),
              _buildPasswordStrengthIndicator(),
            ],
            const SizedBox(height: 16),
            AnimatedFormField(
              controller: _heightController,
              label: 'Height (cm)',
              icon: Icons.height,
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Height is required';
                final height = double.tryParse(value!);
                if (height == null || height <= 0) return 'Invalid height';
                return null;
              },
            ),
            const SizedBox(height: 16),
            AnimatedFormField(
              controller: _weightController,
              label: 'Weight (kg)',
              icon: Icons.fitness_center,
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Weight is required';
                final weight = double.tryParse(value!);
                if (weight == null || weight <= 0) return 'Invalid weight';
                return null;
              },
            ),
            const SizedBox(height: 16),
            AnimatedFormField(
              controller: _ageController,
              label: 'Age',
              icon: Icons.cake,
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Age is required';
                final age = int.tryParse(value!);
                if (age == null || age <= 0) return 'Invalid age';
                return null;
              },
            ),
            const SizedBox(height: 16),
            AnimatedFormField(
              controller: _fitnessGoalController,
              label: 'Fitness Goal',
              icon: Icons.flag,
              validator: (value) => value?.isEmpty ?? true ? 'Fitness Goal is required' : null,
            ),
            const SizedBox(height: 24),
            _buildRegisterButton(),
            const SizedBox(height: 16),
            _buildLoginLink(),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordStrengthIndicator() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Text(
          'Password Strength: ${['Very Weak', 'Weak', 'Medium', 'Strong', 'Very Strong'][_passwordStrength]}',
          style: TextStyle(
            color: _passwordStrength < 2 ? Colors.red : _passwordStrength < 4 ? Colors.orange : Colors.green,
          ),
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: (_passwordStrength + 1) / 5,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(
            _passwordStrength < 2 ? Colors.red : _passwordStrength < 4 ? Colors.orange : Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleRegister,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(),
              )
            : const Text(
                'Register',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Widget _buildLoginLink() {
    return TextButton(
      onPressed: () {
        Navigator.of(context).pushReplacementNamed('/login');
      },
      child: Text(
        'Already have an account? Login',
        style: TextStyle(
          //color: FitnessAppTheme.darkCharcoal,
          color: FitnessAppTheme.accentGold,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
