// lib/domain/repositories/auth_repository.dart
import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  /// Get the current authenticated user
  Future<Either<Failure, User?>> getCurrentUser();

  /// Check if user is currently authenticated
  Future<Either<Failure, bool>> isAuthenticated();

  /// Sign in with email and password
  Future<Either<Failure, User>> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  /// Sign up with email and password
  Future<Either<Failure, User>> signUpWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  });

  /// Sign out the current user
  Future<Either<Failure, void>> signOut();

  /// Send password reset email
  Future<Either<Failure, void>> sendPasswordResetEmail({
    required String email,
  });

  /// Send email verification
  Future<Either<Failure, void>> sendEmailVerification();

  /// Check if email verification is completed
  Future<Either<Failure, bool>> isEmailVerified();

  /// Refresh user data
  Future<Either<Failure, User>> refreshUser();

  /// Delete user account
  Future<Either<Failure, void>> deleteAccount();

  /// Update user profile
  Future<Either<Failure, User>> updateProfile({
    String? displayName,
    String? photoURL,
  });

  /// Stream of authentication state changes
  Stream<User?> get authStateChanges;
}
