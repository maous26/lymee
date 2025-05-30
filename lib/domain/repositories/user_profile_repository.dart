// lib/domain/repositories/user_profile_repository.dart
import 'package:dartz/dartz.dart';
import 'package:lym_nutrition/core/error/failures.dart';
import 'package:lym_nutrition/domain/entities/user_profile.dart';

abstract class UserProfileRepository {
  /// Récupère le profil utilisateur
  ///
  /// Retourne un [UserProfile] ou un [Failure]
  Future<Either<Failure, UserProfile>> getUserProfile();

  /// Vérifie si l'utilisateur a un profil
  ///
  /// Retourne true si l'utilisateur a un profil, false sinon
  Future<Either<Failure, bool>> hasUserProfile();

  /// Sauvegarde le profil utilisateur
  ///
  /// Retourne true si la sauvegarde a réussi, false sinon
  Future<Either<Failure, bool>> saveUserProfile(UserProfile userProfile);

  /// Vérifie si l'onboarding a été complété
  ///
  /// Retourne true si l'onboarding a été complété, false sinon
  Future<Either<Failure, bool>> hasCompletedOnboarding();

  /// Remet à zéro le profil utilisateur
  ///
  /// Retourne true si la remise à zéro a réussi, false sinon
  Future<Either<Failure, bool>> resetUserProfile();
}
