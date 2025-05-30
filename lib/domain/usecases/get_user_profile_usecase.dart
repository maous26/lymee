// lib/domain/usecases/get_user_profile_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:lym_nutrition/core/error/failures.dart';
import 'package:lym_nutrition/core/usecases/usecase.dart';
import 'package:lym_nutrition/domain/entities/user_profile.dart';
import 'package:lym_nutrition/domain/repositories/user_profile_repository.dart';

class GetUserProfileUseCase implements UseCase<UserProfile, NoParams> {
  final UserProfileRepository repository;

  GetUserProfileUseCase(this.repository);

  @override
  Future<Either<Failure, UserProfile>> call(NoParams params) {
    return repository.getUserProfile();
  }
}
