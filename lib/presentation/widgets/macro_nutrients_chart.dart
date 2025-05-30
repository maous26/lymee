// lib/presentation/widgets/macro_nutrients_chart.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class MacroNutrientsChart extends StatelessWidget {
  final double proteins;
  final double carbs;
  final double fats;
  final double proteinTarget;
  final double carbsTarget;
  final double fatTarget;

  const MacroNutrientsChart({
    Key? key,
    required this.proteins,
    required this.carbs,
    required this.fats,
    required this.proteinTarget,
    required this.carbsTarget,
    required this.fatTarget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Calculer les pourcentages
    final totalCalories = (proteins * 4) + (carbs * 4) + (fats * 9);
    final proteinPercent =
        totalCalories > 0 ? (proteins * 4) / totalCalories : 0.0;
    final carbsPercent = totalCalories > 0 ? (carbs * 4) / totalCalories : 0.0;
    final fatPercent = totalCalories > 0 ? (fats * 9) / totalCalories : 0.0;

    // Calculer les pourcentages cibles
    final totalTargetCalories =
        (proteinTarget * 4) + (carbsTarget * 4) + (fatTarget * 9);
    final proteinTargetPercent = totalTargetCalories > 0
        ? (proteinTarget * 4) / totalTargetCalories
        : 0.0;
    final carbsTargetPercent =
        totalTargetCalories > 0 ? (carbsTarget * 4) / totalTargetCalories : 0.0;
    final fatTargetPercent =
        totalTargetCalories > 0 ? (fatTarget * 9) / totalTargetCalories : 0.0;

    return Column(
      children: [
        SizedBox(
          height: 200,
          child: Row(
            children: [
              // Graphique des macros actuels
              Expanded(
                child: Column(
                  children: [
                    const Text(
                      'Aujourd\'hui',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Expanded(
                      child: PieChart(
                        PieChartData(
                          sections: [
                            PieChartSectionData(
                              value: proteins,
                              title: '${(proteinPercent * 100).round()}%',
                              color: Colors.blue,
                              radius: 60,
                              titleStyle: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            PieChartSectionData(
                              value: carbs,
                              title: '${(carbsPercent * 100).round()}%',
                              color: Colors.orange,
                              radius: 60,
                              titleStyle: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            PieChartSectionData(
                              value: fats,
                              title: '${(fatPercent * 100).round()}%',
                              color: Colors.red,
                              radius: 60,
                              titleStyle: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                          sectionsSpace: 2,
                          centerSpaceRadius: 30,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Graphique des macros cibles
              Expanded(
                child: Column(
                  children: [
                    const Text(
                      'Objectif',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Expanded(
                      child: PieChart(
                        PieChartData(
                          sections: [
                            PieChartSectionData(
                              value: proteinTarget,
                              title: '${(proteinTargetPercent * 100).round()}%',
                              color: Colors.blue.withOpacity(0.7),
                              radius: 60,
                              titleStyle: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            PieChartSectionData(
                              value: carbsTarget,
                              title: '${(carbsTargetPercent * 100).round()}%',
                              color: Colors.orange.withOpacity(0.7),
                              radius: 60,
                              titleStyle: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            PieChartSectionData(
                              value: fatTarget,
                              title: '${(fatTargetPercent * 100).round()}%',
                              color: Colors.red.withOpacity(0.7),
                              radius: 60,
                              titleStyle: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                          sectionsSpace: 2,
                          centerSpaceRadius: 30,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Légende
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem('Protéines', Colors.blue),
              const SizedBox(width: 16),
              _buildLegendItem('Glucides', Colors.orange),
              const SizedBox(width: 16),
              _buildLegendItem('Lipides', Colors.red),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}
