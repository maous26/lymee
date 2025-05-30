// lib/presentation/screens/onboarding/steps/weight_goal_step.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lym_nutrition/domain/entities/user_profile.dart';
import 'package:lym_nutrition/presentation/themes/premium_theme.dart';
import 'package:lym_nutrition/presentation/widgets/onboarding_step_container.dart';

class WeightGoalStep extends StatefulWidget {
  final UserProfile userProfile;
  final Function(UserProfile) onUpdateProfile;
  final VoidCallback onNext;

  const WeightGoalStep({
    Key? key,
    required this.userProfile,
    required this.onUpdateProfile,
    required this.onNext,
  }) : super(key: key);

  @override
  State<WeightGoalStep> createState() => _WeightGoalStepState();
}

class _WeightGoalStepState extends State<WeightGoalStep> {
  WeightGoal _selectedWeightGoal = WeightGoal.maintain;
  double _goalRate = 0.5; // kg par semaine par défaut
  final TextEditingController _goalRateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedWeightGoal = widget.userProfile.weightGoal;
    _goalRate = widget.userProfile.weightGoalKgPerWeek;
    _goalRateController.text = _goalRate.toString();
  }

  @override
  void dispose() {
    _goalRateController.dispose();
    super.dispose();
  }

  void _updateGoalRate(String value) {
    if (value.isNotEmpty) {
      setState(() {
        _goalRate = double.tryParse(value) ?? 0.5;
      });
    }
  }

  void _saveAndContinue() {
    // Mettre à jour le profil utilisateur
    final updatedProfile = widget.userProfile.copyWith(
      weightGoal: _selectedWeightGoal,
      weightGoalKgPerWeek: _goalRate,
    );

    widget.onUpdateProfile(updatedProfile);
    widget.onNext();
  }

  String _getWeightGoalDescription(WeightGoal goal) {
    switch (goal) {
      case WeightGoal.lose:
        return 'Perdre du poids';
      case WeightGoal.maintain:
        return 'Maintenir mon poids actuel';
      case WeightGoal.gain:
        return 'Prendre du poids';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return OnboardingStepContainer(
      title: 'Votre objectif de poids',
      subtitle:
          'Définissez votre objectif pour personnaliser votre alimentation',
      onNext: _saveAndContinue,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Objectif de poids
          Text(
            'Que souhaitez-vous faire?',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Options d'objectif
          Card(
            elevation: 2,
            child: Column(
              children: WeightGoal.values.map((goal) {
                return RadioListTile<WeightGoal>(
                  title: Text(
                    _getWeightGoalDescription(goal),
                    style: TextStyle(
                      fontWeight: _selectedWeightGoal == goal
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                  value: goal,
                  groupValue: _selectedWeightGoal,
                  onChanged: (WeightGoal? value) {
                    if (value != null) {
                      setState(() {
                        _selectedWeightGoal = value;
                      });
                    }
                  },
                  activeColor: PremiumTheme.primaryColor,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 16,
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 24),

          // Taux de perte/prise de poids
          if (_selectedWeightGoal != WeightGoal.maintain)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _selectedWeightGoal == WeightGoal.lose
                      ? 'À quelle vitesse souhaitez-vous perdre du poids?'
                      : 'À quelle vitesse souhaitez-vous prendre du poids?',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Slider pour le taux
                Row(
                  children: [
                    Expanded(
                      child: Slider(
                        value: _goalRate,
                        min: 0.2,
                        max: _selectedWeightGoal == WeightGoal.lose ? 1.0 : 0.8,
                        divisions:
                            _selectedWeightGoal == WeightGoal.lose ? 8 : 6,
                        onChanged: (value) {
                          setState(() {
                            _goalRate = value;
                            _goalRateController.text = value.toStringAsFixed(1);
                          });
                        },
                        activeColor: _selectedWeightGoal == WeightGoal.lose
                            ? PremiumTheme.error
                            : PremiumTheme.success,
                      ),
                    ),
                    SizedBox(
                      width: 60,
                      child: TextFormField(
                        controller: _goalRateController,
                        decoration: const InputDecoration(
                          suffixText: 'kg',
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 8,
                          ),
                        ),
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^\d+\.?\d{0,1}'),
                          ),
                        ],
                        onChanged: _updateGoalRate,
                      ),
                    ),
                  ],
                ),

                // Description du taux
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    _selectedWeightGoal == WeightGoal.lose
                        ? '$_goalRate kg par semaine (${(_goalRate * 1000).toStringAsFixed(0)} g/semaine)'
                        : '$_goalRate kg par semaine (${(_goalRate * 1000).toStringAsFixed(0)} g/semaine)',
                    style: theme.textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 16),

                // Information sur la perte/prise de poids
                Card(
                  color: _selectedWeightGoal == WeightGoal.lose
                      ? PremiumTheme.error.withOpacity(0.1)
                      : PremiumTheme.success.withOpacity(0.1),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: _selectedWeightGoal == WeightGoal.lose
                                  ? PremiumTheme.error
                                  : PremiumTheme.success,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Bon à savoir',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: _selectedWeightGoal == WeightGoal.lose
                                    ? PremiumTheme.error
                                    : PremiumTheme.success,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _selectedWeightGoal == WeightGoal.lose
                              ? 'Une perte de poids saine et durable se situe entre 0,5 et 1 kg par semaine. Une perte trop rapide peut entraîner une perte de masse musculaire et un effet yo-yo.'
                              : 'Une prise de poids saine se situe entre 0,2 et 0,5 kg par semaine. Cela favorise la prise de masse musculaire plutôt que de graisse.',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Estimation du temps
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Estimation',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildEstimationTable(),
                      ],
                    ),
                  ),
                ),
              ],
            ),

          // Maintien du poids
          if (_selectedWeightGoal == WeightGoal.maintain)
            Card(
              color: PremiumTheme.primaryColor.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: PremiumTheme.primaryColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Maintien du poids',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: PremiumTheme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Nous calculerons vos besoins caloriques pour maintenir votre poids actuel de ${widget.userProfile.weightKg} kg. Vous pourrez ajuster votre alimentation en fonction de vos activités et de vos objectifs de santé.',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEstimationTable() {
    // Calculer la différence de poids souhaitée
    double targetWeightDiff = 5.0; // 5kg par défaut

    // Calculer le temps nécessaire
    int weeksToReachGoal = (targetWeightDiff / _goalRate).ceil();
    int monthsToReachGoal = (weeksToReachGoal / 4.3).ceil();

    return Column(
      children: [
        RichText(
          text: TextSpan(
            style: Theme.of(context).textTheme.bodyMedium,
            children: [
              TextSpan(
                text: 'À ce rythme, ',
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
              TextSpan(
                text: _selectedWeightGoal == WeightGoal.lose
                    ? 'perdre 5 kg'
                    : 'prendre 5 kg',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _selectedWeightGoal == WeightGoal.lose
                      ? PremiumTheme.error
                      : PremiumTheme.success,
                ),
              ),
              TextSpan(
                text: ' vous prendrait environ ',
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
              TextSpan(
                text: '$weeksToReachGoal semaines',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextSpan(
                text: ' (environ $monthsToReachGoal mois).',
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Ces estimations sont indicatives et peuvent varier en fonction de nombreux facteurs individuels.',
          style: TextStyle(
            fontStyle: FontStyle.italic,
            fontSize: 12,
            color: Theme.of(context).textTheme.bodySmall?.color,
          ),
        ),
      ],
    );
  }
}
