// lib/core/services/favorites_service.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lym_nutrition/domain/entities/food_item.dart';

class FavoritesService {
  static const String _favoritesKey = 'user_favorites';

  /// Récupère la liste des aliments favoris
  static Future<List<FoodItem>> getFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesJson = prefs.getString(_favoritesKey);
      
      if (favoritesJson == null) return [];
      
      final favoritesList = jsonDecode(favoritesJson) as List;
      return favoritesList.map((item) => FoodItem(
        id: item['id'] ?? '',
        name: item['name'] ?? '',
        category: item['category'] ?? '',
        isProcessed: item['isProcessed'] ?? false,
        calories: (item['calories'] ?? 0).toDouble(),
        proteins: (item['proteins'] ?? 0).toDouble(),
        carbs: (item['carbs'] ?? 0).toDouble(),
        fats: (item['fats'] ?? 0).toDouble(),
        sugar: (item['sugar'] ?? 0).toDouble(),
        fiber: (item['fiber'] ?? 0).toDouble(),
        nutrients: Map<String, dynamic>.from(item['nutrients'] ?? {}),
        imageUrl: item['imageUrl'] ?? '',
        source: item['source'] ?? '',
        brand: item['brand'],
        nutritionScore: (item['nutritionScore'] ?? 0).toDouble(),
        nutriScoreGrade: item['nutriScoreGrade'],
      )).toList();
    } catch (e) {
      print('Erreur lors du chargement des favoris: $e');
      return [];
    }
  }

  /// Ajoute un aliment aux favoris
  static Future<bool> addToFavorites(FoodItem food) async {
    try {
      final favorites = await getFavorites();
      
      // Vérifier si l'aliment n'est pas déjà en favoris
      if (favorites.any((item) => item.id == food.id && item.source == food.source)) {
        return false; // Déjà en favoris
      }
      
      favorites.add(food);
      await _saveFavorites(favorites);
      return true;
    } catch (e) {
      print('Erreur lors de l\'ajout aux favoris: $e');
      return false;
    }
  }

  /// Retire un aliment des favoris
  static Future<bool> removeFromFavorites(FoodItem food) async {
    try {
      final favorites = await getFavorites();
      final initialLength = favorites.length;
      
      favorites.removeWhere((item) => item.id == food.id && item.source == food.source);
      
      if (favorites.length < initialLength) {
        await _saveFavorites(favorites);
        return true;
      }
      return false;
    } catch (e) {
      print('Erreur lors de la suppression des favoris: $e');
      return false;
    }
  }

  /// Vérifie si un aliment est en favoris
  static Future<bool> isFavorite(FoodItem food) async {
    try {
      final favorites = await getFavorites();
      return favorites.any((item) => item.id == food.id && item.source == food.source);
    } catch (e) {
      print('Erreur lors de la vérification des favoris: $e');
      return false;
    }
  }

  /// Sauvegarde la liste des favoris
  static Future<void> _saveFavorites(List<FoodItem> favorites) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesJson = favorites.map((food) => {
        'id': food.id,
        'name': food.name,
        'category': food.category,
        'isProcessed': food.isProcessed,
        'calories': food.calories,
        'proteins': food.proteins,
        'carbs': food.carbs,
        'fats': food.fats,
        'sugar': food.sugar,
        'fiber': food.fiber,
        'nutrients': food.nutrients,
        'imageUrl': food.imageUrl,
        'source': food.source,
        'brand': food.brand,
        'nutritionScore': food.nutritionScore,
        'nutriScoreGrade': food.nutriScoreGrade,
      }).toList();
      
      await prefs.setString(_favoritesKey, jsonEncode(favoritesJson));
    } catch (e) {
      print('Erreur lors de la sauvegarde des favoris: $e');
    }
  }

  /// Efface tous les favoris
  static Future<void> clearFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_favoritesKey);
    } catch (e) {
      print('Erreur lors de l\'effacement des favoris: $e');
    }
  }

  /// Ajoute une recette aux favoris (sous forme d'aliment générique)
  static Future<bool> addRecipeToFavorites({
    required String recipeName,
    required String recipeContent,
    required double calories,
    required double proteins,
    required double carbs,
    required double fats,
  }) async {
    try {
      final recipeFood = FoodItem(
        id: 'recipe_${DateTime.now().millisecondsSinceEpoch}',
        name: recipeName,
        category: 'Recettes',
        isProcessed: false,
        calories: calories,
        proteins: proteins,
        carbs: carbs,
        fats: fats,
        sugar: 0,
        fiber: 0,
        nutrients: {'recipe_content': recipeContent},
        imageUrl: '',
        source: 'recipe',
        nutritionScore: 3.0,
        nutriScoreGrade: 'C',
      );
      
      return await addToFavorites(recipeFood);
    } catch (e) {
      print('Erreur lors de l\'ajout de la recette aux favoris: $e');
      return false;
    }
  }
}
