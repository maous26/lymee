// lib/data/datasources/local/food_history_data_source.dart
import 'dart:convert';
import 'package:lym_nutrition/domain/entities/food_item.dart';
import 'package:lym_nutrition/core/error/exceptions.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class FoodHistoryDataSource {
  /// Récupère l'historique des aliments consultés
  ///
  /// Retourne une liste de [Map<String, dynamic>] représentant des aliments
  Future<List<Map<String, dynamic>>> getHistory();
  
  /// Ajoute un aliment à l'historique
  Future<void> addToHistory(FoodItem food);
  
  /// Supprime un aliment de l'historique
  Future<void> removeFromHistory(String foodId);
  
  /// Efface tout l'historique
  Future<void> clearHistory();
}

class FoodHistoryDataSourceImpl implements FoodHistoryDataSource {
  final SharedPreferences sharedPreferences;
  static const String HISTORY_KEY = 'FOOD_HISTORY';
  static const int MAX_HISTORY_ITEMS = 50;
  
  FoodHistoryDataSourceImpl({required this.sharedPreferences});
  
  @override
  Future<List<Map<String, dynamic>>> getHistory() async {
    try {
      final String? jsonString = sharedPreferences.getString(HISTORY_KEY);
      
      if (jsonString == null) {
        return [];
      }
      
      List<dynamic> history = jsonDecode(jsonString);
      return List<Map<String, dynamic>>.from(history);
    } catch (e) {
      throw CacheException(e.toString());
    }
  }
  
  @override
  Future<void> addToHistory(FoodItem food) async {
    try {
      final String? jsonString = sharedPreferences.getString(HISTORY_KEY);
      
      List<dynamic> history = [];
      
      if (jsonString != null) {
        history = jsonDecode(jsonString);
      }
      
      // Convertir l'aliment en Map
      final Map<String, dynamic> foodMap = {
        'id': food.id,
        'name': food.name,
        'category': food.category,
        'isProcessed': food.isProcessed,
        'calories': food.calories,
        'imageUrl': food.imageUrl,
        'source': food.source,
        'brand': food.brand,
        'nutritionScore': food.nutritionScore,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };
      
      // Supprimer l'aliment s'il existe déjà dans l'historique
      history.removeWhere((item) => item['id'] == food.id);
      
      // Ajouter l'aliment au début de l'historique
      history.insert(0, foodMap);
      
      // Limiter la taille de l'historique
      if (history.length > MAX_HISTORY_ITEMS) {
        history = history.sublist(0, MAX_HISTORY_ITEMS);
      }
      
      // Sauvegarder dans SharedPreferences
      await sharedPreferences.setString(HISTORY_KEY, jsonEncode(history));
    } catch (e) {
      throw CacheException(e.toString());
    }
  }
  
  @override
  Future<void> removeFromHistory(String foodId) async {
    try {
      final String? jsonString = sharedPreferences.getString(HISTORY_KEY);
      
      if (jsonString == null) {
        return;
      }
      
      List<dynamic> history = jsonDecode(jsonString);
      
      // Supprimer l'aliment de l'historique
      history.removeWhere((item) => item['id'] == foodId);
      
      // Sauvegarder dans SharedPreferences
      await sharedPreferences.setString(HISTORY_KEY, jsonEncode(history));
    } catch (e) {
      throw CacheException(e.toString());
    }
  }
  
  @override
  Future<void> clearHistory() async {
    try {
      await sharedPreferences.remove(HISTORY_KEY);
    } catch (e) {
      throw CacheException(e.toString());
    }
  }
}
