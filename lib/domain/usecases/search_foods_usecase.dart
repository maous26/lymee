// lib/domain/usecases/search_foods_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:lym_nutrition/core/error/failures.dart';
import 'package:lym_nutrition/core/usecases/usecase.dart';
import 'package:lym_nutrition/domain/entities/food_item.dart';
import 'package:lym_nutrition/domain/repositories/food_repository.dart';

class SearchFoodsUseCase implements UseCase<List<FoodItem>, SearchParams> {
  final FoodRepository repository;
  
  SearchFoodsUseCase(this.repository);
  
  @override
  Future<Either<Failure, List<FoodItem>>> call(SearchParams params) {
    return repository.searchFoods(params.query, brand: params.brand);
  }
}

class SearchParams extends Equatable {
  final String query;
  final String? brand;
  
  const SearchParams({
    required this.query,
    this.brand,
  });
  
  @override
  List<Object?> get props => [query, brand];
}