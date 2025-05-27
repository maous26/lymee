// lib/domain/repositories/food_repository.dart
import 'package:dartz/dartz.dart';
import 'package:lym_nutrition/core/error/failures.dart';
import 'package:lym_nutrition/domain/entities/food_item.dart';
import 'package:lym_nutrition/domain/entities/user_dietary_preferences.dart';

abstract class FoodRepository {
  /// Recherche des aliments frais (CIQUAL) et transformés (OpenFoodFacts)
  ///
  /// Retourne une liste de [FoodItem] ou un [Failure]
  Future<Either<Failure, List<FoodItem>>> searchFoods(String query,
      {String? brand});

  /// Recherche uniquement des aliments frais (CIQUAL)
  ///
  /// Retourne une liste de [FoodItem] ou un [Failure]
  Future<Either<Failure, List<FoodItem>>> searchFreshFoods(String query);

  /// Recherche uniquement des aliments transformés (OpenFoodFacts)
  ///
  /// Retourne une liste de [FoodItem] ou un [Failure]
  Future<Either<Failure, List<FoodItem>>> searchProcessedFoods(String query,
      {String? brand});

  /// Récupère un aliment par son identifiant (code CIQUAL ou code-barres)
  ///
  /// Retourne un [FoodItem] ou un [Failure]
  Future<Either<Failure, FoodItem>> getFoodById(String id,
      {required String source});

  /// Récupère l'historique des aliments consultés
  ///
  /// Retourne une liste de [FoodItem] ou un [Failure]
  Future<Either<Failure, List<FoodItem>>> getFoodHistory();

  /// Ajoute un aliment à l'historique
  ///
  /// Retourne true en cas de succès ou un [Failure]
  Future<Either<Failure, bool>> addToHistory(FoodItem food);

  /// Récupère les préférences alimentaires de l'utilisateur
  ///
  /// Retourne un [UserDietaryPreferences] ou un [Failure]
  Future<Either<Failure, UserDietaryPreferences>> getUserDietaryPreferences();

  /// Filtre une liste d'aliments selon les préférences alimentaires de l'utilisateur
  ///
  /// Retourne une liste de [FoodItem] filtrée ou un [Failure]
  Future<Either<Failure, List<FoodItem>>> filterFoodsByPreferences(
      List<FoodItem> foods);
}
