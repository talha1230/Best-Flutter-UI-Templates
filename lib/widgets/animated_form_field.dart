import 'package:flutter/material.dart';
import '../fitness_app/fitness_app_theme.dart';

class AnimatedFormField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool isPassword;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final bool obscureText;
  final VoidCallback? onTogglePassword;

  const AnimatedFormField({
    Key? key,
    required this.controller,
    required this.label,
    required this.icon,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.obscureText = false,
    this.onTogglePassword,
  }) : super(key: key);

  @override
  State<AnimatedFormField> createState() => _AnimatedFormFieldState();
}

class _AnimatedFormFieldState extends State<AnimatedFormField> 
    with SingleTickerProviderStateMixin {
  late AnimationController _focusController;
  late Animation<double> _focusAnimation;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _focusAnimation = Tween<double>(begin: 0, end: 1).animate(_focusController);
  }

  @override
  void dispose() {
    _focusController.dispose();
    super.dispose();
  }

  void _handleFocusChange(bool hasFocus) {
    setState(() => _isFocused = hasFocus);
    if (hasFocus) {
      _focusController.forward();
    } else {
      _focusController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _focusAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: FitnessAppTheme.primaryGold.withOpacity(0.1 * _focusAnimation.value),
                blurRadius: 8 * _focusAnimation.value,
                offset: Offset(0, 2 * _focusAnimation.value),
              ),
            ],
          ),
          child: Focus(
            onFocusChange: _handleFocusChange,
            child: TextFormField(
              controller: widget.controller,
              obscureText: widget.isPassword && widget.obscureText,
              keyboardType: widget.keyboardType,
              validator: widget.validator,
              style: const TextStyle(color: FitnessAppTheme.darkCharcoal),
              decoration: InputDecoration(
                labelText: widget.label,
                prefixIcon: Icon(
                  widget.icon,
                  color: _isFocused 
                      ? FitnessAppTheme.primaryGold 
                      : FitnessAppTheme.darkCharcoal.withOpacity(0.7),
                ),
                suffixIcon: widget.isPassword
                    ? IconButton(
                        icon: Icon(
                          widget.obscureText 
                              ? Icons.visibility_off 
                              : Icons.visibility,
                        ),
                        onPressed: widget.onTogglePassword,
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: FitnessAppTheme.darkCharcoal.withOpacity(0.3),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: FitnessAppTheme.primaryGold,
                    width: 2,
                  ),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),
        );
      },
    );
  }
}
