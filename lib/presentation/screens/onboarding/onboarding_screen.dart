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
import 'package:lym_nutrition/presentation/screens/onboarding/steps/meal_planning_step.dart';
import 'package:lym_nutrition/presentation/screens/onboarding/steps/summary_step.dart';
import 'package:lym_nutrition/presentation/widgets/lym_onboarding_container.dart';
import 'package:lym_nutrition/presentation/themes/fresh_theme.dart';

import 'package:uuid/uuid.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _currentStepIndex = 0;
  late UserProfile _userProfile;
  bool _isSubmitting = false;

  final GlobalKey<BasicInfoStepState> _basicInfoStepKey =
      GlobalKey<BasicInfoStepState>();
  final GlobalKey<ActivityLevelStepState> _activityLevelStepKey =
      GlobalKey<ActivityLevelStepState>();
  final GlobalKey<WeightGoalStepState> _weightGoalStepKey =
      GlobalKey<WeightGoalStepState>();
  final GlobalKey<DietaryPreferencesStepState> _dietaryPreferencesStepKey =
      GlobalKey<DietaryPreferencesStepState>();
  final GlobalKey<FastingScheduleStepState> _fastingScheduleStepKey =
      GlobalKey<FastingScheduleStepState>();
  final GlobalKey<SupplementsStepState> _supplementsStepKey =
      GlobalKey<SupplementsStepState>();
  final GlobalKey<MealPlanningStepState> _mealPlanningStepKey =
      GlobalKey<MealPlanningStepState>();
  // No GlobalKey needed for SummaryStep as its primary actions are submit or edit (navigation)

  late List<Widget> _onboardingSteps;
  late List<String> _stepTitles;
  late List<String> _stepSubtitles;
  late List<Color> _stepAccentColors;

  @override
  void initState() {
    super.initState();
    _userProfile =
        UserProfile.empty(const Uuid().v4()); // Changed defaultProfile to empty
    _initializeStepsAndConfiguration();
  }

  void _initializeStepsAndConfiguration() {
    // Titles for each step
    _stepTitles = [
      'Welcome to Lym!',
      'Activity Level',
      'Weight Goal',
      'Dietary Preferences',
      'Fasting Schedule',
      'Supplements',
      'Meal Planning',
      'Summary & Start',
    ];

    // Subtitles for each step
    _stepSubtitles = [
      'Let\'s get to know you a bit better.', // Corrected escaping
      'Tell us about your typical physical activity.',
      'What are you aiming for with your weight?',
      'Any food allergies, restrictions, or strong preferences?',
      'Do you practice or plan to practice intermittent fasting?',
      'Are you currently taking any dietary supplements?',
      'Tell us about your cooking skills and budget.',
      'Review your information and begin your personalized journey!',
    ];

    // Using existing FreshTheme colors
    _stepAccentColors = [
      FreshTheme.primaryMint, // Basic Info
      FreshTheme.accentCoral, // Activity Level
      FreshTheme.deepOcean, // Weight Goal
      FreshTheme.serenityBlue, // Dietary Preferences
      FreshTheme.serenityBlue, // Fasting Schedule
      FreshTheme.warmAmber, // Supplements
      FreshTheme.serenityBlue, // Meal Planning
      FreshTheme.accentCoral, // Summary
    ];

    // Define the onboarding step widgets
    _onboardingSteps = [
      BasicInfoStep(
        key: _basicInfoStepKey,
        userProfile: _userProfile,
        onUpdateProfile:
            _updateUserProfile, // BasicInfoStep updates the profile directly
        onNextRequested:
            _actualAdvanceAndReinitialize, // Parent handles advancement
      ),
      ActivityLevelStep(
        key: _activityLevelStepKey,
        userProfile: _userProfile,
        onUpdateProfile: _updateUserProfile,
        onNextRequested: _actualAdvanceAndReinitialize,
      ),
      WeightGoalStep(
        key: _weightGoalStepKey,
        userProfile: _userProfile,
        onUpdateProfile: _updateUserProfile,
        onNextRequested: _actualAdvanceAndReinitialize,
      ),
      DietaryPreferencesStep(
        key: _dietaryPreferencesStepKey,
        userProfile: _userProfile,
        onUpdateProfile: _updateUserProfile,
        onNextRequested: _actualAdvanceAndReinitialize,
      ),
      FastingScheduleStep(
        key: _fastingScheduleStepKey,
        userProfile: _userProfile,
        onUpdateProfile: _updateUserProfile,
        onNextRequested: _actualAdvanceAndReinitialize,
      ),
      SupplementsStep(
        key: _supplementsStepKey,
        userProfile:
            _userProfile, // Pass the full profile for context if needed
        initialSupplements:
            _userProfile.supplements, // Pass initial supplements
        onNextRequested:
            _actualAdvanceAndReinitialize, // Parent handles advancement
        // onUpdateProfile is not directly passed; changes are handled via _supplementsStepKey
      ),
      MealPlanningStep(
        key: _mealPlanningStepKey,
        userProfile: _userProfile,
        onUpdateProfile: _updateUserProfile,
        onNextRequested: _actualAdvanceAndReinitialize,
      ),
      SummaryStep(
        userProfile:
            _userProfile, // SummaryStep always gets the latest _userProfile
        onSubmit: _submitUserProfile,
        isSubmitting: _isSubmitting,
        onEdit: (stepIndex) {
          if (stepIndex >= 0 && stepIndex < _onboardingSteps.length) {
            setState(() {
              _currentStepIndex = stepIndex;
              // Crucially, re-initialize to ensure the step being jumped to
              // and the summary (if returned to) reflect the most current state.
              _initializeStepsAndConfiguration();
            });
          }
        },
      ),
    ];
  }

  // New method to handle actual advancement and re-initialization
  void _actualAdvanceAndReinitialize() {
    if (_currentStepIndex < _onboardingSteps.length - 1) {
      setState(() {
        _currentStepIndex++;
        // Re-initialize steps to ensure all steps (especially SummaryStep)
        // are built with the latest _userProfile data.
        _initializeStepsAndConfiguration();
      });
    }
  }

  void _handleNextTap() {
    if (_isSubmitting) return;

    bool isLastStep = _currentStepIndex == _onboardingSteps.length - 1;

    if (isLastStep) {
      _submitUserProfile();
      return; // Submission handles navigation or state change
    }

    // Trigger validation on the current step.
    // The step's validateAndProceed method should call its onNextRequested callback
    // (which is _actualAdvanceAndReinitialize) if validation passes.
    Widget currentStepWidget = _onboardingSteps[_currentStepIndex];

    if (currentStepWidget is BasicInfoStep) {
      _basicInfoStepKey.currentState?.validateAndProceed();
    } else if (currentStepWidget is ActivityLevelStep) {
      _activityLevelStepKey.currentState?.validateAndProceed();
    } else if (currentStepWidget is WeightGoalStep) {
      _weightGoalStepKey.currentState?.validateAndProceed();
    } else if (currentStepWidget is DietaryPreferencesStep) {
      _dietaryPreferencesStepKey.currentState?.validateAndProceed();
    } else if (currentStepWidget is FastingScheduleStep) {
      _fastingScheduleStepKey.currentState?.validateAndProceed();
    } else if (currentStepWidget is SupplementsStep) {
      // For SupplementsStep, we need to get the current supplements
      // and update the profile BEFORE validation, so SummaryStep gets the data.
      final currentSupplements =
          _supplementsStepKey.currentState?.currentSupplements;
      if (currentSupplements != null) {
        // This will update _userProfile and trigger _initializeStepsAndConfiguration
        _updateUserProfile(
            _userProfile.copyWith(supplements: currentSupplements));
      }
      // Now, validateAndProceed can be called. If it calls onNextRequested,
      // _actualAdvanceAndReinitialize will use the already updated profile.
      _supplementsStepKey.currentState?.validateAndProceed();
    } else if (currentStepWidget is MealPlanningStep) {
      _mealPlanningStepKey.currentState?.validateAndProceed();
    } else {
      // Fallback for any step not explicitly handled or if a step doesn't need validation
      // and directly calls onNextRequested (which is _actualAdvanceAndReinitialize).
      // However, all interactive steps should ideally have a validateAndProceed.
      _actualAdvanceAndReinitialize();
    }
  }

  void _goToPreviousStep() {
    if (_isSubmitting) return;
    if (_currentStepIndex > 0) {
      setState(() {
        _currentStepIndex--;
        // Re-initialize to ensure the step being returned to has the correct state
        // and subsequent steps (like summary) are also based on potentially changed data.
        _initializeStepsAndConfiguration();
      });
    }
  }

  void _updateUserProfile(UserProfile updatedProfile) {
    setState(() {
      _userProfile = updatedProfile;
      // CRITICAL: Re-initialize steps whenever the profile is updated.
      // This ensures that all step widgets are rebuilt with the latest data,
      // particularly important for SummaryStep and for steps that might depend
      // on data from previous steps.
      _initializeStepsAndConfiguration();
    });
  }

  void _submitUserProfile() {
    if (_isSubmitting) return;
    // Ensure the final state of supplements is captured if user is on SupplementsStep and clicks "Finish"
    // (though "Finish" is typically on SummaryStep)
    // Or, more robustly, ensure SummaryStep is built with the absolute latest profile.
    // The _initializeStepsAndConfiguration call in _updateUserProfile and navigation methods should handle this.

    // One final check for supplements if the current step IS supplements step and somehow submit is called
    // This is more of a safeguard; primary update path is via _handleNextTap for SupplementsStep.
    if (_onboardingSteps[_currentStepIndex] is SupplementsStep) {
      final currentSupplements =
          _supplementsStepKey.currentState?.currentSupplements;
      if (currentSupplements != null &&
          _userProfile.supplements != currentSupplements) {
        _userProfile = _userProfile.copyWith(supplements: currentSupplements);
        // Not calling _initializeStepsAndConfiguration here as we are about to submit and potentially navigate away.
      }
    }

    setState(() {
      _isSubmitting = true;
    });
    context.read<UserProfileBloc>().add(
          SaveUserProfileEvent(userProfile: _userProfile),
        );
    // Navigation to the main app screen after submission will be handled by BlocListener
  }

  @override
  Widget build(BuildContext context) {
    // Ensure _onboardingSteps is initialized and _currentStepIndex is valid
    // This check prevents errors if build is called before initState completes fully
    // or if _currentStepIndex is somehow out of bounds.
    if (_onboardingSteps.isEmpty ||
        _currentStepIndex >= _onboardingSteps.length ||
        _stepTitles.isEmpty ||
        _currentStepIndex >= _stepTitles.length ||
        _stepSubtitles.isEmpty ||
        _currentStepIndex >= _stepSubtitles.length ||
        _stepAccentColors.isEmpty ||
        _currentStepIndex >= _stepAccentColors.length) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    bool isLastStep = _currentStepIndex == _onboardingSteps.length - 1;
    String nextButtonText = isLastStep ? 'Finish & Start' : 'Next';
    if (_isSubmitting && isLastStep) {
      nextButtonText = 'Starting...';
    }

    return BlocListener<UserProfileBloc, UserProfileState>(
      listener: (context, state) {
        if (state is UserProfileSaved) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile Saved! Welcome!')),
          );
          // Navigate to the main dashboard after successful profile save
          Navigator.of(context).pushReplacementNamed('/dashboard');
        } else if (state is UserProfileError) {
          setState(() {
            _isSubmitting = false; // Reset submitting state on error
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error saving profile: ${state.message}')),
          );
        }
      },
      child: LymOnboardingContainer(
        title: _stepTitles[_currentStepIndex],
        subtitle: _stepSubtitles[_currentStepIndex],
        currentStep: _currentStepIndex,
        totalSteps: _onboardingSteps.length,
        onNext: _isSubmitting ? null : _handleNextTap,
        onBack:
            _currentStepIndex == 0 || _isSubmitting ? null : _goToPreviousStep,
        nextButtonText: nextButtonText,
        accentColor: _stepAccentColors[_currentStepIndex],
        child: IndexedStack(
          index: _currentStepIndex,
          children: _onboardingSteps,
        ),
      ),
    );
  }
}

// Ensure other step files (ActivityLevelStep, WeightGoalStep, etc.) are updated
// to have onNextRequested and onUpdateProfile parameters and a validateAndProceed method.
// BasicInfoStep already has: userProfile, onUpdateProfile, onNextRequested, validateAndProceed
// ActivityLevelStep needs: userProfile, onUpdateProfile, onNextRequested, validateAndProceed
// WeightGoalStep needs: userProfile, onUpdateProfile, onNextRequested, validateAndProceed
// DietaryPreferencesStep needs: userProfile, onUpdateProfile, onNextRequested, validateAndProceed
// FastingScheduleStep needs: userProfile, onUpdateProfile, onNextRequested, validateAndProceed
// SupplementsStep has: userProfile, initialSupplements, onNextRequested, validateAndProceed, currentSupplements getter
// SummaryStep has: userProfile, onSubmit, isSubmitting, onEdit
