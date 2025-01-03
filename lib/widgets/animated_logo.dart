import 'package:flutter/material.dart';

class Logo extends StatelessWidget {
  final bool isDarkMode;
  final double size;
  
  const Logo({
    super.key,
    this.isDarkMode = false,
    this.size = 120,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size / 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Image.asset(
        'assets/fitness_app/logo.png',  // Updated path to match pubspec.yaml
        fit: BoxFit.contain,
      ),
    );
  }
}
