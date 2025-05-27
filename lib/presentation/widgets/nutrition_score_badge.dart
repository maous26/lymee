import 'package:flutter/material.dart';
import 'package:lym_nutrition/presentation/themes/app_theme.dart';

class NutritionScoreBadge extends StatelessWidget {
  final double score;
  final double size;
  final bool showLabel;
  final bool useGradient;

  const NutritionScoreBadge({
    Key? key,
    required this.score,
    this.size = 40,
    this.showLabel = false,
    this.useGradient = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = AppTheme.getNutritionScoreColor(score);
    final label = AppTheme.getNutritionScoreLabel(score);
    final scoreText = score.round().toString();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient:
                useGradient
                    ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [color.withOpacity(0.8), color],
                    )
                    : null,
            color: useGradient ? null : color,
            boxShadow: AppTheme.shadowSmall,
          ),
          child: Center(
            child: Text(
              scoreText,
              style: theme.textTheme.labelLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        if (showLabel)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }
}
