// lib/domain/entities/food_item.dart
class FoodItem {
  final String id;
  final String name;
  final String category;
  final bool isProcessed;
  final double calories;
  final double proteins;
  final double carbs;
  final double fats;
  final double sugar;
  final double fiber;
  final Map<String, dynamic> nutrients;
  final String imageUrl;
  final String source; // 'ciqual' ou 'openfoodfacts'
  final String? brand;
  final double nutritionScore;

  FoodItem({
    required this.id,
    required this.name,
    required this.category,
    required this.isProcessed,
    required this.calories,
    required this.proteins,
    required this.carbs,
    required this.fats,
    required this.sugar,
    required this.fiber,
    required this.nutrients,
    required this.imageUrl,
    required this.source,
    this.brand,
    required this.nutritionScore,
  });
}
