// lib/presentation/bloc/auth/auth_bloc.dart
import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/error/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/usecases/auth/get_current_user_usecase.dart';
import '../../../domain/usecases/auth/is_authenticated_usecase.dart';
import '../../../domain/usecases/auth/sign_in_usecase.dart';
import '../../../domain/usecases/auth/sign_out_usecase.dart';
import '../../../domain/usecases/auth/sign_up_usecase.dart';
import '../../../domain/usecases/auth/send_password_reset_usecase.dart';
import '../../../domain/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final GetCurrentUserUseCase getCurrentUser;
  final IsAuthenticatedUseCase isAuthenticated;
  final SignInUseCase signIn;
  final SignUpUseCase signUp;
  final SignOutUseCase signOut;
  final SendPasswordResetUseCase sendPasswordReset;
  final AuthRepository authRepository;

  late StreamSubscription<User?> _authStateSubscription;

  AuthBloc({
    required this.getCurrentUser,
    required this.isAuthenticated,
    required this.signIn,
    required this.signUp,
    required this.signOut,
    required this.sendPasswordReset,
    required this.authRepository,
  }) : super(AuthInitial()) {
    // Listen to auth state changes from repository
    _authStateSubscription = authRepository.authStateChanges.listen(
      (user) => add(AuthUserChanged(user)),
    );

    on<AuthStatusRequested>(_onAuthStatusRequested);
    on<SignInRequested>(_onSignInRequested);
    on<SignUpRequested>(_onSignUpRequested);
    on<SignOutRequested>(_onSignOutRequested);
    on<PasswordResetRequested>(_onPasswordResetRequested);
    on<EmailVerificationRequested>(_onEmailVerificationRequested);
    on<UserRefreshRequested>(_onUserRefreshRequested);
    on<AuthUserChanged>(_onAuthUserChanged);
    on<AuthErrorCleared>(_onAuthErrorCleared);
    on<DeleteAccountRequested>(_onDeleteAccountRequested);
    on<UpdateProfileRequested>(_onUpdateProfileRequested);
  }

  @override
  Future<void> close() {
    _authStateSubscription.cancel();
    return super.close();
  }

  Future<void> _onAuthStatusRequested(
    AuthStatusRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await getCurrentUser(NoParams());

    result.fold(
      (failure) => emit(AuthError(_mapFailureToMessage(failure))),
      (user) {
        if (user != null) {
          emit(AuthAuthenticated(user));
        } else {
          emit(AuthUnauthenticated());
        }
      },
    );
  }

  Future<void> _onSignInRequested(
    SignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthSignInLoading());

    final result = await signIn(
      SignInParams(email: event.email, password: event.password),
    );

    result.fold(
      (failure) => emit(AuthSignInFailure(_mapFailureToMessage(failure))),
      (user) => emit(AuthSignInSuccess(user)),
    );
  }

  Future<void> _onSignUpRequested(
    SignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthSignUpLoading());

    final result = await signUp(
      SignUpParams(
        email: event.email,
        password: event.password,
        displayName: event.displayName,
      ),
    );

    result.fold(
      (failure) => emit(AuthSignUpFailure(_mapFailureToMessage(failure))),
      (user) => emit(AuthSignUpSuccess(user)),
    );
  }

  Future<void> _onSignOutRequested(
    SignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthSignOutLoading());

    final result = await signOut(NoParams());

    result.fold(
      (failure) => emit(AuthSignOutFailure(_mapFailureToMessage(failure))),
      (_) => emit(AuthSignOutSuccess()),
    );
  }

  Future<void> _onPasswordResetRequested(
    PasswordResetRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthPasswordResetLoading());

    final result = await sendPasswordReset(
      SendPasswordResetParams(email: event.email),
    );

    result.fold(
      (failure) =>
          emit(AuthPasswordResetFailure(_mapFailureToMessage(failure))),
      (_) => emit(AuthPasswordResetSuccess(event.email)),
    );
  }

  Future<void> _onEmailVerificationRequested(
    EmailVerificationRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthEmailVerificationLoading());

    final result = await authRepository.sendEmailVerification();

    result.fold(
      (failure) =>
          emit(AuthEmailVerificationFailure(_mapFailureToMessage(failure))),
      (_) => emit(AuthEmailVerificationSuccess()),
    );
  }

  Future<void> _onUserRefreshRequested(
    UserRefreshRequested event,
    Emitter<AuthState> emit,
  ) async {
    final result = await authRepository.refreshUser();

    result.fold(
      (failure) => emit(AuthError(_mapFailureToMessage(failure))),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  void _onAuthUserChanged(
    AuthUserChanged event,
    Emitter<AuthState> emit,
  ) {
    if (event.user != null) {
      emit(AuthAuthenticated(event.user as User));
    } else {
      emit(AuthUnauthenticated());
    }
  }

  void _onAuthErrorCleared(
    AuthErrorCleared event,
    Emitter<AuthState> emit,
  ) {
    // Check current auth status after clearing error
    add(AuthStatusRequested());
  }

  Future<void> _onDeleteAccountRequested(
    DeleteAccountRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthDeleteAccountLoading());

    final result = await authRepository.deleteAccount();

    result.fold(
      (failure) =>
          emit(AuthDeleteAccountFailure(_mapFailureToMessage(failure))),
      (_) => emit(AuthDeleteAccountSuccess()),
    );
  }

  Future<void> _onUpdateProfileRequested(
    UpdateProfileRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthUpdateProfileLoading());

    final result = await authRepository.updateProfile(
      displayName: event.displayName,
      photoURL: event.photoURL,
    );

    result.fold(
      (failure) =>
          emit(AuthUpdateProfileFailure(_mapFailureToMessage(failure))),
      (user) => emit(AuthUpdateProfileSuccess(user)),
    );
  }

  String _mapFailureToMessage(Failure failure) {
    if (failure is ServerFailure) {
      return failure.message;
    } else if (failure is CacheFailure) {
      return failure.message;
    } else if (failure is NetworkFailure) {
      return failure.message;
    } else {
      return failure.message;
    }
  }

  // Helper getters for checking current state
  bool get isUserAuthenticated => state is AuthAuthenticated;

  User? get currentUser {
    final currentState = state;
    if (currentState is AuthAuthenticated) {
      return currentState.user;
    }
    return null;
  }
}
