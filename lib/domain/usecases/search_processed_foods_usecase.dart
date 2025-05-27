// lib/domain/usecases/search_processed_foods_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:lym_nutrition/core/error/failures.dart';
import 'package:lym_nutrition/core/usecases/usecase.dart';
import 'package:lym_nutrition/domain/entities/food_item.dart';
import 'package:lym_nutrition/domain/repositories/food_repository.dart';
import 'package:lym_nutrition/domain/usecases/search_foods_usecase.dart';

class SearchProcessedFoodsUseCase
    implements UseCase<List<FoodItem>, SearchParams> {
  final FoodRepository repository;

  SearchProcessedFoodsUseCase(this.repository);

  @override
  Future<Either<Failure, List<FoodItem>>> call(SearchParams params) {
    return repository.searchProcessedFoods(params.query, brand: params.brand);
  }
}
