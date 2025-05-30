// lib/domain/usecases/reset_user_profile_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:lym_nutrition/core/error/failures.dart';
import 'package:lym_nutrition/core/usecases/usecase.dart';
import 'package:lym_nutrition/domain/repositories/user_profile_repository.dart';

class ResetUserProfileUseCase implements UseCase<bool, NoParams> {
  final UserProfileRepository repository;

  ResetUserProfileUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(NoParams params) {
    return repository.resetUserProfile();
  }
}
