// lib/domain/usecases/get_food_history_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:lym_nutrition/core/error/failures.dart';
import 'package:lym_nutrition/core/usecases/usecase.dart';
import 'package:lym_nutrition/domain/entities/food_item.dart';
import 'package:lym_nutrition/domain/repositories/food_repository.dart';

class GetFoodHistoryUseCase implements UseCase<List<FoodItem>, NoParams> {
  final FoodRepository repository;

  GetFoodHistoryUseCase(this.repository);

  @override
  Future<Either<Failure, List<FoodItem>>> call(NoParams params) {
    return repository.getFoodHistory();
  }
}
