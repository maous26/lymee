// lib/data/repositories/user_profile_repository_impl.dart
import 'package:dartz/dartz.dart';
import 'package:lym_nutrition/core/error/failures.dart';
import 'package:lym_nutrition/data/datasources/local/user_profile_data_source.dart';
import 'package:lym_nutrition/domain/entities/user_profile.dart';
import 'package:lym_nutrition/domain/repositories/user_profile_repository.dart';

class UserProfileRepositoryImpl implements UserProfileRepository {
  final UserProfileDataSource localDataSource;

  UserProfileRepositoryImpl({
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, UserProfile>> getUserProfile() async {
    try {
      final userProfile = await localDataSource.getUserProfile();
      return Right(userProfile);
    } catch (e) {
      return Left(CacheFailure('Failed to get user profile: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, bool>> saveUserProfile(UserProfile userProfile) async {
    try {
      await localDataSource.saveUserProfile(userProfile);
      return const Right(true);
    } catch (e) {
      return Left(CacheFailure('Failed to save user profile: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, bool>> hasUserProfile() async {
    try {
      final hasProfile = await localDataSource.hasUserProfile();
      return Right(hasProfile);
    } catch (e) {
      return Left(
          CacheFailure('Failed to check user profile: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, bool>> hasCompletedOnboarding() async {
    try {
      final hasCompleted = await localDataSource.hasCompletedOnboarding();
      return Right(hasCompleted);
    } catch (e) {
      return Left(
          CacheFailure('Failed to check onboarding status: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, bool>> resetUserProfile() async {
    try {
      await localDataSource.resetUserProfile();
      return const Right(true);
    } catch (e) {
      return Left(
          CacheFailure('Failed to reset user profile: ${e.toString()}'));
    }
  }
}
