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

      // Filtrer les aliments selon la requête avec une logique de correspondance précise
      final String normalizedQuery = _normalizeString(query);

      // Séparer les aliments par score de pertinence
      List<MapEntry<CiqualFoodModel, int>> scoredFoods = [];

      for (final food in allFoods) {
        final String normalizedName = _normalizeString(food.name);
        int score = 0;

        // Score 100: Correspondance exacte du nom
        if (normalizedName == normalizedQuery) {
          score = 100;
        }
        // Score 90: Le nom commence par la requête
        else if (normalizedName.startsWith(normalizedQuery)) {
          score = 90;
        }
        // Score 80: La requête est un mot entier dans le nom
        else if (_containsWholeWord(normalizedName, normalizedQuery)) {
          score = 80;
        }
        // Score 70: Correspondance dans la catégorie
        else if (food.alimGrpNomFr != null &&
            _normalizeString(food.alimGrpNomFr!).contains(normalizedQuery)) {
          score = 70;
        }
        // Score 60: Correspondance dans la sous-catégorie
        else if (food.alimSsgrpNomFr != null &&
            _normalizeString(food.alimSsgrpNomFr!).contains(normalizedQuery)) {
          score = 60;
        }
        // Score 50: Correspondance partielle dans le nom
        else if (normalizedName.contains(normalizedQuery)) {
          score = 50;
        }

        if (score > 0) {
          scoredFoods.add(MapEntry(food, score));
        }
      }

      // Trier par score décroissant et retourner les aliments
      scoredFoods.sort((a, b) => b.value.compareTo(a.value));
      return scoredFoods.map((entry) => entry.key).toList();
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

  // Fonction utilitaire pour vérifier si une requête correspond à un mot entier
  bool _containsWholeWord(String text, String word) {
    if (text.isEmpty || word.isEmpty) return false;

    // Utilise des délimiteurs de mots (espaces, ponctuation, etc.)
    final RegExp regex = RegExp(r'\b' + RegExp.escape(word) + r'\b');
    return regex.hasMatch(text);
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
