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
    try {
      // Recherche dans les deux sources
      final freshFoodsResult = await searchFreshFoods(query);
      final processedFoodsResult =
          await searchProcessedFoods(query, brand: brand);

      // Combiner les résultats
      List<FoodItem> combinedResults = [];

      freshFoodsResult.fold(
        (failure) => null, // Ignorer les échecs ici
        (freshFoods) => combinedResults.addAll(freshFoods),
      );

      processedFoodsResult.fold(
        (failure) => null, // Ignorer les échecs ici
        (processedFoods) => combinedResults.addAll(processedFoods),
      );

      // Filtrer les résultats selon les préférences alimentaires
      final filteredResults = await filterFoodsByPreferences(combinedResults);

      return filteredResults;
    } on Exception catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<FoodItem>>> searchFreshFoods(String query) async {
    try {
      final freshFoods = await ciqualLocalDataSource.searchFoods(query);

      // Filtrer pour ne garder que les produits "brut" (crus/basiques) et le pain
      final brutFoods = freshFoods.where((food) => _isBrutProduct(food)).toList();

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
      return Right([]);
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
        print('  ✅ Using local results (${localResults.length} foods, connected: $isConnected)');
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
        final filteredRemoteResults = await openFoodFactsLocalDataSource.searchFoods(query, brand: brand);
        print('  ✅ Filtered results: ${filteredRemoteResults.length} foods matching "$query"');
        
        return Right(filteredRemoteResults);
      } on ServerException {
        // En cas d'erreur distante, retourner les résultats locaux
        print('  ⚠️ Server error, falling back to local results (${localResults.length} foods)');
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
            return Left(CacheFailure(
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
    final brutKeywords = ['cru', 'crue', 'frais', 'fraiche', 'naturel', 'brut', 'entier', 'non transformé'];
    for (String keyword in brutKeywords) {
      if (foodName.contains(keyword)) {
        return true;
      }
    }
    
    // Exclure les produits clairement transformés/dérivés
    final derivedKeywords = [
      'cuit', 'cuite', 'grillé', 'grillée', 'frit', 'frite', 'bouilli', 'bouillie',
      'rôti', 'rôtie', 'à la vapeur', 'en conserve', 'surgelé', 'surgelée',
      'préparé', 'préparée', 'transformé', 'transformée', 'industriel', 'industrielle',
      'poudre', 'concentré', 'concentrée', 'extrait', 'sirop', 'confiture',
      'compote', 'purée', 'jus', 'sauce', 'crème', 'yaourt', 'fromage',
      'charcuterie', 'saucisse', 'jambon', 'pâté', 'terrine'
    ];
    
    for (String keyword in derivedKeywords) {
      if (foodName.contains(keyword)) {
        return false;
      }
    }
    
    // Pour les fruits et légumes, inclure par défaut s'ils ne contiennent pas de mots-clés de transformation
    if (foodCategory.contains('fruits') || foodCategory.contains('légumes') || 
        foodCategory.contains('légumineuses') || foodCategory.contains('oléagineux')) {
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
