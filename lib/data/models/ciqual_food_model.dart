// lib/data/models/ciqual_food_model.dart
import 'package:lym_nutrition/domain/entities/food_item.dart';
import 'package:lym_nutrition/core/services/nutriscore_calculator.dart';

class CiqualFoodModel extends FoodItem {
  final String alimCode;
  final String? alimGrpNomFr;
  final String? alimSsgrpNomFr;

  CiqualFoodModel({
    required this.alimCode,
    required String name,
    this.alimGrpNomFr,
    this.alimSsgrpNomFr,
    required Map<String, dynamic> nutrients,
    required double nutritionScore,
    String? nutriScoreGrade,
  }) : super(
          id: alimCode,
          name: name,
          category: alimGrpNomFr ?? 'Non catégorisé',
          isProcessed: false,
          calories: _getCalories(nutrients),
          proteins: _getDoubleValue(
              nutrients, 'Protéines, N x facteur de Jones (g/100 g)'),
          carbs: _getDoubleValue(nutrients, 'Glucides (g/100 g)'),
          fats: _getDoubleValue(nutrients, 'Lipides (g/100 g)'),
          sugar: _getDoubleValue(nutrients, 'Sucres (g/100 g)'),
          fiber: _getDoubleValue(nutrients, 'Fibres alimentaires (g/100 g)'),
          nutrients: nutrients,
          imageUrl: '', // Les aliments CIQUAL n'ont pas d'images par défaut
          source: 'ciqual',
          brand: null,
          nutritionScore: nutritionScore,
          nutriScoreGrade: nutriScoreGrade,
        );

  factory CiqualFoodModel.fromJson(Map<String, dynamic> json) {
    // Calcul du Nutri-Score officiel selon l'algorithme OpenFoodFacts
    String? nutriscoreGrade = _calculateOfficialNutriScore(json);
    double nutritionScore = _convertNutriScoreToNumeric(nutriscoreGrade);

    return CiqualFoodModel(
      alimCode: json['alim_code'].toString(),
      name: json['alim_nom_fr'],
      alimGrpNomFr: json['alim_grp_nom_fr'],
      alimSsgrpNomFr: json['alim_ssgrp_nom_fr'],
      nutrients: _extractNutrients(json),
      nutritionScore: nutritionScore,
      nutriScoreGrade: nutriscoreGrade,
    );
  }

  static Map<String, dynamic> _extractNutrients(Map<String, dynamic> json) {
    Map<String, dynamic> nutrients = {};

    json.forEach((key, value) {
      if (key != 'alim_code' &&
          key != 'alim_nom_fr' &&
          key != 'alim_grp_nom_fr' &&
          key != 'alim_ssgrp_nom_fr' &&
          key != 'alim_grp_code' &&
          key != 'alim_ssgrp_code' &&
          key != 'alim_ssssgrp_code' &&
          key != 'alim_ssssgrp_nom_fr' &&
          key != 'alim_nom_sci') {
        nutrients[key] = value;
      }
    });

    return nutrients;
  }

  static double _getCalories(Map<String, dynamic> nutrients) {
    // Essayer plusieurs champs de calories possibles
    String calorieField = 'Energie, Règlement UE N° 1169/2011 (kcal/100 g)';
    if (nutrients[calorieField] != null && nutrients[calorieField] != '-') {
      return _getDoubleValue(nutrients, calorieField);
    }

    calorieField = 'Energie, N x facteur Jones, avec fibres  (kcal/100 g)';
    if (nutrients[calorieField] != null && nutrients[calorieField] != '-') {
      return _getDoubleValue(nutrients, calorieField);
    }

    // Valeur par défaut si aucune information de calories
    return 0.0;
  }

  static double _getDoubleValue(Map<String, dynamic> nutrients, String key) {
    if (nutrients[key] == null || nutrients[key] == '-') return 0.0;

    if (nutrients[key] is String) {
      String value = nutrients[key].toString().replaceAll(',', '.');
      if (value.startsWith('<')) {
        // Prendre la moitié de la valeur si c'est "< X"
        return double.tryParse(value.substring(1).trim())! / 2;
      }
      return double.tryParse(value) ?? 0.0;
    }

    return (nutrients[key] as num).toDouble();
  }

  /// Calcule le Nutri-Score officiel selon l'algorithme OpenFoodFacts pour les données CIQUAL
  static String? _calculateOfficialNutriScore(Map<String, dynamic> json) {
    try {
      // Récupération des valeurs nutritionnelles depuis les données CIQUAL
      double energyKj = _getDoubleValue(json, 'Energie, N x facteur Jones, avec fibres (kJ/100 g)');
      double energy = energyKj; // Déjà en kJ
      double sugars = _getDoubleValue(json, 'Sucres (g/100 g)');
      double saturatedFat = _getDoubleValue(json, 'AG saturés (g/100 g)');
      double salt = _getDoubleValue(json, 'Sel chlorure de sodium (g/100 g)');
      double sodium = NutriScoreCalculator.saltToSodium(salt);
      double fiber = _getDoubleValue(json, 'Fibres alimentaires (g/100 g)');
      double proteins = _getDoubleValue(json, 'Protéines, N x facteur de Jones (g/100 g)');
      
      // Estimation du pourcentage fruits/légumes/noix basée sur la catégorie CIQUAL
      String category = json['alim_grp_nom_fr'] ?? 'general';
      double fruitsVegetablesNuts = _estimateFruitsVegetablesNutsCiqual(category);

      // Calcul du Nutri-Score
      return NutriScoreCalculator.calculateNutriScore(
        energy: energy,
        sugars: sugars,
        saturatedFat: saturatedFat,
        sodium: sodium,
        fiber: fiber,
        proteins: proteins,
        fruitsVegetablesNuts: fruitsVegetablesNuts,
        category: category,
      );
    } catch (e) {
      print('Erreur lors du calcul du Nutri-Score CIQUAL: $e');
      return null;
    }
  }

  /// Convertit le grade Nutri-Score (A-E) en score numérique (1-5)
  static double _convertNutriScoreToNumeric(String? nutriscoreGrade) {
    if (nutriscoreGrade == null) return 3.0;
    
    switch (nutriscoreGrade.toUpperCase()) {
      case 'A':
        return 5.0; // Excellent
      case 'B':
        return 4.0; // Bon
      case 'C':
        return 3.0; // Moyen
      case 'D':
        return 2.0; // Faible
      case 'E':
        return 1.0; // Mauvais
      default:
        return 3.0; // Par défaut
    }
  }

  /// Estimation du pourcentage de fruits/légumes/noix pour les catégories CIQUAL
  static double _estimateFruitsVegetablesNutsCiqual(String category) {
    final category_lower = category.toLowerCase();
    
    // Fruits
    if (category_lower.contains('fruits')) {
      return 100.0;
    }
    
    // Légumes
    if (category_lower.contains('légumes') || category_lower.contains('végétaux')) {
      return 85.0;
    }
    
    // Noix et graines
    if (category_lower.contains('noix') || category_lower.contains('graines') || 
        category_lower.contains('oléagineux')) {
      return 95.0;
    }
    
    // Produits à base de fruits/légumes
    if (category_lower.contains('jus de fruits') || category_lower.contains('compotes')) {
      return 90.0;
    }
    
    return 0.0; // Par défaut pour les autres catégories
  }
}
