import 'package:flutter/material.dart';

class BodyMeasurement {
  final double weight; // in kg
  final double height; // in cm
  final double? bodyFat;
  final DateTime timestamp;
  final String source; // 'manual' or 'smart_scale'

  BodyMeasurement({
    required this.weight,
    required this.height,
    this.bodyFat,
    required this.timestamp,
    required this.source,
  });

  double get bmi => weight / ((height / 100) * (height / 100));

  String get bmiCategory {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }

  Color getBmiColor() {
    if (bmi < 18.5) return Colors.orange;
    if (bmi < 25) return Colors.green;
    if (bmi < 30) return Colors.orange;
    return Colors.red;
  }

  bool isBodyFatHealthy(bool isMale) {
    if (bodyFat == null) return true;
    return isMale 
        ? bodyFat! >= 6 && bodyFat! <= 24
        : bodyFat! >= 14 && bodyFat! <= 31;
  }

  String getHealthyWeightRange() {
    double heightInMeters = height / 100;
    double minWeight = 18.5 * (heightInMeters * heightInMeters);
    double maxWeight = 24.9 * (heightInMeters * heightInMeters);
    return '${minWeight.toStringAsFixed(1)}-${maxWeight.toStringAsFixed(1)} kg';
  }

  String getHealthyWeightTarget() {
    double heightInMeters = height / 100;
    double idealWeight = 22 * (heightInMeters * heightInMeters); // middle of healthy BMI range
    return idealWeight.toStringAsFixed(1);
  }

  String getFeedbackMessage() {
    if (bmi < 18.5) {
      double targetWeight = 18.5 * ((height / 100) * (height / 100));
      return 'Try to gain ${(targetWeight - weight).toStringAsFixed(1)} kg for a healthy weight';
    } else if (bmi >= 25) {
      double targetWeight = 24.9 * ((height / 100) * (height / 100));
      return 'Try to lose ${(weight - targetWeight).toStringAsFixed(1)} kg for a healthy weight';
    }
    return 'Your weight is in the healthy range';
  }

  // Convert weight from lbs to kg
  static double lbsToKg(double lbs) => lbs * 0.453592;
  
  // Convert kg to lbs
  static double kgToLbs(double kg) => kg / 0.453592;
}
