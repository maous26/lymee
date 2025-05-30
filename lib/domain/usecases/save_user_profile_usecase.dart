// lib/domain/usecases/save_user_profile_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:lym_nutrition/core/error/failures.dart';
import 'package:lym_nutrition/core/usecases/usecase.dart';
import 'package:lym_nutrition/domain/entities/user_profile.dart';
import 'package:lym_nutrition/domain/repositories/user_profile_repository.dart';

class SaveUserProfileUseCase implements UseCase<bool, SaveUserProfileParams> {
  final UserProfileRepository repository;

  SaveUserProfileUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(SaveUserProfileParams params) {
    return repository.saveUserProfile(params.userProfile);
  }
}

class SaveUserProfileParams extends Equatable {
  final UserProfile userProfile;

  const SaveUserProfileParams({required this.userProfile});

  @override
  List<Object> get props => [userProfile];
}
