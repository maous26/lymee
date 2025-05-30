// lib/presentation/screens/onboarding/steps/activity_level_step.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lym_nutrition/domain/entities/user_profile.dart';
import 'package:lym_nutrition/presentation/themes/premium_theme.dart';
import 'package:lym_nutrition/presentation/widgets/onboarding_step_container.dart';

class ActivityLevelStep extends StatefulWidget {
  final UserProfile userProfile;
  final Function(UserProfile) onUpdateProfile;
  final VoidCallback onNext;

  const ActivityLevelStep({
    Key? key,
    required this.userProfile,
    required this.onUpdateProfile,
    required this.onNext,
  }) : super(key: key);

  @override
  State<ActivityLevelStep> createState() => _ActivityLevelStepState();
}

class _ActivityLevelStepState extends State<ActivityLevelStep> {
  ActivityLevel _selectedActivityLevel = ActivityLevel.moderatelyActive;
  List<UserSportActivity> _sportActivities = [];
  bool _showAddActivityForm = false;
  final _sportNameController = TextEditingController();
  final _minutesController = TextEditingController();
  final _sessionsController = TextEditingController();
  SportIntensity _selectedIntensity = SportIntensity.medium;

  @override
  void initState() {
    super.initState();
    _selectedActivityLevel = widget.userProfile.activityLevel;
    _sportActivities = List.from(widget.userProfile.sportActivities);
  }

  @override
  void dispose() {
    _sportNameController.dispose();
    _minutesController.dispose();
    _sessionsController.dispose();
    super.dispose();
  }

  void _toggleAddActivityForm() {
    setState(() {
      _showAddActivityForm = !_showAddActivityForm;
      if (_showAddActivityForm) {
        // Réinitialiser le formulaire
        _sportNameController.clear();
        _minutesController.text = "30";
        _sessionsController.text = "3";
        _selectedIntensity = SportIntensity.medium;
      }
    });
  }

  void _addSportActivity() {
    if (_sportNameController.text.isEmpty ||
        _minutesController.text.isEmpty ||
        _sessionsController.text.isEmpty) {
      // Afficher un message d'erreur
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez remplir tous les champs'),
          backgroundColor: PremiumTheme.error,
        ),
      );
      return;
    }

    final newActivity = UserSportActivity(
      name: _sportNameController.text,
      intensity: _selectedIntensity,
      minutesPerSession: int.parse(_minutesController.text),
      sessionsPerWeek: int.parse(_sessionsController.text),
    );

    setState(() {
      _sportActivities.add(newActivity);
      _showAddActivityForm = false;
    });
  }

  void _removeSportActivity(int index) {
    setState(() {
      _sportActivities.removeAt(index);
    });
  }

  void _saveAndContinue() {
    // Mettre à jour le profil utilisateur
    final updatedProfile = widget.userProfile.copyWith(
      activityLevel: _selectedActivityLevel,
      sportActivities: _sportActivities,
    );

    widget.onUpdateProfile(updatedProfile);
    widget.onNext();
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

  String _getActivityLevelDescription(ActivityLevel level) {
    switch (level) {
      case ActivityLevel.sedentary:
        return 'Très peu ou pas d\'exercice, travail de bureau';
      case ActivityLevel.lightlyActive:
        return 'Exercice léger 1-3 jours par semaine';
      case ActivityLevel.moderatelyActive:
        return 'Exercice modéré 3-5 jours par semaine';
      case ActivityLevel.veryActive:
        return 'Exercice intense 6-7 jours par semaine';
      case ActivityLevel.extremelyActive:
        return 'Exercice très intense, travail physique ou athlète professionnel';
    }
  }

  String _getIntensityDescription(SportIntensity intensity) {
    switch (intensity) {
      case SportIntensity.low:
        return 'Faible (marche, yoga doux)';
      case SportIntensity.medium:
        return 'Moyenne (jogging, vélo, natation)';
      case SportIntensity.high:
        return 'Élevée (course, HIIT, musculation)';
      case SportIntensity.extreme:
        return 'Extrême (compétition, crossfit intense)';
    }
  }

  Color _getIntensityColor(SportIntensity intensity) {
    switch (intensity) {
      case SportIntensity.low:
        return Colors.green;
      case SportIntensity.medium:
        return Colors.blue;
      case SportIntensity.high:
        return Colors.orange;
      case SportIntensity.extreme:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return OnboardingStepContainer(
      title: 'Votre niveau d\'activité',
      subtitle: 'Aidez-nous à déterminer vos besoins énergétiques',
      onNext: _saveAndContinue,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Niveau d'activité général
          Text(
            'Niveau d\'activité général',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: ActivityLevel.values.length,
            itemBuilder: (context, index) {
              final activityLevel = ActivityLevel.values[index];
              return RadioListTile<ActivityLevel>(
                title: Text(
                  _getActivityLevelLabel(activityLevel),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(_getActivityLevelDescription(activityLevel)),
                value: activityLevel,
                groupValue: _selectedActivityLevel,
                onChanged: (ActivityLevel? value) {
                  if (value != null) {
                    setState(() {
                      _selectedActivityLevel = value;
                    });
                  }
                },
                activeColor: PremiumTheme.primaryColor,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
              );
            },
          ),

          const Divider(height: 32),

          // Sports et activités spécifiques
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Sports et activités',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton.icon(
                onPressed: _toggleAddActivityForm,
                icon: Icon(_showAddActivityForm ? Icons.close : Icons.add),
                label: Text(_showAddActivityForm ? 'Annuler' : 'Ajouter'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _showAddActivityForm
                      ? Colors.grey
                      : PremiumTheme.primaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Formulaire d'ajout d'activité
          if (_showAddActivityForm)
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _sportNameController,
                      decoration: const InputDecoration(
                        labelText: 'Nom de l\'activité',
                        hintText: 'Ex: Course, Natation, Yoga...',
                        prefixIcon: Icon(Icons.sports),
                      ),
                      textCapitalization: TextCapitalization.sentences,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Intensité',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: SportIntensity.values.map((intensity) {
                        return ChoiceChip(
                          label: Text(_getIntensityDescription(intensity)),
                          selected: _selectedIntensity == intensity,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _selectedIntensity = intensity;
                              });
                            }
                          },
                          selectedColor:
                              _getIntensityColor(intensity).withOpacity(0.2),
                          labelStyle: TextStyle(
                            color: _selectedIntensity == intensity
                                ? _getIntensityColor(intensity)
                                : theme.textTheme.bodyMedium?.color,
                            fontWeight: _selectedIntensity == intensity
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        // Minutes par séance
                        Expanded(
                          child: TextFormField(
                            controller: _minutesController,
                            decoration: const InputDecoration(
                              labelText: 'Minutes par séance',
                              hintText: 'Ex: 30',
                              prefixIcon: Icon(Icons.timer),
                            ),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                          ),
                        ),

                        const SizedBox(width: 16),

                        // Séances par semaine
                        Expanded(
                          child: TextFormField(
                            controller: _sessionsController,
                            decoration: const InputDecoration(
                              labelText: 'Séances par semaine',
                              hintText: 'Ex: 3',
                              prefixIcon: Icon(Icons.calendar_today),
                            ),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: _addSportActivity,
                        icon: const Icon(Icons.check),
                        label: const Text('Ajouter cette activité'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: PremiumTheme.primaryColor,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Liste des activités
          if (_sportActivities.isEmpty && !_showAddActivityForm)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Text(
                  'Aucune activité spécifique ajoutée.\nVous pourrez en ajouter plus tard.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _sportActivities.length,
              itemBuilder: (context, index) {
                final activity = _sportActivities[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _getIntensityColor(activity.intensity)
                          .withOpacity(0.2),
                      child: Icon(
                        Icons.sports,
                        color: _getIntensityColor(activity.intensity),
                      ),
                    ),
                    title: Text(activity.name),
                    subtitle: Text(
                      '${_getIntensityDescription(activity.intensity)}\n'
                      '${activity.minutesPerSession} min × ${activity.sessionsPerWeek} fois/semaine',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _removeSportActivity(index),
                      color: PremiumTheme.error,
                    ),
                    isThreeLine: true,
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
