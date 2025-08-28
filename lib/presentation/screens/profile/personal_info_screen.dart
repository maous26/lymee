import 'package:flutter/material.dart';
import 'package:lym_nutrition/presentation/themes/enhanced_theme.dart';

class PersonalInfoScreen extends StatelessWidget {
  const PersonalInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Informations personnelles'),
        backgroundColor: EnhancedTheme.primaryTeal,
        foregroundColor: EnhancedTheme.neutralWhite,
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.person,
                size: 80,
                color: EnhancedTheme.primaryTeal,
              ),
              SizedBox(height: 24),
              Text(
                'Informations personnelles',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: EnhancedTheme.neutralGray800,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Cette section sera bientôt disponible pour gérer vos informations personnelles.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: EnhancedTheme.neutralGray600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
