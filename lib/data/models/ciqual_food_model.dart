// lib/data/models/ciqual_food_model.dart
import 'package:lym_nutrition/domain/entities/food_item.dart';

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
  }) : super(
          id: alimCode,
          name: name,
          category: alimGrpNomFr ?? 'Non catégorisé',
          isProcessed: false,
          calories: _getCalories(nutrients),
          proteins: _getDoubleValue(nutrients, 'Protéines, N x facteur de Jones (g/100 g)'),
          carbs: _getDoubleValue(nutrients, 'Glucides (g/100 g)'),
          fats: _getDoubleValue(nutrients, 'Lipides (g/100 g)'),
          sugar: _getDoubleValue(nutrients, 'Sucres (g/100 g)'),
          fiber: _getDoubleValue(nutrients, 'Fibres alimentaires (g/100 g)'),
          nutrients: nutrients,
          imageUrl: '', // Les aliments CIQUAL n'ont pas d'images par défaut
          source: 'ciqual',
          brand: null,
          nutritionScore: nutritionScore,
        );

  factory CiqualFoodModel.fromJson(Map<String, dynamic> json) {
    // Calcul du score nutritionnel basé sur les recommandations OMS
    double nutritionScore = _calculateNutritionScore(json);
    
    return CiqualFoodModel(
      alimCode: json['alim_code'].toString(),
      name: json['alim_nom_fr'],
      alimGrpNomFr: json['alim_grp_nom_fr'],
      alimSsgrpNomFr: json['alim_ssgrp_nom_fr'],
      nutrients: _extractNutrients(json),
      nutritionScore: nutritionScore,
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

  static double _calculateNutritionScore(Map<String, dynamic> json) {
    // Implémentation simplifiée du score nutritionnel basé sur les recommandations OMS
    // Score de 0 à 100, où 100 est excellent
    double score = 50.0; // Score de base
    
    // Bonus pour protéines
    double proteins = _getDoubleValue(json, 'Protéines, N x facteur de Jones (g/100 g)');
    score += proteins * 2;
    
    // Bonus pour fibres
    double fibers = _getDoubleValue(json, 'Fibres alimentaires (g/100 g)');
    score += fibers * 3;
    
    // Malus pour sucres
    double sugars = _getDoubleValue(json, 'Sucres (g/100 g)');
    score -= sugars * 1.5;
    
    // Malus pour graisses saturées
    double saturatedFats = _getDoubleValue(json, 'AG saturés (g/100 g)');
    score -= saturatedFats * 2;
    
    // Malus pour sel
    double salt = _getDoubleValue(json, 'Sel chlorure de sodium (g/100 g)');
    score -= salt * 5;
    
    // Bonus pour vitamines et minéraux
    // Simplification: on compte juste les présences de vitamines/minéraux
    int nutrientCount = 0;
    for (String key in json.keys) {
      if (key.startsWith('Vitamine') || 
          key == 'Calcium (mg/100 g)' || 
          key == 'Fer (mg/100 g)' ||
          key == 'Magnésium (mg/100 g)') {
        var value = json[key];
        if (value != null && value != '-' && value != '0' && value != '0.0') {
          nutrientCount++;
        }
      }
    }
    score += nutrientCount * 1.5;
    
    // Limiter le score entre 0 et 100
    return score.clamp(0.0, 100.0);
  }
}

