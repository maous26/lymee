// lib/core/services/nutriscore_calculator.dart

/// Service pour calculer le Nutri-Score selon l'algorithme officiel d'OpenFoodFacts
/// Basé sur la formule officielle mise à jour en 2024
class NutriScoreCalculator {
  /// Calcule le Nutri-Score pour un produit alimentaire
  /// Retourne une lettre (A, B, C, D, E) ou null si le calcul est impossible
  static String? calculateNutriScore({
    required double energy, // en kJ pour 100g
    required double sugars, // en g pour 100g
    required double saturatedFat, // en g pour 100g
    required double sodium, // en mg pour 100g
    required double fiber, // en g pour 100g
    required double proteins, // en g pour 100g
    required double fruitsVegetablesNuts, // % pour 100g (estimation)
    String category = 'general', // catégorie du produit
  }) {
    try {
      // Points négatifs (A points)
      int pointsA = 0;
      
      // Énergie (kJ/100g)
      pointsA += _getEnergyPoints(energy);
      
      // Sucres (g/100g)
      pointsA += _getSugarsPoints(sugars, category);
      
      // Graisses saturées (g/100g)
      pointsA += _getSaturatedFatPoints(saturatedFat, category);
      
      // Sodium (mg/100g)
      pointsA += _getSodiumPoints(sodium);

      // Points positifs (C points)
      int pointsC = 0;
      
      // Fibres (g/100g)
      pointsC += _getFiberPoints(fiber);
      
      // Protéines (g/100g)
      pointsC += _getProteinPoints(proteins);
      
      // Fruits, légumes, noix (%)
      pointsC += _getFruitsVegetablesNutsPoints(fruitsVegetablesNuts);

      // Calcul du score final
      int finalScore = pointsA - pointsC;

      // Conditions spéciales pour les fromages et matières grasses
      if (_isCheeseCategory(category)) {
        return _getNutriScoreGradeForCheese(finalScore);
      } else if (_isFatsCategory(category)) {
        return _getNutriScoreGradeForFats(finalScore);
      } else {
        return _getNutriScoreGradeGeneral(finalScore);
      }
    } catch (e) {
      print('Erreur lors du calcul du Nutri-Score: $e');
      return null;
    }
  }

  /// Points pour l'énergie (kJ/100g)
  static int _getEnergyPoints(double energy) {
    if (energy <= 335) return 0;
    if (energy <= 670) return 1;
    if (energy <= 1005) return 2;
    if (energy <= 1340) return 3;
    if (energy <= 1675) return 4;
    if (energy <= 2010) return 5;
    if (energy <= 2345) return 6;
    if (energy <= 2680) return 7;
    if (energy <= 3015) return 8;
    if (energy <= 3350) return 9;
    return 10;
  }

  /// Points pour les sucres (g/100g)
  static int _getSugarsPoints(double sugars, String category) {
    // Pour les boissons, barème différent
    if (_isDrinkCategory(category)) {
      if (sugars <= 0) return 0;
      if (sugars <= 1.5) return 1;
      if (sugars <= 3) return 2;
      if (sugars <= 4.5) return 3;
      if (sugars <= 6) return 4;
      if (sugars <= 7.5) return 5;
      if (sugars <= 9) return 6;
      if (sugars <= 10.5) return 7;
      if (sugars <= 12) return 8;
      if (sugars <= 13.5) return 9;
      return 10;
    } else {
      // Barème général
      if (sugars <= 4.5) return 0;
      if (sugars <= 9) return 1;
      if (sugars <= 13.5) return 2;
      if (sugars <= 18) return 3;
      if (sugars <= 22.5) return 4;
      if (sugars <= 27) return 5;
      if (sugars <= 31) return 6;
      if (sugars <= 36) return 7;
      if (sugars <= 40) return 8;
      if (sugars <= 45) return 9;
      return 10;
    }
  }

  /// Points pour les graisses saturées (g/100g)
  static int _getSaturatedFatPoints(double saturatedFat, String category) {
    // Pour les matières grasses, barème différent
    if (_isFatsCategory(category)) {
      if (saturatedFat <= 10) return 0;
      if (saturatedFat <= 16) return 1;
      if (saturatedFat <= 22) return 2;
      if (saturatedFat <= 28) return 3;
      if (saturatedFat <= 34) return 4;
      if (saturatedFat <= 40) return 5;
      if (saturatedFat <= 46) return 6;
      if (saturatedFat <= 52) return 7;
      if (saturatedFat <= 58) return 8;
      if (saturatedFat <= 64) return 9;
      return 10;
    } else {
      // Barème général
      if (saturatedFat <= 1) return 0;
      if (saturatedFat <= 2) return 1;
      if (saturatedFat <= 3) return 2;
      if (saturatedFat <= 4) return 3;
      if (saturatedFat <= 5) return 4;
      if (saturatedFat <= 6) return 5;
      if (saturatedFat <= 7) return 6;
      if (saturatedFat <= 8) return 7;
      if (saturatedFat <= 9) return 8;
      if (saturatedFat <= 10) return 9;
      return 10;
    }
  }

  /// Points pour le sodium (mg/100g)
  static int _getSodiumPoints(double sodium) {
    if (sodium <= 90) return 0;
    if (sodium <= 180) return 1;
    if (sodium <= 270) return 2;
    if (sodium <= 360) return 3;
    if (sodium <= 450) return 4;
    if (sodium <= 540) return 5;
    if (sodium <= 630) return 6;
    if (sodium <= 720) return 7;
    if (sodium <= 810) return 8;
    if (sodium <= 900) return 9;
    return 10;
  }

  /// Points pour les fibres (g/100g)
  static int _getFiberPoints(double fiber) {
    if (fiber <= 0.9) return 0;
    if (fiber <= 1.9) return 1;
    if (fiber <= 2.8) return 2;
    if (fiber <= 3.7) return 3;
    if (fiber <= 4.7) return 4;
    return 5;
  }

  /// Points pour les protéines (g/100g)
  static int _getProteinPoints(double proteins) {
    if (proteins <= 1.6) return 0;
    if (proteins <= 3.2) return 1;
    if (proteins <= 4.8) return 2;
    if (proteins <= 6.4) return 3;
    if (proteins <= 8.0) return 4;
    return 5;
  }

  /// Points pour fruits, légumes, noix (%)
  static int _getFruitsVegetablesNutsPoints(double percentage) {
    if (percentage <= 40) return 0;
    if (percentage <= 60) return 1;
    if (percentage <= 80) return 2;
    return 5;
  }

  /// Détermine le grade Nutri-Score pour les produits généraux
  static String _getNutriScoreGradeGeneral(int score) {
    if (score <= -1) return 'A';
    if (score <= 2) return 'B';
    if (score <= 10) return 'C';
    if (score <= 18) return 'D';
    return 'E';
  }

  /// Détermine le grade Nutri-Score pour les fromages
  static String _getNutriScoreGradeForCheese(int score) {
    if (score <= -1) return 'A';
    if (score <= 2) return 'B';
    if (score <= 10) return 'C';
    if (score <= 18) return 'D';
    return 'E';
  }

  /// Détermine le grade Nutri-Score pour les matières grasses
  static String _getNutriScoreGradeForFats(int score) {
    if (score <= 3) return 'C';
    if (score <= 10) return 'D';
    return 'E';
  }

  /// Vérifie si c'est une catégorie de boisson
  static bool _isDrinkCategory(String category) {
    final drinkCategories = [
      'beverages',
      'drinks',
      'boissons',
      'jus',
      'sodas',
      'waters',
      'eaux',
    ];
    return drinkCategories.any((cat) => 
        category.toLowerCase().contains(cat.toLowerCase()));
  }

  /// Vérifie si c'est une catégorie de fromage
  static bool _isCheeseCategory(String category) {
    final cheeseCategories = [
      'cheese',
      'fromage',
      'dairy',
      'lait',
    ];
    return cheeseCategories.any((cat) => 
        category.toLowerCase().contains(cat.toLowerCase()));
  }

  /// Vérifie si c'est une catégorie de matières grasses
  static bool _isFatsCategory(String category) {
    final fatsCategories = [
      'fats',
      'oils',
      'huiles',
      'beurre',
      'butter',
      'margarine',
    ];
    return fatsCategories.any((cat) => 
        category.toLowerCase().contains(cat.toLowerCase()));
  }

  /// Convertit les calories (kcal) en énergie (kJ)
  static double caloriesToKilojoules(double calories) {
    return calories * 4.184;
  }

  /// Convertit le sel (g) en sodium (mg)
  static double saltToSodium(double salt) {
    return salt * 400; // 1g de sel = 400mg de sodium
  }

  /// Estimation du pourcentage de fruits/légumes/noix basée sur la catégorie
  static double estimateFruitsVegetablesNuts(String category, List<String>? ingredients) {
    final category_lower = category.toLowerCase();
    
    // Fruits et légumes
    if (category_lower.contains('fruit') || 
        category_lower.contains('vegetable') ||
        category_lower.contains('légume')) {
      return 80.0;
    }
    
    // Noix et graines
    if (category_lower.contains('nuts') || 
        category_lower.contains('noix') ||
        category_lower.contains('seeds')) {
      return 85.0;
    }
    
    // Jus de fruits
    if (category_lower.contains('jus') || 
        (category_lower.contains('juice') && category_lower.contains('fruit'))) {
      return 100.0;
    }
    
    // Analyse des ingrédients si disponibles
    if (ingredients != null) {
      int fruitsVegCount = 0;
      for (String ingredient in ingredients.take(5)) { // Premiers 5 ingrédients
        String ing_lower = ingredient.toLowerCase();
        if (ing_lower.contains('fruit') || 
            ing_lower.contains('légume') ||
            ing_lower.contains('noix') ||
            ing_lower.contains('nuts')) {
          fruitsVegCount++;
        }
      }
      if (fruitsVegCount > 0) {
        return (fruitsVegCount / ingredients.take(5).length) * 60;
      }
    }
    
    return 0.0; // Par défaut
  }
}
