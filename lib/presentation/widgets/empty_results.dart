// lib/presentation/widgets/empty_results.dart
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:lym_nutrition/presentation/themes/app_theme.dart';

class EmptyResults extends StatelessWidget {
  final String message;
  final String? submessage;
  final String? lottieAsset;
  final IconData? icon;
  final Color? color;
  final VoidCallback? onActionPressed;
  final String? actionLabel;

  const EmptyResults({
    Key? key,
    required this.message,
    this.submessage,
    this.lottieAsset,
    this.icon,
    this.color,
    this.onActionPressed,
    this.actionLabel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final iconColor = color ?? AppTheme.primaryColor;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (lottieAsset != null)
              Lottie.asset(lottieAsset!, width: 200, height: 200, repeat: true)
            else if (icon != null)
              Icon(icon, size: 80, color: iconColor.withOpacity(0.7)),

            const SizedBox(height: 24),

            Text(
              message,
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface.withOpacity(0.8),
              ),
              textAlign: TextAlign.center,
            ),

            if (submessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  submessage!,
                  style: textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

            if (onActionPressed != null && actionLabel != null)
              Padding(
                padding: const EdgeInsets.only(top: 24),
                child: ElevatedButton(
                  onPressed: onActionPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: iconColor,
                    foregroundColor: Colors.white,
                    elevation: 2,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  child: Text(actionLabel!),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
