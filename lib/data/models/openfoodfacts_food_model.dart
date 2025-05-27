// lib/data/models/openfoodfacts_food_model.dart
import 'package:lym_nutrition/domain/entities/food_item.dart';

class OpenFoodFactsFoodModel extends FoodItem {
  final String barcode;
  final List<String>? ingredients;
  final List<String>? allergens;
  final String? nutriscore;

  OpenFoodFactsFoodModel({
    required this.barcode,
    required String name,
    required String category,
    required String brand,
    required double calories,
    required double proteins,
    required double carbs,
    required double fats,
    required double sugar,
    required double fiber,
    required Map<String, dynamic> nutrients,
    required String imageUrl,
    this.ingredients,
    this.allergens,
    this.nutriscore,
    required double nutritionScore,
  }) : super(
          id: barcode,
          name: name,
          category: category,
          isProcessed: true,
          calories: calories,
          proteins: proteins,
          carbs: carbs,
          fats: fats,
          sugar: sugar,
          fiber: fiber,
          nutrients: nutrients,
          imageUrl: imageUrl,
          source: 'openfoodfacts',
          brand: brand,
          nutritionScore: nutritionScore,
        );

  factory OpenFoodFactsFoodModel.fromJson(Map<String, dynamic> json) {
    // Structure à adapter en fonction du format réel d'OpenFoodFacts
    final product = json['product'] ?? json;

    final nutrients = product['nutriments'] ?? {};
    final imageUrl = product['image_url'] ?? '';

    return OpenFoodFactsFoodModel(
      barcode: product['code'] ?? product['_id'] ?? '',
      name: product['product_name'] ?? '',
      category: product['categories_tags']?.isNotEmpty
          ? product['categories_tags'][0]
          : 'Non catégorisé',
      brand: product['brands'] ?? '',
      calories: _getDoubleValue(nutrients, 'energy-kcal_100g') ?? 0,
      proteins: _getDoubleValue(nutrients, 'proteins_100g') ?? 0,
      carbs: _getDoubleValue(nutrients, 'carbohydrates_100g') ?? 0,
      fats: _getDoubleValue(nutrients, 'fat_100g') ?? 0,
      sugar: _getDoubleValue(nutrients, 'sugars_100g') ?? 0,
      fiber: _getDoubleValue(nutrients, 'fiber_100g') ?? 0,
      nutrients: nutrients,
      imageUrl: imageUrl,
      ingredients: product['ingredients_tags'] != null
          ? List<String>.from(product['ingredients_tags'])
          : null,
      allergens: product['allergens_tags'] != null
          ? List<String>.from(product['allergens_tags'])
          : null,
      nutriscore: product['nutriscore_grade'],
      nutritionScore: _calculateNutritionScore(product),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': barcode,
      'product_name': name,
      'brands': brand,
      'categories_tags': [category],
      'image_url': imageUrl,
      'ingredients_tags': ingredients,
      'allergens_tags': allergens,
      'nutriscore_grade': nutriscore,
      'nutriments': {
        'energy-kcal_100g': calories,
        'proteins_100g': proteins,
        'carbohydrates_100g': carbs,
        'fat_100g': fats,
        'sugars_100g': sugar,
        'fiber_100g': fiber,
        ...nutrients,
      },
    };
  }

  static double? _getDoubleValue(Map<String, dynamic> map, String key) {
    if (map[key] == null) return null;

    if (map[key] is String) {
      return double.tryParse(map[key]);
    }

    return (map[key] as num).toDouble();
  }

  static double _calculateNutritionScore(Map<String, dynamic> product) {
    // Utilisation du Nutri-Score si disponible
    String? nutriscoreGrade = product['nutriscore_grade'];
    if (nutriscoreGrade != null) {
      switch (nutriscoreGrade.toLowerCase()) {
        case 'a':
          return 90.0;
        case 'b':
          return 70.0;
        case 'c':
          return 50.0;
        case 'd':
          return 30.0;
        case 'e':
          return 10.0;
      }
    }

    // Calcul simplifié si pas de Nutri-Score
    Map<String, dynamic> nutrients = product['nutriments'] ?? {};

    double score = 50.0; // Score de base

    // Bonus pour protéines
    double proteins = _getDoubleValue(nutrients, 'proteins_100g') ?? 0;
    score += proteins * 2;

    // Bonus pour fibres
    double fibers = _getDoubleValue(nutrients, 'fiber_100g') ?? 0;
    score += fibers * 3;

    // Malus pour sucres
    double sugars = _getDoubleValue(nutrients, 'sugars_100g') ?? 0;
    score -= sugars * 1.5;

    // Malus pour graisses saturées
    double saturatedFats =
        _getDoubleValue(nutrients, 'saturated-fat_100g') ?? 0;
    score -= saturatedFats * 2;

    // Malus pour sel
    double salt = _getDoubleValue(nutrients, 'salt_100g') ?? 0;
    score -= salt * 5;

    // Limiter le score entre 0 et 100
    return score.clamp(0.0, 100.0);
  }
}
