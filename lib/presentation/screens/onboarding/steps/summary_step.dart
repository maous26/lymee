// lib/presentation/screens/onboarding/steps/summary_step.dart
import 'package:flutter/material.dart';
import 'package:lym_nutrition/domain/entities/user_profile.dart';
import 'package:lym_nutrition/presentation/themes/premium_theme.dart';
import 'package:lym_nutrition/presentation/widgets/onboarding_step_container.dart';

class SummaryStep extends StatelessWidget {
  final UserProfile userProfile;
  final VoidCallback onSubmit;
  final bool isSubmitting;

  const SummaryStep({
    Key? key,
    required this.userProfile,
    required this.onSubmit,
    this.isSubmitting = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return OnboardingStepContainer(
      title: 'Résumé de votre profil',
      subtitle: 'Vérifiez vos informations avant de terminer',
      onNext: onSubmit,
      nextButtonText: 'Finaliser mon profil',
      isLoading: isSubmitting,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Informations de base
          _buildSectionCard(
            context,
            title: 'Informations personnelles',
            icon: Icons.person,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow(
                  'Âge',
                  '${userProfile.age} ans',
                ),
                _buildInfoRow(
                  'Genre',
                  _getGenderLabel(userProfile.gender),
                ),
                _buildInfoRow(
                  'Taille',
                  '${userProfile.heightCm} cm',
                ),
                _buildInfoRow(
                  'Poids',
                  '${userProfile.weightKg} kg',
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Niveau d'activité
          _buildSectionCard(
            context,
            title: 'Activité physique',
            icon: Icons.fitness_center,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow(
                  'Niveau général',
                  _getActivityLevelLabel(userProfile.activityLevel),
                ),
                if (userProfile.sportActivities.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  const Text(
                    'Activités spécifiques:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  ...userProfile.sportActivities.map((activity) {
                    return Padding(
                      padding: const EdgeInsets.only(left: 16, bottom: 4),
                      child: Text(
                        '• ${activity.name} (${activity.minutesPerSession} min × ${activity.sessionsPerWeek} fois/semaine)',
                      ),
                    );
                  }).toList(),
                ],
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Objectif de poids
          _buildSectionCard(
            context,
            title: 'Objectif de poids',
            icon: Icons.track_changes,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow(
                  'Objectif',
                  _getWeightGoalLabel(userProfile.weightGoal),
                ),
                if (userProfile.weightGoal != WeightGoal.maintain)
                  _buildInfoRow(
                    'Rythme',
                    '${userProfile.weightGoalKgPerWeek} kg par semaine',
                  ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Préférences alimentaires
          _buildSectionCard(
            context,
            title: 'Préférences alimentaires',
            icon: Icons.restaurant,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Régimes
                if (_hasSpecialDiet(userProfile)) ...[
                  const Text(
                    'Régimes:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      if (userProfile.dietaryPreferences.isVegetarian)
                        _buildDietChip('Végétarien', PremiumTheme.success),
                      if (userProfile.dietaryPreferences.isVegan)
                        _buildDietChip('Végétalien', PremiumTheme.success),
                      if (userProfile.dietaryPreferences.isHalal)
                        _buildDietChip('Halal', PremiumTheme.info),
                      if (userProfile.dietaryPreferences.isKosher)
                        _buildDietChip('Casher', PremiumTheme.info),
                      if (userProfile.dietaryPreferences.isGlutenFree)
                        _buildDietChip('Sans gluten', PremiumTheme.warning),
                      if (userProfile.dietaryPreferences.isLactoseFree)
                        _buildDietChip('Sans lactose', PremiumTheme.warning),
                    ],
                  ),
                ] else
                  const Text('Aucun régime alimentaire spécifique'),

                // Allergies
                if (userProfile.dietaryPreferences.allergies.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  const Text(
                    'Allergies:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children:
                        userProfile.dietaryPreferences.allergies.map((allergy) {
                      return _buildDietChip(allergy, PremiumTheme.error);
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Jeûne intermittent
          _buildSectionCard(
            context,
            title: 'Jeûne intermittent',
            icon: Icons.schedule,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow(
                  'Type',
                  _getFastingTypeLabel(userProfile.fastingSchedule.type),
                ),
                if (userProfile.fastingSchedule.type !=
                    IntermittentFastingType.none) ...[
                  if (userProfile.fastingSchedule.type ==
                          IntermittentFastingType.fasting16_8 ||
                      userProfile.fastingSchedule.type ==
                          IntermittentFastingType.fasting18_6 ||
                      userProfile.fastingSchedule.type ==
                          IntermittentFastingType.fasting20_4 ||
                      userProfile.fastingSchedule.type ==
                          IntermittentFastingType.custom) ...[
                    _buildInfoRow(
                      'Début du jeûne',
                      userProfile.fastingSchedule.fastingStartTime,
                    ),
                    _buildInfoRow(
                      'Fin du jeûne',
                      userProfile.fastingSchedule.fastingEndTime,
                    ),
                  ],
                  if (userProfile.fastingSchedule.type ==
                          IntermittentFastingType.fasting5_2 ||
                      userProfile.fastingSchedule.type ==
                          IntermittentFastingType.alternateDay) ...[
                    _buildInfoRow(
                      'Jours de jeûne',
                      _getFastingDaysLabel(
                          userProfile.fastingSchedule.fastingDays),
                    ),
                  ],
                ],
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Compléments alimentaires
          _buildSectionCard(
            context,
            title: 'Compléments alimentaires',
            icon: Icons.medical_services,
            content: userProfile.supplements.isEmpty
                ? const Text('Aucun complément alimentaire ajouté')
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: userProfile.supplements.map((supplement) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              supplement.name,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '${supplement.dosage} ${supplement.unit} - ${supplement.timing}',
                            ),
                            if (supplement.notes != null)
                              Text(
                                supplement.notes!,
                                style: const TextStyle(
                                  fontStyle: FontStyle.italic,
                                  fontSize: 12,
                                ),
                              ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
          ),

          const SizedBox(height: 16),

          // Besoins nutritionnels calculés
          _buildSectionCard(
            context,
            title: 'Besoins nutritionnels calculés',
            icon: Icons.pie_chart,
            color: PremiumTheme.primaryColor,
            content: _buildNutrientSummary(context, userProfile),
          ),

          const SizedBox(height: 24),

          // Message de confidentialité
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(PremiumTheme.borderRadiusMedium),
              border: Border.all(
                color: theme.colorScheme.onSurface.withOpacity(0.1),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.privacy_tip,
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Confidentialité',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Vos données sont stockées uniquement sur votre appareil. Vous pourrez modifier votre profil à tout moment dans les paramètres de l\'application.',
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Widget content,
    Color? color,
  }) {
    final theme = Theme.of(context);
    final effectiveColor = color ?? theme.colorScheme.primary;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(PremiumTheme.borderRadiusLarge),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: effectiveColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: effectiveColor,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            content,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Widget _buildDietChip(String label, Color color) {
    return Chip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
      backgroundColor: color.withOpacity(0.1),
      side: BorderSide(color: color.withOpacity(0.3)),
      padding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
    );
  }

  Widget _buildNutrientSummary(BuildContext context, UserProfile userProfile) {
    final macros = userProfile.calculateMacroTargets();
    final calories = macros['calories']?.round() ?? 0;
    final protein = macros['protein']?.round() ?? 0;
    final carbs = macros['carbs']?.round() ?? 0;
    final fat = macros['fat']?.round() ?? 0;
    final fiber = macros['fiber']?.round() ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Objectif quotidien: $calories kcal',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNutrientCircle(
              'Protéines',
              '$protein g',
              Colors.blue,
            ),
            _buildNutrientCircle(
              'Glucides',
              '$carbs g',
              Colors.orange,
            ),
            _buildNutrientCircle(
              'Lipides',
              '$fat g',
              Colors.red,
            ),
            _buildNutrientCircle(
              'Fibres',
              '$fiber g',
              Colors.green,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Ces valeurs sont calculées en fonction de vos caractéristiques et objectifs. Elles seront utilisées pour suivre votre alimentation quotidienne.',
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildNutrientCircle(
    String label,
    String value,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withOpacity(0.1),
            border: Border.all(
              color: color.withOpacity(0.5),
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  String _getGenderLabel(Gender gender) {
    switch (gender) {
      case Gender.male:
        return 'Homme';
      case Gender.female:
        return 'Femme';
      case Gender.other:
        return 'Autre';
    }
  }

  String _getActivityLevelLabel(ActivityLevel level) {
    switch (level) {
      case ActivityLevel.sedentary:
        return 'Sédentaire';
      case ActivityLevel.lightlyActive:
        return 'Légèrement actif';
      case ActivityLevel.moderatelyActive:
        return 'Modérément actif';
      case ActivityLevel.veryActive:
        return 'Très actif';
      case ActivityLevel.extremelyActive:
        return 'Extrêmement actif';
    }
  }

  String _getWeightGoalLabel(WeightGoal goal) {
    switch (goal) {
      case WeightGoal.lose:
        return 'Perte de poids';
      case WeightGoal.maintain:
        return 'Maintien du poids';
      case WeightGoal.gain:
        return 'Prise de poids';
    }
  }

  String _getFastingTypeLabel(IntermittentFastingType type) {
    switch (type) {
      case IntermittentFastingType.none:
        return 'Pas de jeûne intermittent';
      case IntermittentFastingType.fasting16_8:
        return 'Jeûne 16/8';
      case IntermittentFastingType.fasting18_6:
        return 'Jeûne 18/6';
      case IntermittentFastingType.fasting20_4:
        return 'Jeûne 20/4';
      case IntermittentFastingType.fasting5_2:
        return 'Jeûne 5:2';
      case IntermittentFastingType.alternateDay:
        return 'Jeûne alterné';
      case IntermittentFastingType.custom:
        return 'Personnalisé';
    }
  }

  String _getFastingDaysLabel(List<int> days) {
    if (days.isEmpty) return 'Aucun jour sélectionné';

    final weekdays = [
      'Lundi',
      'Mardi',
      'Mercredi',
      'Jeudi',
      'Vendredi',
      'Samedi',
      'Dimanche',
    ];

    return days.map((day) => weekdays[day - 1]).join(', ');
  }

  bool _hasSpecialDiet(UserProfile profile) {
    return profile.dietaryPreferences.isVegetarian ||
        profile.dietaryPreferences.isVegan ||
        profile.dietaryPreferences.isHalal ||
        profile.dietaryPreferences.isKosher ||
        profile.dietaryPreferences.isGlutenFree ||
        profile.dietaryPreferences.isLactoseFree;
  }
}
