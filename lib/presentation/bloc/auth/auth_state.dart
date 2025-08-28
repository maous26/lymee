// lib/presentation/bloc/auth/auth_state.dart
import 'package:equatable/equatable.dart';

import '../../../domain/entities/user.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Initial state - checking authentication status
class AuthInitial extends AuthState {}

/// Loading state for various auth operations
class AuthLoading extends AuthState {}

/// User is authenticated
class AuthAuthenticated extends AuthState {
  final User user;

  const AuthAuthenticated(this.user);

  @override
  List<Object> get props => [user];
}

/// User is not authenticated
class AuthUnauthenticated extends AuthState {}

/// Sign in process states
class AuthSignInLoading extends AuthState {}

class AuthSignInSuccess extends AuthState {
  final User user;

  const AuthSignInSuccess(this.user);

  @override
  List<Object> get props => [user];
}

class AuthSignInFailure extends AuthState {
  final String message;

  const AuthSignInFailure(this.message);

  @override
  List<Object> get props => [message];
}

/// Sign up process states
class AuthSignUpLoading extends AuthState {}

class AuthSignUpSuccess extends AuthState {
  final User user;

  const AuthSignUpSuccess(this.user);

  @override
  List<Object> get props => [user];
}

class AuthSignUpFailure extends AuthState {
  final String message;

  const AuthSignUpFailure(this.message);

  @override
  List<Object> get props => [message];
}

/// Sign out process states
class AuthSignOutLoading extends AuthState {}

class AuthSignOutSuccess extends AuthState {}

class AuthSignOutFailure extends AuthState {
  final String message;

  const AuthSignOutFailure(this.message);

  @override
  List<Object> get props => [message];
}

/// Password reset states
class AuthPasswordResetLoading extends AuthState {}

class AuthPasswordResetSuccess extends AuthState {
  final String email;

  const AuthPasswordResetSuccess(this.email);

  @override
  List<Object> get props => [email];
}

class AuthPasswordResetFailure extends AuthState {
  final String message;

  const AuthPasswordResetFailure(this.message);

  @override
  List<Object> get props => [message];
}

/// Email verification states
class AuthEmailVerificationLoading extends AuthState {}

class AuthEmailVerificationSuccess extends AuthState {}

class AuthEmailVerificationFailure extends AuthState {
  final String message;

  const AuthEmailVerificationFailure(this.message);

  @override
  List<Object> get props => [message];
}

/// Profile update states
class AuthUpdateProfileLoading extends AuthState {}

class AuthUpdateProfileSuccess extends AuthState {
  final User user;

  const AuthUpdateProfileSuccess(this.user);

  @override
  List<Object> get props => [user];
}

class AuthUpdateProfileFailure extends AuthState {
  final String message;

  const AuthUpdateProfileFailure(this.message);

  @override
  List<Object> get props => [message];
}

/// Account deletion states
class AuthDeleteAccountLoading extends AuthState {}

class AuthDeleteAccountSuccess extends AuthState {}

class AuthDeleteAccountFailure extends AuthState {
  final String message;

  const AuthDeleteAccountFailure(this.message);

  @override
  List<Object> get props => [message];
}

/// General error state
class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object> get props => [message];
}
