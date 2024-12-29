import 'package:flutter/material.dart';

class Logo extends StatelessWidget {
  final double size;
  final bool isDarkMode;
  
  const Logo({
    Key? key, 
    this.size = 200, // Changed default size from 120 to 200
    this.isDarkMode = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size,
      width: size * 1.8, // Increased multiplier from 1.5 to 1.8 for better aspect ratio
      child: isDarkMode 
          ? ColorFiltered(
              colorFilter: ColorFilter.mode(
                Colors.white.withOpacity(0.9),
                BlendMode.srcATop,
              ),
              child: Image.asset(
                'assets/fitness_app/logo.png',
                fit: BoxFit.contain,
              ),
            )
          : Image.asset(
              'assets/fitness_app/logo.png',
              fit: BoxFit.contain,
            ),
    );
  }
}
