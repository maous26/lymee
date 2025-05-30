// lib/presentation/bloc/user_profile/user_profile_state.dart
import 'package:equatable/equatable.dart';
import 'package:lym_nutrition/domain/entities/user_profile.dart';

abstract class UserProfileState extends Equatable {
  const UserProfileState();

  @override
  List<Object?> get props => [];
}

class UserProfileInitial extends UserProfileState {}

class UserProfileLoading extends UserProfileState {}

class UserProfileLoaded extends UserProfileState {
  final UserProfile userProfile;

  const UserProfileLoaded({required this.userProfile});

  @override
  List<Object> get props => [userProfile];
}

class UserProfileExists extends UserProfileState {
  final bool exists;

  const UserProfileExists({required this.exists});

  @override
  List<Object> get props => [exists];
}

class UserProfileSaved extends UserProfileState {}

class UserProfileError extends UserProfileState {
  final String message;

  const UserProfileError({required this.message});

  @override
  List<Object> get props => [message];
}

class OnboardingCompleted extends UserProfileState {
  final bool isCompleted;

  const OnboardingCompleted({required this.isCompleted});

  @override
  List<Object> get props => [isCompleted];
}

class UserProfileReset extends UserProfileState {}
