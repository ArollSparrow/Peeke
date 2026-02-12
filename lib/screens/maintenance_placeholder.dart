// lib/screens/maintenance/maintenance_placeholder.dart
// Placeholder screen for all Maintenance features - to be implemented

import 'package:flutter/material.dart';
import '../../utils/app_utils.dart';

class MaintenancePlaceholder extends StatelessWidget {
  final String featureName;

  const MaintenancePlaceholder({
    Key? key,
    required this.featureName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(featureName),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.build,
                size: 100,
                color: AppColors.accent.withOpacity(0.5),
              ),
              const SizedBox(height: 24),
              Text(
                featureName,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.accent,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Coming Soon',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'This maintenance feature is currently under development.\nIt will be available in the next update.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.5),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.black,
                ),
                child: const Text('Back to Menu'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
