// lib/domain/usecases/filter_foods_by_preferences_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:lym_nutrition/core/error/failures.dart';
import 'package:lym_nutrition/core/usecases/usecase.dart';
import 'package:lym_nutrition/domain/entities/food_item.dart';
import 'package:lym_nutrition/domain/repositories/food_repository.dart';

class FilterFoodsByPreferencesUseCase implements UseCase<List<FoodItem>, FoodsParams> {
  final FoodRepository repository;
  
  FilterFoodsByPreferencesUseCase(this.repository);
  
  @override
  Future<Either<Failure, List<FoodItem>>> call(FoodsParams params) {
    return repository.filterFoodsByPreferences(params.foods);
  }
}

class FoodsParams extends Equatable {
  final List<FoodItem> foods;
  
  const FoodsParams({required this.foods});
  
  @override
  List<Object> get props => [foods];
}