// lib/presentation/widgets/nutrition_target_card.dart
import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class NutritionTargetCard extends StatelessWidget {
  final String label;
  final double consumed;
  final double target;
  final String unit;
  final Color color;

  const NutritionTargetCard({
    Key? key,
    required this.label,
    required this.consumed,
    required this.target,
    required this.unit,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final percent = (consumed / target).clamp(0.0, 1.0);
    final remaining = (target - consumed).clamp(0.0, double.infinity);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Icon(
                _getIconForLabel(label),
                size: 16,
                color: color,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${consumed.toStringAsFixed(1)}$unit',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          LinearPercentIndicator(
            lineHeight: 6,
            percent: percent,
            backgroundColor: Colors.grey.withOpacity(0.2),
            progressColor: color,
            barRadius: const Radius.circular(3),
            padding: EdgeInsets.zero,
          ),
          const SizedBox(height: 4),
          Text(
            'Objectif: ${target.toStringAsFixed(1)}$unit',
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
            ),
          ),
          if (remaining > 0)
            Text(
              'Restant: ${remaining.toStringAsFixed(1)}$unit',
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[600],
              ),
            ),
        ],
      ),
    );
  }

  IconData _getIconForLabel(String label) {
    switch (label.toLowerCase()) {
      case 'protéines':
        return Icons.fitness_center;
      case 'glucides':
        return Icons.grain;
      case 'lipides':
        return Icons.opacity;
      default:
        return Icons.restaurant;
    }
  }
}
