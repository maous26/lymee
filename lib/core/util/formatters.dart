// lib/core/util/formatters.dart
class Formatters {
  static String formatCalories(double calories) {
    return '${calories.round()} kcal';
  }

  static String formatWeight(double weight, {bool showUnit = true}) {
    return '${weight.toStringAsFixed(1)}${showUnit ? ' g' : ''}';
  }

  static String formatPercentage(double value) {
    return '${(value * 100).toStringAsFixed(1)}%';
  }

  static String formatNutritionScore(double score) {
    return score.round().toString();
  }

  static String formatNutrientValue(dynamic value, String unit) {
    if (value == null || value == '-') {
      return '0 $unit';
    }

    if (value is String) {
      if (value.startsWith('<')) {
        return '$value $unit';
      }
      final parsedValue = double.tryParse(value.replaceAll(',', '.'));
      if (parsedValue != null) {
        return '${parsedValue.toStringAsFixed(1)} $unit';
      }
      return '$value $unit';
    }

    if (value is num) {
      return '${value.toStringAsFixed(1)} $unit';
    }

    return '0 $unit';
  }
}
