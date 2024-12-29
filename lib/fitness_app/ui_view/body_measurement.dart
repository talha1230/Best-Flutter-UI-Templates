import 'package:flutter/material.dart';
import '../models/body_measurement.dart';
import '../../services/database_service.dart';
import '../../services/user_service.dart';
import '../fitness_app_theme.dart';

class BodyMeasurementView extends StatelessWidget {
  final AnimationController? animationController;
  final Animation<double>? animation;

  const BodyMeasurementView({Key? key, this.animationController, this.animation})
      : super(key: key);

  Widget _buildMeasurementValue(String value, String unit, String label, {Color? valueColor}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          '$value $unit',
          style: TextStyle(
            fontFamily: FitnessAppTheme.fontName,
            fontWeight: FontWeight.w500,
            fontSize: 16,
            letterSpacing: -0.2,
            color: valueColor ?? FitnessAppTheme.darkText,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: FitnessAppTheme.fontName,
              fontWeight: FontWeight.w600,
              fontSize: 12,
              color: FitnessAppTheme.grey.withOpacity(0.5),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: DatabaseService.getUserProfile(UserService.userId!),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final userData = snapshot.data!;
        final measurement = BodyMeasurement(
          weight: double.parse(userData['weight'].toString()),
          height: double.parse(userData['height'].toString()),
          bodyFat: userData['body_fat']?.toDouble(),
          timestamp: DateTime.now(),
          source: 'manual',
        );

        return AnimatedBuilder(
          animation: animationController!,
          builder: (context, child) {
            return FadeTransition(
              opacity: animation!,
              child: Transform(
                transform: Matrix4.translationValues(
                    0.0, 30 * (1.0 - animation!.value), 0.0),
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 24, right: 24, top: 16, bottom: 18),
                  child: Container(
                    decoration: BoxDecoration(
                      color: FitnessAppTheme.white,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(8.0),
                        bottomLeft: Radius.circular(8.0),
                        bottomRight: Radius.circular(8.0),
                        topRight: Radius.circular(68.0),
                      ),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: FitnessAppTheme.grey.withOpacity(0.2),
                          offset: const Offset(1.1, 1.1),
                          blurRadius: 10.0,
                        ),
                      ],
                    ),
                    child: Column(
                      children: <Widget>[
                        _buildWeightSection(measurement),
                        const Divider(),
                        _buildMetricsSection(measurement),
                        _buildFeedbackSection(measurement),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildWeightSection(BodyMeasurement measurement) {
    final weightLbs = BodyMeasurement.kgToLbs(measurement.weight);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${weightLbs.toStringAsFixed(1)} lbs',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${measurement.weight.toStringAsFixed(1)} kg',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Target: ${measurement.getHealthyWeightTarget()} kg',
                style: const TextStyle(color: Colors.blue),
              ),
              Text(
                'Last updated: ${_formatDate(measurement.timestamp)}',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsSection(BodyMeasurement measurement) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildMeasurementValue(
            measurement.height.toStringAsFixed(1),
            'cm',
            'Height',
          ),
          _buildMeasurementValue(
            measurement.bmi.toStringAsFixed(1),
            'BMI',
            measurement.bmiCategory,
            valueColor: measurement.getBmiColor(),
          ),
          if (measurement.bodyFat != null)
            _buildMeasurementValue(
              measurement.bodyFat!.toStringAsFixed(1),
              '%',
              'Body Fat',
              valueColor: measurement.isBodyFatHealthy(true) // TODO: Get actual gender
                  ? Colors.green
                  : Colors.red,
            ),
        ],
      ),
    );
  }

  Widget _buildFeedbackSection(BodyMeasurement measurement) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            measurement.getFeedbackMessage(),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Healthy weight range: ${measurement.getHealthyWeightRange()}',
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }
}
