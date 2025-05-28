// lib/data/datasources/local/openfoodfacts_local_data_source.dart
import 'dart:convert';
import 'package:lym_nutrition/data/models/openfoodfacts_food_model.dart';
import 'package:lym_nutrition/core/error/exceptions.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class OpenFoodFactsLocalDataSource {
  /// Récupère tous les aliments transformés qui correspondent à la requête
  ///
  /// Retourne une liste de [OpenFoodFactsFoodModel]
  ///
  /// Lance [CacheException] si aucune donnée n'est disponible
  Future<List<OpenFoodFactsFoodModel>> searchFoods(
    String query, {
    String? brand,
  });

  /// Récupère un aliment par son code-barres
  ///
  /// Retourne un [OpenFoodFactsFoodModel]
  ///
  /// Lance [CacheException] si aucune donnée n'est disponible
  Future<OpenFoodFactsFoodModel> getFoodByBarcode(String barcode);

  /// Sauvegarde un aliment dans la base locale
  Future<void> cacheFood(OpenFoodFactsFoodModel food);

  /// Sauvegarde une liste d'aliments dans la base locale
  Future<void> cacheFoods(List<OpenFoodFactsFoodModel> foods);
}

class OpenFoodFactsLocalDataSourceImpl implements OpenFoodFactsLocalDataSource {
  final SharedPreferences sharedPreferences;
  static const String cachedFoodsKey = 'OPENFOODFACTS_CACHED_FOODS';

  OpenFoodFactsLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<List<OpenFoodFactsFoodModel>> searchFoods(
    String query, {
    String? brand,
  }) async {
    print('🔍 Local OpenFoodFacts search:');
    print('  Query: "$query"');
    print('  Brand: ${brand ?? "none"}');

    try {
      final String? jsonString = sharedPreferences.getString(cachedFoodsKey);

      if (jsonString == null) {
        print('  📭 No cached foods found');
        return [];
      }

      List<dynamic> cachedFoods = jsonDecode(jsonString);
      print('  📦 Found ${cachedFoods.length} cached foods');

      List<OpenFoodFactsFoodModel> foods = cachedFoods
          .map((item) => OpenFoodFactsFoodModel.fromJson(item))
          .toList();

      if (query.isEmpty && brand == null) {
        print('  🎯 Returning all ${foods.length} foods (empty query)');
        return foods;
      }

      // Normalisation de la requête
      final String normalizedQuery = _normalizeString(query);
      print('  🔧 Normalized query: "$normalizedQuery"');

      // Filtrage par requête et marque si spécifiée
      final filteredFoods = foods.where((food) {
        bool matchesQuery = true;

        if (normalizedQuery.isNotEmpty) {
          final String normalizedName = _normalizeString(food.name);
          final String normalizedCategory = _normalizeString(food.category);

          matchesQuery = normalizedName.contains(normalizedQuery) ||
              normalizedCategory.contains(normalizedQuery);

          if (!matchesQuery) {
            print('  ❌ "${food.name}" doesn\'t match query');
            print('    Normalized name: "$normalizedName"');
            print('    Normalized category: "$normalizedCategory"');
          }
        }

        bool matchesBrand = true;

        if (brand != null && brand.isNotEmpty) {
          matchesBrand = food.brand != null &&
              _normalizeString(food.brand!).contains(_normalizeString(brand));

          if (!matchesBrand) {
            print('  ❌ "${food.name}" doesn\'t match brand filter');
          }
        }

        final matches = matchesQuery && matchesBrand;
        if (matches) {
          print('  ✅ "${food.name}" matches criteria');
        }

        return matches;
      }).toList();

      print('  🎯 Final result: ${filteredFoods.length} matching foods');
      return filteredFoods;
    } catch (e) {
      print('  💥 Error in local search: $e');
      throw CacheException(e.toString());
    }
  }

  @override
  Future<OpenFoodFactsFoodModel> getFoodByBarcode(String barcode) async {
    try {
      final String? jsonString = sharedPreferences.getString(cachedFoodsKey);

      if (jsonString == null) {
        throw CacheException('Aucun aliment en cache');
      }

      List<dynamic> cachedFoods = jsonDecode(jsonString);

      final food = cachedFoods.firstWhere(
        (item) => item['code'] == barcode || item['_id'] == barcode,
        orElse: () => throw CacheException('Aliment non trouvé'),
      );

      return OpenFoodFactsFoodModel.fromJson(food);
    } catch (e) {
      throw CacheException(e.toString());
    }
  }

  @override
  Future<void> cacheFood(OpenFoodFactsFoodModel food) async {
    try {
      final String? jsonString = sharedPreferences.getString(cachedFoodsKey);

      List<dynamic> cachedFoods = [];

      if (jsonString != null) {
        cachedFoods = jsonDecode(jsonString);
      }

      // Vérifier si l'aliment existe déjà
      final existingIndex = cachedFoods.indexWhere(
        (item) => item['code'] == food.barcode || item['_id'] == food.barcode,
      );

      if (existingIndex >= 0) {
        // Remplacer l'aliment existant
        cachedFoods[existingIndex] = food.toJson();
      } else {
        // Ajouter le nouvel aliment
        cachedFoods.add(food.toJson());
      }

      // Sauvegarder dans SharedPreferences
      await sharedPreferences.setString(
        cachedFoodsKey,
        jsonEncode(cachedFoods),
      );
    } catch (e) {
      throw CacheException(e.toString());
    }
  }

  @override
  Future<void> cacheFoods(List<OpenFoodFactsFoodModel> foods) async {
    try {
      final String? jsonString = sharedPreferences.getString(cachedFoodsKey);

      List<dynamic> cachedFoods = [];

      if (jsonString != null) {
        cachedFoods = jsonDecode(jsonString);
      }

      // Convertir les nouveaux aliments en JSON
      final newFoodsJson = foods.map((food) => food.toJson()).toList();

      // Mettre à jour les aliments existants et ajouter les nouveaux
      for (var newFood in newFoodsJson) {
        final existingIndex = cachedFoods.indexWhere(
          (item) =>
              item['code'] == newFood['code'] || item['_id'] == newFood['code'],
        );

        if (existingIndex >= 0) {
          cachedFoods[existingIndex] = newFood;
        } else {
          cachedFoods.add(newFood);
        }
      }

      // Sauvegarder dans SharedPreferences
      await sharedPreferences.setString(
        cachedFoodsKey,
        jsonEncode(cachedFoods),
      );
    } catch (e) {
      throw CacheException(e.toString());
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
