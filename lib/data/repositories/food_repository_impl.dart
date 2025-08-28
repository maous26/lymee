// lib/data/repositories/food_repository_impl.dart
import 'package:dartz/dartz.dart';
import 'package:lym_nutrition/core/error/exceptions.dart'
    hide Failure, ServerFailure, CacheFailure, DataParsingFailure;
import 'package:lym_nutrition/core/error/failures.dart';
import 'package:lym_nutrition/core/network/network_info.dart';
import 'package:lym_nutrition/data/datasources/local/ciqual_local_data_source.dart';
import 'package:lym_nutrition/data/datasources/local/openfoodfacts_local_data_source.dart';
import 'package:lym_nutrition/data/datasources/local/food_history_data_source.dart';
import 'package:lym_nutrition/data/datasources/local/user_preferences_data_source.dart';
import 'package:lym_nutrition/data/datasources/remote/openfoodfacts_remote_data_source.dart';
import 'package:lym_nutrition/data/models/openfoodfacts_food_model.dart';
import 'package:lym_nutrition/domain/entities/food_item.dart';
import 'package:lym_nutrition/domain/entities/user_dietary_preferences.dart';
import 'package:lym_nutrition/domain/repositories/food_repository.dart';

class FoodRepositoryImpl implements FoodRepository {
  final CiqualLocalDataSource ciqualLocalDataSource;
  final OpenFoodFactsLocalDataSource openFoodFactsLocalDataSource;
  final OpenFoodFactsRemoteDataSource openFoodFactsRemoteDataSource;
  final FoodHistoryDataSource foodHistoryDataSource;
  final UserPreferencesDataSource userPreferencesDataSource;
  final NetworkInfo networkInfo;

  FoodRepositoryImpl({
    required this.ciqualLocalDataSource,
    required this.openFoodFactsLocalDataSource,
    required this.openFoodFactsRemoteDataSource,
    required this.foodHistoryDataSource,
    required this.userPreferencesDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<FoodItem>>> searchFoods(String query,
      {String? brand}) async {
    print('\n🔍 UNIFIED PRECISE SEARCH:');
    print('  Query: "$query"');
    print('  Brand: ${brand ?? "none"}');

    try {
      // New precise search logic
      final results = await _performPreciseSearch(query, brand);

      // Apply user preferences filtering
      final filteredResults = await filterFoodsByPreferences(results);

      return filteredResults;
    } on Exception catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  /// Implements precise search logic with specific rules:
  /// - "tomate" -> only tomatoes (raw CIQUAL products)
  /// - "sauce tomate" -> tomato sauce products
  /// - "sauce" -> all sauce products
  /// - Brand searches work by brand name
  Future<List<FoodItem>> _performPreciseSearch(
      String query, String? brand) async {
    print('  🎯 Applying precise search rules...');

    if (query.isEmpty && brand == null) {
      print('  ⚠️ Empty query, returning empty list');
      return [];
    }

    List<FoodItem> results = [];

    // Rule 1: Brand-only search - return all products from that brand
    if (brand != null && brand.isNotEmpty && query.isEmpty) {
      print('  📱 Brand-only search for: "$brand"');
      final processedResults = await _searchProcessedByBrand(brand);
      results.addAll(processedResults);
      print('  🎯 Brand search result: ${results.length} products');
      return results;
    }

    // Rule 2: Query contains multiple words - look for exact combinations
    final queryWords = query.toLowerCase().trim().split(RegExp(r'\s+'));
    print('  📝 Query words: $queryWords');

    if (queryWords.length == 1) {
      // Single word search - prioritize basic products
      print('  🥕 Single word search - prioritizing basic products');

      // First search in CIQUAL for basic products
      final freshResults = await _searchFreshBasicProducts(query);
      results.addAll(freshResults);
      print('  📱 Basic products found: ${freshResults.length}');

      // If query is a general term like "sauce", also search processed foods
      if (_isGeneralTerm(query)) {
        print('  🏭 General term detected - searching processed foods');
        final processedResults = await _searchProcessedProducts(query, brand);
        results.addAll(processedResults);
        print('  🏭 Processed products found: ${processedResults.length}');
      }
      // IMPORTANT: If no basic products found OR if it's a brand name, also search processed foods
      else if (freshResults.isEmpty || _isBrandName(query)) {
        if (_isBrandName(query)) {
          print(
              '  🏷️ Brand name detected - searching processed foods for "$query"');
          // When query is a brand name, search both ways:
          // 1. Query as product name, brand as brand parameter
          final processedResults1 =
              await _searchProcessedProducts(query, brand);
          // 2. Query as brand parameter, empty product search
          final processedResults2 = await _searchProcessedProducts('', query);
          results.addAll(processedResults1);
          results.addAll(processedResults2);
          print(
              '  🏭 Processed products found: ${processedResults1.length + processedResults2.length}');
        } else {
          print(
              '  🏷️ No basic products found - searching processed foods for brands/products');
          final processedResults = await _searchProcessedProducts(query, brand);
          results.addAll(processedResults);
          print('  🏭 Processed products found: ${processedResults.length}');
        }
      }
    } else {
      // Multi-word search - look for specific combinations
      print('  🍕 Multi-word search - looking for specific combinations');

      // Search both sources for exact combinations
      final freshResults = await _searchFreshBasicProducts(query);
      final processedResults = await _searchProcessedProducts(query, brand);

      results.addAll(freshResults);
      results.addAll(processedResults);

      print('  📱 Fresh results: ${freshResults.length}');
      print('  🏭 Processed results: ${processedResults.length}');
    }

    // Remove duplicates based on ID
    final seen = <String>{};
    results = results.where((food) => seen.add(food.id)).toList();

    print('  ✅ Final results after deduplication: ${results.length}');
    return results;
  }

  /// Check if a term is general (like "sauce", "pizza", etc.)
  bool _isGeneralTerm(String query) {
    final generalTerms = [
      'sauce',
      'pizza',
      'pain',
      'pâtes',
      'soupe',
      'salade',
      'fromage',
      'yaourt',
      'biscuit',
      'chocolat',
      'gâteau',
      'tarte',
      'jus',
      'boisson',
      'thé',
      'café',
      'eau',
      'lait'
    ];

    // Pour "riz", on veut d'abord privilégier les produits de base CIQUAL
    // donc on ne le considère pas comme un terme général
    final String normalizedQuery = query.toLowerCase().trim();

    return generalTerms.any((term) =>
        normalizedQuery.contains(term) || term.contains(normalizedQuery));
  }

  /// Check if a term is a brand name
  bool _isBrandName(String query) {
    final brandNames = [
      'nestlé',
      'nestle',
      'danone',
      'coca',
      'coca-cola',
      'ferrero',
      'nutella',
      'lu',
      'president',
      'président',
      'lindt',
      'evian',
      'carrefour',
      'lidl',
      'auchan',
      'kellogg',
      'kelloggs',
      'mcdonald',
      'mcdonalds',
      'pringles',
      'haribo',
      'yoplait',
      'activia',
      'actimel',
      'buitoni',
      'maggi',
      'knorr',
      'lipton',
      'nescafé',
      'nescafe',
      'ricore',
      'banania',
      'bonne-maman',
      'bonne maman',
      'philadelphia',
      'babybel',
      'caprice',
      'vache-qui-rit',
      'vache qui rit',
      'orangina',
      'perrier',
      'vittel',
      'contrex',
      'hépar',
      'hepar',
      'badoit',
      'san pellegrino',
      'san-pellegrino'
    ];

    final String normalizedQuery = query.toLowerCase().trim();
    return brandNames.any((brand) =>
        normalizedQuery == brand ||
        normalizedQuery.contains(brand) ||
        brand.contains(normalizedQuery));
  }

  /// Check if a food item is a basic/raw product (for single word searches)
  bool _isBasicProduct(FoodItem food) {
    final String foodName = food.name.toLowerCase();
    final String foodCategory = food.category.toLowerCase();

    // Prioritize raw/basic keywords
    final basicKeywords = [
      'cru',
      'crue',
      'frais',
      'fraiche',
      'naturel',
      'brut',
      'entier',
      'non transformé',
      'nature',
      'simple'
    ];

    for (String keyword in basicKeywords) {
      if (foodName.contains(keyword)) {
        return true;
      }
    }

    // Exclude clearly processed products
    final processedKeywords = [
      'cuit',
      'cuite',
      'grillé',
      'grillée',
      'frit',
      'frite',
      'bouilli',
      'bouillie',
      'rôti',
      'rôtie',
      'préparé',
      'préparée',
      'transformé',
      'transformée',
      'industriel',
      'industrielle',
      'en conserve',
      'surgelé',
      'surgelée',
      'poudre',
      'concentré',
      'extrait',
      'sirop',
      'confiture',
      'compote',
      'purée',
      'sauce',
      'crème',
      'pâté',
      'terrine'
    ];

    for (String keyword in processedKeywords) {
      if (foodName.contains(keyword)) {
        return false;
      }
    }

    // Include basic categories by default (fruits, vegetables, etc.)
    if (foodCategory.contains('fruits') ||
        foodCategory.contains('légumes') ||
        foodCategory.contains('légumineuses') ||
        foodCategory.contains('oléagineux') ||
        foodCategory.contains('céréales') ||
        foodCategory.contains('viande') ||
        foodCategory.contains('poisson')) {
      return true;
    }

    // Default to basic if no processing indicators found
    return true;
  }

  /// Search for basic/raw products in CIQUAL
  Future<List<FoodItem>> _searchFreshBasicProducts(String query) async {
    try {
      final freshFoods = await ciqualLocalDataSource.searchFoods(query);
      // Filter for basic products only
      return freshFoods.where((food) => _isBasicProduct(food)).toList();
    } catch (e) {
      print('  ⚠️ Error searching fresh products: $e');
      return [];
    }
  }

  /// Search processed products with brand filtering
  Future<List<FoodItem>> _searchProcessedProducts(
      String query, String? brand) async {
    try {
      // Use the existing processed food search
      final result = await searchProcessedFoods(query, brand: brand);
      return result.fold(
        (failure) => <FoodItem>[],
        (foods) => foods,
      );
    } catch (e) {
      print('  ⚠️ Error searching processed products: $e');
      return [];
    }
  }

  /// Search processed products by brand only
  Future<List<FoodItem>> _searchProcessedByBrand(String brand) async {
    try {
      final result = await searchProcessedFoods('', brand: brand);
      return result.fold(
        (failure) => <FoodItem>[],
        (foods) => foods,
      );
    } catch (e) {
      print('  ⚠️ Error searching by brand: $e');
      return [];
    }
  }

  @override
  Future<Either<Failure, List<FoodItem>>> searchFreshFoods(String query) async {
    try {
      final freshFoods = await ciqualLocalDataSource.searchFoods(query);

      // Filtrer pour ne garder que les produits "brut" (crus/basiques) et le pain
      final brutFoods =
          freshFoods.where((food) => _isBrutProduct(food)).toList();

      return Right(brutFoods);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } on Exception catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<FoodItem>>> searchProcessedFoods(String query,
      {String? brand}) async {
    print('\n🚀 Starting processed foods search:');
    print('  Query: "$query"');
    print('  Brand: ${brand ?? "none"}');

    if (query.isEmpty && brand == null) {
      print('  ⚠️ Empty query and no brand, returning empty list');
      return const Right([]);
    }

    try {
      // Recherche d'abord dans le cache local
      print('  📱 Searching in local cache...');
      final localResults =
          await openFoodFactsLocalDataSource.searchFoods(query, brand: brand);
      print('  📱 Local results: ${localResults.length} foods');

      // Si résultats locaux suffisants ou pas de connexion, retourner les résultats locaux
      final isConnected = await networkInfo.isConnected;
      print('  🌐 Network connected: $isConnected');

      if (localResults.length >= 10 || !isConnected) {
        print(
            '  ✅ Using local results (${localResults.length} foods, connected: $isConnected)');
        return Right(localResults);
      }

      // Sinon, rechercher en ligne
      print('  🌐 Searching online...');
      try {
        final remoteResults = await openFoodFactsRemoteDataSource
            .searchFoods(query, brand: brand);
        print('  🌐 Remote results: ${remoteResults.length} foods');

        // Mettre en cache les résultats distants
        if (remoteResults.isNotEmpty) {
          print('  💾 Caching ${remoteResults.length} remote results...');
          await openFoodFactsLocalDataSource.cacheFoods(remoteResults);
          print('  💾 Cached successfully');
        }

        // ✅ FIX: Apply local filtering to remote results to ensure they match the query
        print('  🔍 Filtering remote results by query...');
        final filteredRemoteResults =
            await openFoodFactsLocalDataSource.searchFoods(query, brand: brand);
        print(
            '  ✅ Filtered results: ${filteredRemoteResults.length} foods matching "$query"');

        return Right(filteredRemoteResults);
      } on ServerException {
        // En cas d'erreur distante, retourner les résultats locaux
        print(
            '  ⚠️ Server error, falling back to local results (${localResults.length} foods)');
        return Right(localResults);
      }
    } on CacheException catch (e) {
      print('  💥 Cache error: ${e.message}');
      // En cas d'erreur de cache, essayer la recherche en ligne
      if (await networkInfo.isConnected) {
        try {
          print('  🌐 Cache failed, trying online search...');
          final remoteResults = await openFoodFactsRemoteDataSource
              .searchFoods(query, brand: brand);
          print('  🌐 Online fallback results: ${remoteResults.length} foods');

          // Mettre en cache les résultats distants
          if (remoteResults.isNotEmpty) {
            await openFoodFactsLocalDataSource.cacheFoods(remoteResults);
          }

          return Right(remoteResults);
        } on ServerException catch (e) {
          print('  💥 Online fallback also failed: ${e.message}');
          return Left(ServerFailure(e.message));
        }
      } else {
        print('  💥 No network connection and cache failed');
        return Left(CacheFailure(e.message));
      }
    } on Exception catch (e) {
      print('  💥 Unexpected error: $e');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, FoodItem>> getFoodById(String id,
      {required String source}) async {
    try {
      if (source == 'ciqual') {
        final food = await ciqualLocalDataSource.getFoodByCode(id);
        return Right(food);
      } else if (source == 'openfoodfacts') {
        try {
          // Essayer d'abord en local
          final food = await openFoodFactsLocalDataSource.getFoodByBarcode(id);
          return Right(food);
        } on CacheException catch (_) {
          // Si pas trouvé en local, chercher en ligne
          if (await networkInfo.isConnected) {
            final food =
                await openFoodFactsRemoteDataSource.getFoodByBarcode(id);
            // Mettre en cache
            await openFoodFactsLocalDataSource.cacheFood(food);
            return Right(food);
          } else {
            return const Left(CacheFailure(
                'Produit non trouvé en cache et pas de connexion internet'));
          }
        }
      } else {
        return Left(CacheFailure('Source invalide: $source'));
      }
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on Exception catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<FoodItem>>> getFoodHistory() async {
    try {
      final historyItems = await foodHistoryDataSource.getHistory();

      List<FoodItem> foods = [];

      for (var item in historyItems) {
        if (item['source'] == 'ciqual') {
          try {
            final food = await ciqualLocalDataSource.getFoodByCode(item['id']);
            foods.add(food);
          } catch (_) {
            // Ignorer les erreurs individuelles
          }
        } else if (item['source'] == 'openfoodfacts') {
          try {
            final food =
                await openFoodFactsLocalDataSource.getFoodByBarcode(item['id']);
            foods.add(food);
          } catch (_) {
            // Ignorer les erreurs individuelles
          }
        }
      }

      return Right(foods);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } on Exception catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> addToHistory(FoodItem food) async {
    try {
      await foodHistoryDataSource.addToHistory(food);
      return const Right(true);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } on Exception catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserDietaryPreferences>>
      getUserDietaryPreferences() async {
    try {
      final preferences =
          await userPreferencesDataSource.getDietaryPreferences();
      return Right(preferences);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } on Exception catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<FoodItem>>> filterFoodsByPreferences(
      List<FoodItem> foods) async {
    try {
      final preferencesResult = await getUserDietaryPreferences();

      return preferencesResult.fold(
        (failure) =>
            Right(foods), // En cas d'échec, retourner la liste non filtrée
        (preferences) {
          if (!preferences.isVegetarian &&
              !preferences.isVegan &&
              !preferences.isHalal &&
              !preferences.isKosher &&
              !preferences.isGlutenFree &&
              !preferences.isLactoseFree &&
              preferences.allergies.isEmpty) {
            return Right(foods); // Pas de préférences à appliquer
          }

          // Filtrer selon les préférences
          List<FoodItem> filteredFoods = foods.where((food) {
            // Exclusions pour végétarien
            if (preferences.isVegetarian && _containsMeat(food)) {
              return false;
            }

            // Exclusions pour végétalien
            if (preferences.isVegan && _containsAnimalProducts(food)) {
              return false;
            }

            // Exclusions pour halal
            if (preferences.isHalal && _containsPork(food)) {
              return false;
            }

            // Exclusions pour casher
            if (preferences.isKosher && _isNotKosher(food)) {
              return false;
            }

            // Exclusions pour sans gluten
            if (preferences.isGlutenFree && _containsGluten(food)) {
              return false;
            }

            // Exclusions pour sans lactose
            if (preferences.isLactoseFree && _containsLactose(food)) {
              return false;
            }

            // Exclusions pour allergies
            for (String allergen in preferences.allergies) {
              if (_containsAllergen(food, allergen)) {
                return false;
              }
            }

            return true;
          }).toList();

          return Right(filteredFoods);
        },
      );
    } on Exception catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  // Fonctions utilitaires pour filtrer les aliments selon les préférences

  bool _isBrutProduct(FoodItem food) {
    // Vérifier si l'aliment est un produit "brut" (cru/basique) ou du pain
    final String foodName = food.name.toLowerCase();
    final String foodCategory = food.category.toLowerCase();

    // Inclure le pain même s'il est transformé
    final breadKeywords = ['pain', 'baguette', 'croissant', 'brioche', 'miche'];
    for (String keyword in breadKeywords) {
      if (foodName.contains(keyword)) {
        return true;
      }
    }

    // Mots-clés indiquant des produits bruts/crus
    final brutKeywords = [
      'cru',
      'crue',
      'frais',
      'fraiche',
      'naturel',
      'brut',
      'entier',
      'non transformé'
    ];
    for (String keyword in brutKeywords) {
      if (foodName.contains(keyword)) {
        return true;
      }
    }

    // Exclure les produits clairement transformés/dérivés
    final derivedKeywords = [
      'cuit',
      'cuite',
      'grillé',
      'grillée',
      'frit',
      'frite',
      'bouilli',
      'bouillie',
      'rôti',
      'rôtie',
      'à la vapeur',
      'en conserve',
      'surgelé',
      'surgelée',
      'préparé',
      'préparée',
      'transformé',
      'transformée',
      'industriel',
      'industrielle',
      'poudre',
      'concentré',
      'concentrée',
      'extrait',
      'sirop',
      'confiture',
      'compote',
      'purée',
      'jus',
      'sauce',
      'crème',
      'yaourt',
      'fromage',
      'charcuterie',
      'saucisse',
      'jambon',
      'pâté',
      'terrine'
    ];

    for (String keyword in derivedKeywords) {
      if (foodName.contains(keyword)) {
        return false;
      }
    }

    // Pour les fruits et légumes, inclure par défaut s'ils ne contiennent pas de mots-clés de transformation
    if (foodCategory.contains('fruits') ||
        foodCategory.contains('légumes') ||
        foodCategory.contains('légumineuses') ||
        foodCategory.contains('oléagineux')) {
      return true;
    }

    // Pour les viandes, poissons et autres, être plus restrictif et exiger des mots-clés "brut"
    return false;
  }

  bool _containsMeat(FoodItem food) {
    // Vérifier si l'aliment contient de la viande
    final meatCategories = [
      'viande',
      'volaille',
      'charcuterie',
      'gibier',
      'porc',
      'bœuf',
      'agneau',
      'poulet',
      'dinde',
      'canard',
      'jambon',
      'saucisse',
      'bacon'
    ];

    final String foodCategory = food.category.toLowerCase();
    final String foodName = food.name.toLowerCase();

    for (String category in meatCategories) {
      if (foodCategory.contains(category) || foodName.contains(category)) {
        return true;
      }
    }

    return false;
  }

  bool _containsAnimalProducts(FoodItem food) {
    // Vérifier si l'aliment contient des produits d'origine animale
    if (_containsMeat(food)) {
      return true;
    }

    final animalProducts = [
      'lait',
      'fromage',
      'beurre',
      'crème',
      'yaourt',
      'œuf',
      'miel',
      'poisson',
      'fruits de mer',
      'crevette',
      'moule',
      'huître',
      'crabe',
      'homard',
      'gelatin',
      'gélatine'
    ];

    final String foodCategory = food.category.toLowerCase();
    final String foodName = food.name.toLowerCase();

    for (String product in animalProducts) {
      if (foodCategory.contains(product) || foodName.contains(product)) {
        return true;
      }
    }

    return false;
  }

  bool _containsPork(FoodItem food) {
    // Vérifier si l'aliment contient du porc
    final porkProducts = [
      'porc',
      'jambon',
      'bacon',
      'lard',
      'saucisson',
      'chorizo',
      'salami',
      'andouille',
      'andouillette',
      'boudin',
      'pâté',
      'rillettes',
      'gelatin',
      'gélatine'
    ];

    final String foodCategory = food.category.toLowerCase();
    final String foodName = food.name.toLowerCase();

    for (String product in porkProducts) {
      if (foodCategory.contains(product) || foodName.contains(product)) {
        return true;
      }
    }

    return false;
  }

  bool _isNotKosher(FoodItem food) {
    // Vérifier si l'aliment n'est pas casher
    if (_containsPork(food)) {
      return true;
    }

    final nonKosherProducts = [
      'fruits de mer',
      'crevette',
      'moule',
      'huître',
      'crabe',
      'homard',
      'calamar',
      'poulpe',
      'escargot',
      'anguille',
      'requin',
      'raie'
    ];

    final String foodCategory = food.category.toLowerCase();
    final String foodName = food.name.toLowerCase();

    for (String product in nonKosherProducts) {
      if (foodCategory.contains(product) || foodName.contains(product)) {
        return true;
      }
    }

    return false;
  }

  bool _containsGluten(FoodItem food) {
    // Vérifier si l'aliment contient du gluten
    final glutenProducts = [
      'blé',
      'orge',
      'seigle',
      'avoine',
      'épeautre',
      'kamut',
      'triticale',
      'pain',
      'pâtes',
      'gâteau',
      'biscuit',
      'farine',
      'couscous',
      'boulgour',
      'chapelure',
      'pâtisserie',
      'pizza',
      'bière'
    ];

    final String foodCategory = food.category.toLowerCase();
    final String foodName = food.name.toLowerCase();

    for (String product in glutenProducts) {
      if (foodCategory.contains(product) || foodName.contains(product)) {
        return true;
      }
    }

    return false;
  }

  bool _containsLactose(FoodItem food) {
    // Vérifier si l'aliment contient du lactose
    final lactoseProducts = [
      'lait',
      'fromage',
      'beurre',
      'crème',
      'yaourt',
      'yogourt',
      'glace',
      'crème glacée',
      'petit-lait',
      'lactosérum',
      'lactose',
      'caséine',
      'margarine',
      'crème fraîche',
      'mascarpone',
      'ricotta',
      'mozzarella'
    ];

    final String foodCategory = food.category.toLowerCase();
    final String foodName = food.name.toLowerCase();

    for (String product in lactoseProducts) {
      if (foodCategory.contains(product) || foodName.contains(product)) {
        return true;
      }
    }

    return false;
  }

  bool _containsAllergen(FoodItem food, String allergen) {
    // Vérifier si l'aliment contient un allergène spécifique
    final String foodCategory = food.category.toLowerCase();
    final String foodName = food.name.toLowerCase();
    final String allergenLower = allergen.toLowerCase();

    // Vérifier si l'allergène est présent dans le nom ou la catégorie
    if (foodCategory.contains(allergenLower) ||
        foodName.contains(allergenLower)) {
      return true;
    }

    // Vérifier les allergènes dans OpenFoodFacts
    if (food is OpenFoodFactsFoodModel && food.allergens != null) {
      for (String foodAllergen in food.allergens!) {
        if (foodAllergen.toLowerCase().contains(allergenLower)) {
          return true;
        }
      }
    }

    return false;
  }
}
