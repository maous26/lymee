// lib/domain/usecases/get_user_dietary_preferences_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:lym_nutrition/core/error/failures.dart';
import 'package:lym_nutrition/core/usecases/usecase.dart';
import 'package:lym_nutrition/domain/entities/user_dietary_preferences.dart';
import 'package:lym_nutrition/domain/repositories/food_repository.dart';

class GetUserDietaryPreferencesUseCase
    implements UseCase<UserDietaryPreferences, NoParams> {
  final FoodRepository repository;

  GetUserDietaryPreferencesUseCase(this.repository);

  @override
  Future<Either<Failure, UserDietaryPreferences>> call(NoParams params) {
    return repository.getUserDietaryPreferences();
  }
}
