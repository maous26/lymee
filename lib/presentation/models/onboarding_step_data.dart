// lib/presentation/models/onboarding_step_data.dart
import 'package:flutter/material.dart';

class OnboardingStepData {
  final String title;
  final String subtitle;
  final String emoji;
  final IconData icon;
  final Color primaryColor;

  const OnboardingStepData({
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.icon,
    required this.primaryColor,
  });
}
