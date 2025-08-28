// lib/presentation/bloc/auth/auth_event.dart
import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Event to check current authentication status
class AuthStatusRequested extends AuthEvent {}

/// Event to sign in with email and password
class SignInRequested extends AuthEvent {
  final String email;
  final String password;

  const SignInRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object> get props => [email, password];
}

/// Event to sign up with email and password
class SignUpRequested extends AuthEvent {
  final String email;
  final String password;
  final String? displayName;

  const SignUpRequested({
    required this.email,
    required this.password,
    this.displayName,
  });

  @override
  List<Object?> get props => [email, password, displayName];
}

/// Event to sign out
class SignOutRequested extends AuthEvent {}

/// Event to send password reset email
class PasswordResetRequested extends AuthEvent {
  final String email;

  const PasswordResetRequested({required this.email});

  @override
  List<Object> get props => [email];
}

/// Event to send email verification
class EmailVerificationRequested extends AuthEvent {}

/// Event to refresh user data
class UserRefreshRequested extends AuthEvent {}

/// Event triggered by auth state changes from repository
class AuthUserChanged extends AuthEvent {
  final dynamic user; // Can be User or null

  const AuthUserChanged(this.user);

  @override
  List<Object?> get props => [user];
}

/// Event to clear auth errors
class AuthErrorCleared extends AuthEvent {}

/// Event to delete user account
class DeleteAccountRequested extends AuthEvent {}

/// Event to update user profile
class UpdateProfileRequested extends AuthEvent {
  final String? displayName;
  final String? photoURL;

  const UpdateProfileRequested({
    this.displayName,
    this.photoURL,
  });

  @override
  List<Object?> get props => [displayName, photoURL];
}
