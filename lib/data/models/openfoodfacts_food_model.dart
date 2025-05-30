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
    // Debug logging
    print('🏗️ Parsing OpenFoodFacts product:');
    print('  JSON keys: ${json.keys.toList()}');

    // Structure à adapter en fonction du format réel d'OpenFoodFacts
    final product = json['product'] ?? json;
    print('  Product keys: ${product.keys.toList()}');

    final nutrients = product['nutriments'] ?? {};
    final imageUrl = product['image_url'] ?? '';

    final name = product['product_name'] ?? '';
    final brand = product['brands'] ?? '';
    final barcode = product['code'] ?? product['_id'] ?? '';

    print('  Extracted values:');
    print('    Name: "$name"');
    print('    Brand: "$brand"');
    print('    Barcode: "$barcode"');

    return OpenFoodFactsFoodModel(
      barcode: barcode,
      name: name,
      category: product['categories_tags']?.isNotEmpty
          ? product['categories_tags'][0]
          : 'Non catégorisé',
      brand: brand,
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
    // Utilisation du Nutri-Score si disponible - conversion vers échelle 1-5
    String? nutriscoreGrade = product['nutriscore_grade'];
    if (nutriscoreGrade != null) {
      switch (nutriscoreGrade.toLowerCase()) {
        case 'a':
          return 5.0; // Excellent
        case 'b':
          return 4.0; // Bon
        case 'c':
          return 3.0; // Moyen
        case 'd':
          return 2.0; // Faible
        case 'e':
          return 1.0; // Mauvais
      }
    }

    // Calcul simplifié si pas de Nutri-Score - conversion vers échelle 1-5
    Map<String, dynamic> nutrients = product['nutriments'] ?? {};

    double score = 3.0; // Score de base (moyen)

    // Bonus pour protéines
    double proteins = _getDoubleValue(nutrients, 'proteins_100g') ?? 0;
    score += proteins * 0.02; // Facteur réduit pour échelle 1-5

    // Bonus pour fibres
    double fibers = _getDoubleValue(nutrients, 'fiber_100g') ?? 0;
    score += fibers * 0.03; // Facteur réduit pour échelle 1-5

    // Malus pour sucres
    double sugars = _getDoubleValue(nutrients, 'sugars_100g') ?? 0;
    score -= sugars * 0.015; // Facteur réduit pour échelle 1-5

    // Malus pour graisses saturées
    double saturatedFats =
        _getDoubleValue(nutrients, 'saturated-fat_100g') ?? 0;
    score -= saturatedFats * 0.02; // Facteur réduit pour échelle 1-5

    // Malus pour sel
    double salt = _getDoubleValue(nutrients, 'salt_100g') ?? 0;
    score -= salt * 0.5; // Facteur réduit pour échelle 1-5

    // Limiter le score entre 1 et 5
    return score.clamp(1.0, 5.0);
  }
}
