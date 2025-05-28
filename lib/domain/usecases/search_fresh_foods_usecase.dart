// lib/domain/usecases/search_fresh_foods_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:lym_nutrition/core/error/failures.dart';
import 'package:lym_nutrition/core/usecases/usecase.dart';
import 'package:lym_nutrition/domain/entities/food_item.dart';
import 'package:lym_nutrition/domain/repositories/food_repository.dart';

class SearchFreshFoodsUseCase implements UseCase<List<FoodItem>, QueryParams> {
  final FoodRepository repository;
  
  SearchFreshFoodsUseCase(this.repository);
  
  @override
  Future<Either<Failure, List<FoodItem>>> call(QueryParams params) {
    return repository.searchFreshFoods(params.query);
  }
}

class QueryParams extends Equatable {
  final String query;
  
  const QueryParams({required this.query});
  
  @override
  List<Object> get props => [query];
}