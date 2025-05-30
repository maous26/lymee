// lib/presentation/bloc/user_profile/user_profile_event.dart
import 'package:equatable/equatable.dart';
import 'package:lym_nutrition/domain/entities/user_profile.dart';

abstract class UserProfileEvent extends Equatable {
  const UserProfileEvent();

  @override
  List<Object?> get props => [];
}

class GetUserProfileEvent extends UserProfileEvent {}

class CheckUserProfileExistsEvent extends UserProfileEvent {}

class SaveUserProfileEvent extends UserProfileEvent {
  final UserProfile userProfile;

  const SaveUserProfileEvent({required this.userProfile});

  @override
  List<Object> get props => [userProfile];
}

class CheckOnboardingCompletedEvent extends UserProfileEvent {}

class ResetUserProfileEvent extends UserProfileEvent {}
