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
import 'package:lym_nutrition/presentation/themes/premium_theme.dart';
import 'package:uuid/uuid.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;
  late UserProfile _userProfile;
  bool _isSubmitting = false;

  final List<String> _steps = [
    'Informations de base',
    'Niveau d\'activité',
    'Objectif de poids',
    'Préférences alimentaires',
    'Jeûne intermittent',
    'Compléments alimentaires',
    'Résumé',
  ];

  @override
  void initState() {
    super.initState();
    // Initialiser le profil utilisateur avec des valeurs par défaut
    _userProfile = UserProfile.defaultProfile(const Uuid().v4());
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToNextPage() {
    if (_currentPage < _steps.length - 1) {
      _pageController.nextPage(
        duration: PremiumTheme.animationMedium,
        curve: Curves.easeInOut,
      );
    }
  }

  void _goToPreviousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: PremiumTheme.animationMedium,
        curve: Curves.easeInOut,
      );
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

    // Sauvegarder le profil utilisateur
    context.read<UserProfileBloc>().add(
          SaveUserProfileEvent(userProfile: _userProfile),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil nutritionnel'),
        leading: _currentPage > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _goToPreviousPage,
              )
            : null,
        backgroundColor: PremiumTheme.primaryColor,
      ),
      body: BlocListener<UserProfileBloc, UserProfileState>(
        listener: (context, state) {
          if (state is UserProfileSaved) {
            setState(() {
              _isSubmitting = false;
            });
            // Naviguer vers l'écran principal après la sauvegarde
            Navigator.of(context).pushReplacementNamed('/dashboard');
          } else if (state is UserProfileError) {
            setState(() {
              _isSubmitting = false;
            });
            // Afficher une erreur
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Erreur: ${state.message}'),
                backgroundColor: PremiumTheme.error,
              ),
            );
          }
        },
        child: Column(
          children: [
            // Indicateur de progression
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Texte de l'étape actuelle
                  Text(
                    _steps[_currentPage],
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: PremiumTheme.primaryColor,
                        ),
                  ),
                  const SizedBox(height: 8),
                  // Barre de progression
                  LinearProgressIndicator(
                    value: (_currentPage + 1) / _steps.length,
                    backgroundColor: Colors.grey[200],
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      PremiumTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Étape actuelle / Total
                  Text(
                    'Étape ${_currentPage + 1}/${_steps.length}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),

            // Contenu des étapes
            Expanded(
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
                  BasicInfoStep(
                    userProfile: _userProfile,
                    onUpdateProfile: _updateUserProfile,
                    onNext: _goToNextPage,
                  ),

                  // Étape 2: Niveau d'activité
                  ActivityLevelStep(
                    userProfile: _userProfile,
                    onUpdateProfile: _updateUserProfile,
                    onNext: _goToNextPage,
                  ),

                  // Étape 3: Objectif de poids
                  WeightGoalStep(
                    userProfile: _userProfile,
                    onUpdateProfile: _updateUserProfile,
                    onNext: _goToNextPage,
                  ),

                  // Étape 4: Préférences alimentaires
                  DietaryPreferencesStep(
                    userProfile: _userProfile,
                    onUpdateProfile: _updateUserProfile,
                    onNext: _goToNextPage,
                  ),

                  // Étape 5: Jeûne intermittent
                  FastingScheduleStep(
                    userProfile: _userProfile,
                    onUpdateProfile: _updateUserProfile,
                    onNext: _goToNextPage,
                  ),

                  // Étape 6: Compléments alimentaires
                  SupplementsStep(
                    userProfile: _userProfile,
                    onUpdateProfile: _updateUserProfile,
                    onNext: _goToNextPage,
                  ),

                  // Étape 7: Résumé
                  SummaryStep(
                    userProfile: _userProfile,
                    onSubmit: _submitUserProfile,
                    isSubmitting: _isSubmitting,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
