// lib/data/datasources/local/ciqual_local_data_source.dart
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:lym_nutrition/data/models/ciqual_food_model.dart';
import 'package:lym_nutrition/core/error/exceptions.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class CiqualLocalDataSource {
  /// Récupère tous les aliments de la base CIQUAL qui correspondent à la requête
  ///
  /// Retourne une liste de [CiqualFoodModel]
  ///
  /// Lance [CacheException] si aucune donnée n'est disponible
  Future<List<CiqualFoodModel>> searchFoods(String query);

  /// Récupère un aliment par son code
  ///
  /// Retourne un [CiqualFoodModel]
  ///
  /// Lance [CacheException] si aucune donnée n'est disponible
  Future<CiqualFoodModel> getFoodByCode(String code);

  /// Initialise la base de données locale avec les données CIQUAL
  Future<void> initializeDatabase();

  /// Vérifie si la base de données est initialisée
  Future<bool> isDatabaseInitialized();

  /// Efface le cache de la base de données CIQUAL pour forcer un rechargement
  Future<void> clearCache();
}

class CiqualLocalDataSourceImpl implements CiqualLocalDataSource {
  final SharedPreferences sharedPreferences;
  static const String CIQUAL_DATA_KEY = 'CIQUAL_DATA';
  static const String CIQUAL_INITIALIZED_KEY = 'CIQUAL_INITIALIZED';

  CiqualLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<List<CiqualFoodModel>> searchFoods(String query) async {
    try {
      if (!await isDatabaseInitialized()) {
        await initializeDatabase();
      }

      final String? jsonString = sharedPreferences.getString(CIQUAL_DATA_KEY);

      if (jsonString == null) {
        throw CacheException('Données CIQUAL non disponibles');
      }

      List<dynamic> decodedJson = jsonDecode(jsonString);
      List<CiqualFoodModel> allFoods =
          decodedJson.map((item) => CiqualFoodModel.fromJson(item)).toList();

      if (query.isEmpty) {
        return allFoods;
      }

      // Filtrer les aliments selon la requête
      // Recherche sur le nom, en ignorant la casse et les accents
      final String normalizedQuery = _normalizeString(query);

      return allFoods.where((food) {
        final String normalizedName = _normalizeString(food.name);

        // Si la requête est un nom de catégorie, on retourne tous les aliments de cette catégorie
        if (food.alimGrpNomFr != null &&
            _normalizeString(food.alimGrpNomFr!).contains(normalizedQuery)) {
          return true;
        }

        // Si la requête est un nom de sous-catégorie, on retourne tous les aliments de cette sous-catégorie
        if (food.alimSsgrpNomFr != null &&
            _normalizeString(food.alimSsgrpNomFr!).contains(normalizedQuery)) {
          return true;
        }

        // Sinon, on cherche dans le nom de l'aliment
        return normalizedName.contains(normalizedQuery);
      }).toList();
    } on Exception catch (e) {
      throw CacheException(e.toString());
    }
  }

  @override
  Future<CiqualFoodModel> getFoodByCode(String code) async {
    try {
      if (!await isDatabaseInitialized()) {
        await initializeDatabase();
      }

      final String? jsonString = sharedPreferences.getString(CIQUAL_DATA_KEY);

      if (jsonString == null) {
        throw CacheException('Données CIQUAL non disponibles');
      }

      List<dynamic> decodedJson = jsonDecode(jsonString);

      final food = decodedJson.firstWhere(
        (item) => item['alim_code'].toString() == code,
        orElse: () => throw CacheException('Aliment non trouvé'),
      );

      return CiqualFoodModel.fromJson(food);
    } catch (e) {
      throw CacheException(e.toString());
    }
  }

  @override
  Future<void> initializeDatabase() async {
    try {
      // Charger le fichier JSON depuis les assets
      final String jsonString =
          await rootBundle.loadString('assets/data/common_ciqual.json');

      // Stocker les données dans SharedPreferences
      await sharedPreferences.setString(CIQUAL_DATA_KEY, jsonString);

      // Marquer la base comme initialisée
      await sharedPreferences.setBool(CIQUAL_INITIALIZED_KEY, true);
    } catch (e) {
      throw CacheException(
          'Erreur lors de l\'initialisation de la base CIQUAL: ${e.toString()}');
    }
  }

  @override
  Future<bool> isDatabaseInitialized() async {
    return sharedPreferences.getBool(CIQUAL_INITIALIZED_KEY) ?? false;
  }

  @override
  Future<void> clearCache() async {
    try {
      // Supprimer les données en cache
      await sharedPreferences.remove(CIQUAL_DATA_KEY);
      await sharedPreferences.remove(CIQUAL_INITIALIZED_KEY);
    } catch (e) {
      throw CacheException(
          'Erreur lors de l\'effacement du cache CIQUAL: ${e.toString()}');
    }
  }

  // Fonction utilitaire pour normaliser les chaînes (supprimer accents, mettre en minuscule)
  String _normalizeString(String input) {
    if (input.isEmpty) return '';

    // Conversion en minuscules
    String normalized = input.toLowerCase();

    // Suppression des accents
    normalized = normalized
        .replaceAll('é', 'e')
        .replaceAll('è', 'e')
        .replaceAll('ê', 'e')
        .replaceAll('ë', 'e')
        .replaceAll('à', 'a')
        .replaceAll('â', 'a')
        .replaceAll('ä', 'a')
        .replaceAll('î', 'i')
        .replaceAll('ï', 'i')
        .replaceAll('ô', 'o')
        .replaceAll('ö', 'o')
        .replaceAll('ù', 'u')
        .replaceAll('û', 'u')
        .replaceAll('ü', 'u')
        .replaceAll('ç', 'c');

    return normalized;
  }
}
