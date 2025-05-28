// lib/domain/usecases/get_food_by_id_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:lym_nutrition/core/error/failures.dart';
import 'package:lym_nutrition/core/usecases/usecase.dart';
import 'package:lym_nutrition/domain/entities/food_item.dart';
import 'package:lym_nutrition/domain/repositories/food_repository.dart';

class GetFoodByIdUseCase implements UseCase<FoodItem, FoodIdParams> {
  final FoodRepository repository;
  
  GetFoodByIdUseCase(this.repository);
  
  @override
  Future<Either<Failure, FoodItem>> call(FoodIdParams params) {
    return repository.getFoodById(params.id, source: params.source);
  }
}

class FoodIdParams extends Equatable {
  final String id;
  final String source;
  
  const FoodIdParams({
    required this.id,
    required this.source,
  });
  
  @override
  List<Object> get props => [id, source];
}
