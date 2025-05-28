// lib/domain/usecases/add_to_history_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:lym_nutrition/core/error/failures.dart';
import 'package:lym_nutrition/core/usecases/usecase.dart';
import 'package:lym_nutrition/domain/entities/food_item.dart';
import 'package:lym_nutrition/domain/repositories/food_repository.dart';

class AddToHistoryUseCase implements UseCase<bool, FoodParams> {
  final FoodRepository repository;
  
  AddToHistoryUseCase(this.repository);
  
  @override
  Future<Either<Failure, bool>> call(FoodParams params) {
    return repository.addToHistory(params.food);
  }
}

class FoodParams extends Equatable {
  final FoodItem food;
  
  const FoodParams({required this.food});
  
  @override
  List<Object> get props => [food];
}
