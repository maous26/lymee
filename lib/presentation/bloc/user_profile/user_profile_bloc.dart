// lib/presentation/bloc/user_profile/user_profile_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lym_nutrition/core/usecases/usecase.dart';
import 'package:lym_nutrition/domain/usecases/get_user_profile_usecase.dart';
import 'package:lym_nutrition/domain/usecases/has_completed_onboarding_usecase.dart';
import 'package:lym_nutrition/domain/usecases/has_user_profile_usecase.dart';
import 'package:lym_nutrition/domain/usecases/reset_user_profile_usecase.dart';
import 'package:lym_nutrition/domain/usecases/save_user_profile_usecase.dart';
import 'package:lym_nutrition/presentation/bloc/user_profile/user_profile_event.dart';
import 'package:lym_nutrition/presentation/bloc/user_profile/user_profile_state.dart';

class UserProfileBloc extends Bloc<UserProfileEvent, UserProfileState> {
  final GetUserProfileUseCase getUserProfile;
  final HasUserProfileUseCase hasUserProfile;
  final SaveUserProfileUseCase saveUserProfile;
  final HasCompletedOnboardingUseCase hasCompletedOnboarding;
  final ResetUserProfileUseCase resetUserProfile;

  UserProfileBloc({
    required this.getUserProfile,
    required this.hasUserProfile,
    required this.saveUserProfile,
    required this.hasCompletedOnboarding,
    required this.resetUserProfile,
  }) : super(UserProfileInitial()) {
    on<GetUserProfileEvent>(_onGetUserProfile);
    on<CheckUserProfileExistsEvent>(_onCheckUserProfileExists);
    on<SaveUserProfileEvent>(_onSaveUserProfile);
    on<CheckOnboardingCompletedEvent>(_onCheckOnboardingCompleted);
    on<ResetUserProfileEvent>(_onResetUserProfile);
  }

  Future<void> _onGetUserProfile(
    GetUserProfileEvent event,
    Emitter<UserProfileState> emit,
  ) async {
    emit(UserProfileLoading());

    final result = await getUserProfile(NoParams());

    result.fold(
      (failure) => emit(UserProfileError(message: failure.message)),
      (userProfile) => emit(UserProfileLoaded(userProfile: userProfile)),
    );
  }

  Future<void> _onCheckUserProfileExists(
    CheckUserProfileExistsEvent event,
    Emitter<UserProfileState> emit,
  ) async {
    emit(UserProfileLoading());

    final result = await hasUserProfile(NoParams());

    result.fold(
      (failure) => emit(UserProfileError(message: failure.message)),
      (exists) => emit(UserProfileExists(exists: exists)),
    );
  }

  Future<void> _onSaveUserProfile(
    SaveUserProfileEvent event,
    Emitter<UserProfileState> emit,
  ) async {
    emit(UserProfileLoading());

    final result = await saveUserProfile(
      SaveUserProfileParams(userProfile: event.userProfile),
    );

    result.fold(
      (failure) => emit(UserProfileError(message: failure.message)),
      (_) => emit(UserProfileSaved()),
    );
  }

  Future<void> _onCheckOnboardingCompleted(
    CheckOnboardingCompletedEvent event,
    Emitter<UserProfileState> emit,
  ) async {
    emit(UserProfileLoading());

    // Ajouter des logs pour déboguer
    print("Vérification de l'état d'onboarding...");

    final result = await hasCompletedOnboarding(NoParams());

    result.fold(
      (failure) {
        print(
            "Erreur lors de la vérification d'onboarding: ${failure.message}");
        emit(UserProfileError(message: failure.message));
      },
      (isCompleted) {
        print("Onboarding complété: $isCompleted");
        emit(OnboardingCompleted(isCompleted: isCompleted));
      },
    );
  }

  Future<void> _onResetUserProfile(
    ResetUserProfileEvent event,
    Emitter<UserProfileState> emit,
  ) async {
    emit(UserProfileLoading());

    final result = await resetUserProfile(NoParams());

    result.fold(
      (failure) => emit(UserProfileError(message: failure.message)),
      (_) => emit(UserProfileReset()),
    );
  }
}
