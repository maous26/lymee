// lib/presentation/screens/onboarding/onboarding_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lym_nutrition/domain/entities/user_profile.dart';
import 'package:lym_nutrition/presentation/bloc/user_profile/user_profile_bloc.dart';
import 'package:lym_nutrition/presentation/bloc/user_profile/user_profile_event.dart';
import 'package:lym_nutrition/presentation/bloc/user_profile/user_profile_state.dart';
import 'package:lym_nutrition/presentation/screens/onboarding/steps/basic_info_step.dart';
import 'package:lym_nutrition/presentation/screens/onboarding/steps/activity_level_step.dart';
import 'package:lym_nutrition/presentation/screens/onboarding/steps/weight_goal_step.dart';
import 'package:lym_nutrition/presentation/screens/onboarding/steps/dietary_preferences_step.dart';
import 'package:lym_nutrition/presentation/screens/onboarding/steps/fasting_schedule_step.dart';
import 'package:lym_nutrition/presentation/screens/onboarding/steps/supplements_step.dart';
import 'package:lym_nutrition/presentation/screens/onboarding/steps/summary_step.dart';
import 'package:lym_nutrition/presentation/widgets/modern_onboarding_container.dart';
import 'package:lym_nutrition/presentation/models/onboarding_step_data.dart';
import 'package:lym_nutrition/presentation/themes/wellness_colors.dart';
import 'package:uuid/uuid.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;
  late UserProfile _userProfile;
  bool _isSubmitting = false;
  late AnimationController _pageTransitionController;

  final List<OnboardingStepData> _steps = [
    OnboardingStepData(
      title: 'Informations personnelles',
      subtitle: 'Parlons de vous pour personnaliser votre expérience',
      emoji: '👤',
      icon: Icons.person_rounded,
      primaryColor: WellnessColors.primaryGreen,
    ),
    OnboardingStepData(
      title: 'Niveau d\'activité',
      subtitle: 'Quel sport pratiquez-vous ? À quelle fréquence ?',
      emoji: '🏃‍♀️',
      icon: Icons.fitness_center_rounded,
      primaryColor: WellnessColors.sunsetOrange,
    ),
    OnboardingStepData(
      title: 'Objectif de poids',
      subtitle: 'Définissons ensemble vos objectifs de transformation',
      emoji: '🎯',
      icon: Icons.track_changes_rounded,
      primaryColor: WellnessColors.secondaryBlue,
    ),
    OnboardingStepData(
      title: 'Préférences alimentaires',
      subtitle: 'Quels sont vos goûts et restrictions alimentaires ?',
      emoji: '🥗',
      icon: Icons.restaurant_rounded,
      primaryColor: WellnessColors.mintGreen,
    ),
    OnboardingStepData(
      title: 'Jeûne intermittent',
      subtitle: 'Pratiquez-vous le jeûne ? Définissons vos horaires',
      emoji: '⏰',
      icon: Icons.schedule_rounded,
      primaryColor: WellnessColors.accentPeach,
    ),
    OnboardingStepData(
      title: 'Compléments alimentaires',
      subtitle: 'Quels suppléments prenez-vous actuellement ?',
      emoji: '💊',
      icon: Icons.medical_services_rounded,
      primaryColor: WellnessColors.lavenderBlue,
    ),
    OnboardingStepData(
      title: 'Récapitulatif',
      subtitle: 'Validons ensemble votre profil nutritionnel',
      emoji: '✨',
      icon: Icons.check_circle_rounded,
      primaryColor: WellnessColors.primaryGreen,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _userProfile = UserProfile.defaultProfile(const Uuid().v4());
    _pageTransitionController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _pageTransitionController.dispose();
    super.dispose();
  }

  void _goToNextPage() {
    if (_currentPage < _steps.length - 1) {
      _pageTransitionController.forward().then((_) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
        _pageTransitionController.reverse();
      });
    }
  }

  void _goToPreviousPage() {
    if (_currentPage > 0) {
      _pageTransitionController.forward().then((_) {
        _pageController.previousPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
        _pageTransitionController.reverse();
      });
    }
  }

  void _updateUserProfile(UserProfile updatedProfile) {
    setState(() {
      _userProfile = updatedProfile;
    });
  }

  void _submitUserProfile() {
    setState(() {
      _isSubmitting = true;
    });
    context.read<UserProfileBloc>().add(
          SaveUserProfileEvent(userProfile: _userProfile),
        );
  }

  AppBar? _buildModernAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            Icons.arrow_back_rounded,
            color: WellnessColors.textPrimary,
            size: 20,
          ),
        ),
        onPressed: _goToPreviousPage,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WellnessColors.backgroundSecondary,
      appBar: _currentPage > 0 ? _buildModernAppBar() : null,
      body: BlocListener<UserProfileBloc, UserProfileState>(
        listener: (context, state) {
          if (state is UserProfileSaved) {
            setState(() {
              _isSubmitting = false;
            });
            Navigator.of(context).pushReplacementNamed('/dashboard');
          } else if (state is UserProfileError) {
            setState(() {
              _isSubmitting = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Erreur: ${state.message}'),
                backgroundColor: WellnessColors.errorCoral,
              ),
            );
          }
        },
        child: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          onPageChanged: (int page) {
            setState(() {
              _currentPage = page;
            });
          },
          children: [
            // Étape 1: Informations de base
            ModernOnboardingContainer(
              title: _steps[0].title,
              subtitle: _steps[0].subtitle,
              titleIcon: _steps[0].icon,
              illustrationEmoji: _steps[0].emoji,
              primaryColor: _steps[0].primaryColor,
              currentStep: 0,
              totalSteps: _steps.length,
              onNext: () {
                // Valider et sauvegarder avant de passer à l'étape suivante
                _goToNextPage();
              },
              content: BasicInfoStep(
                userProfile: _userProfile,
                onUpdateProfile: _updateUserProfile,
                onNext: _goToNextPage,
              ),
            ),

            // Étape 2: Niveau d'activité
            ModernOnboardingContainer(
              title: _steps[1].title,
              subtitle: _steps[1].subtitle,
              titleIcon: _steps[1].icon,
              illustrationEmoji: _steps[1].emoji,
              primaryColor: _steps[1].primaryColor,
              currentStep: 1,
              totalSteps: _steps.length,
              onNext: _goToNextPage,
              content: ActivityLevelStep(
                userProfile: _userProfile,
                onUpdateProfile: _updateUserProfile,
                onNext: _goToNextPage,
              ),
            ),

            // Étape 3: Objectif de poids
            ModernOnboardingContainer(
              title: _steps[2].title,
              subtitle: _steps[2].subtitle,
              titleIcon: _steps[2].icon,
              illustrationEmoji: _steps[2].emoji,
              primaryColor: _steps[2].primaryColor,
              currentStep: 2,
              totalSteps: _steps.length,
              onNext: _goToNextPage,
              content: WeightGoalStep(
                userProfile: _userProfile,
                onUpdateProfile: _updateUserProfile,
                onNext: _goToNextPage,
              ),
            ),

            // Étape 4: Préférences alimentaires
            ModernOnboardingContainer(
              title: _steps[3].title,
              subtitle: _steps[3].subtitle,
              titleIcon: _steps[3].icon,
              illustrationEmoji: _steps[3].emoji,
              primaryColor: _steps[3].primaryColor,
              currentStep: 3,
              totalSteps: _steps.length,
              onNext: _goToNextPage,
              content: DietaryPreferencesStep(
                userProfile: _userProfile,
                onUpdateProfile: _updateUserProfile,
                onNext: _goToNextPage,
              ),
            ),

            // Étape 5: Jeûne intermittent
            ModernOnboardingContainer(
              title: _steps[4].title,
              subtitle: _steps[4].subtitle,
              titleIcon: _steps[4].icon,
              illustrationEmoji: _steps[4].emoji,
              primaryColor: _steps[4].primaryColor,
              currentStep: 4,
              totalSteps: _steps.length,
              onNext: _goToNextPage,
              content: FastingScheduleStep(
                userProfile: _userProfile,
                onUpdateProfile: _updateUserProfile,
                onNext: _goToNextPage,
              ),
            ),

            // Étape 6: Compléments alimentaires
            ModernOnboardingContainer(
              title: _steps[5].title,
              subtitle: _steps[5].subtitle,
              titleIcon: _steps[5].icon,
              illustrationEmoji: _steps[5].emoji,
              primaryColor: _steps[5].primaryColor,
              currentStep: 5,
              totalSteps: _steps.length,
              onNext: _goToNextPage,
              content: SupplementsStep(
                userProfile: _userProfile,
                onUpdateProfile: _updateUserProfile,
                onNext: _goToNextPage,
              ),
            ),

            // Étape 7: Résumé
            ModernOnboardingContainer(
              title: _steps[6].title,
              subtitle: _steps[6].subtitle,
              titleIcon: _steps[6].icon,
              illustrationEmoji: _steps[6].emoji,
              primaryColor: _steps[6].primaryColor,
              currentStep: 6,
              totalSteps: _steps.length,
              nextButtonText: 'Créer mon profil',
              isLoading: _isSubmitting,
              onNext: _submitUserProfile,
              content: SummaryStep(
                userProfile: _userProfile,
                onSubmit: _submitUserProfile,
                isSubmitting: _isSubmitting,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
