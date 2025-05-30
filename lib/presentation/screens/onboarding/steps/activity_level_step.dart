// lib/presentation/screens/onboarding/steps/activity_level_step.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lym_nutrition/domain/entities/user_profile.dart';
import 'package:lym_nutrition/presentation/themes/premium_theme.dart';
import 'package:lym_nutrition/presentation/widgets/onboarding_step_container.dart';
import 'package:lym_nutrition/data/sports_data.dart';

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
  final _sportSearchController = TextEditingController();
  final _minutesController = TextEditingController();
  final _sessionsController = TextEditingController();
  SportIntensity _selectedIntensity = SportIntensity.medium;
  SportData? _selectedSport;
  List<SportData> _filteredSports = [];
  String _selectedCategory = 'Tous';
  bool _showSportsList = false;

  @override
  void initState() {
    super.initState();
    _selectedActivityLevel = widget.userProfile.activityLevel;
    _sportActivities = List.from(widget.userProfile.sportActivities);
    _filteredSports = SportsDatabase.sports;
  }

  @override
  void dispose() {
    _sportSearchController.dispose();
    _minutesController.dispose();
    _sessionsController.dispose();
    super.dispose();
  }

  void _filterSports(String query) {
    setState(() {
      if (query.isEmpty && _selectedCategory == 'Tous') {
        _filteredSports = SportsDatabase.sports;
      } else if (query.isEmpty) {
        _filteredSports = SportsDatabase.getSportsByCategory(_selectedCategory);
      } else {
        _filteredSports = SportsDatabase.searchSports(query);
        if (_selectedCategory != 'Tous') {
          _filteredSports = _filteredSports
              .where((sport) => sport.category == _selectedCategory)
              .toList();
        }
      }
    });
  }

  void _onCategoryChanged(String category) {
    setState(() {
      _selectedCategory = category;
      _filterSports(_sportSearchController.text);
    });
  }

  void _selectSport(SportData sport) {
    setState(() {
      _selectedSport = sport;
      _sportSearchController.text = sport.name;
      _selectedIntensity = sport.recommendedIntensity;
      _showSportsList = false;
    });
  }

  void _toggleAddActivityForm() {
    setState(() {
      _showAddActivityForm = !_showAddActivityForm;
      if (_showAddActivityForm) {
        // Réinitialiser le formulaire
        _sportSearchController.clear();
        _minutesController.text = "30";
        _sessionsController.text = "3";
        _selectedIntensity = SportIntensity.medium;
        _selectedSport = null;
        _showSportsList = false;
        _filteredSports = SportsDatabase.sports;
      }
    });
  }

  void _addSportActivity() {
    if (_selectedSport == null ||
        _minutesController.text.isEmpty ||
        _sessionsController.text.isEmpty) {
      // Afficher un message d'erreur
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner un sport et remplir tous les champs'),
          backgroundColor: PremiumTheme.error,
        ),
      );
      return;
    }

    final newActivity = UserSportActivity(
      name: _selectedSport!.name,
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

  String _getIntensityLabel(SportIntensity intensity) {
    switch (intensity) {
      case SportIntensity.low:
        return 'Faible';
      case SportIntensity.medium:
        return 'Moyenne';
      case SportIntensity.high:
        return 'Élevée';
      case SportIntensity.extreme:
        return 'Extrême';
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
                    // Sport selection with search
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          controller: _sportSearchController,
                          decoration: InputDecoration(
                            labelText: 'Rechercher un sport',
                            hintText: 'Ex: Course, Natation, Yoga...',
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: _selectedSport != null
                                ? Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        _selectedSport!.icon,
                                        style: const TextStyle(fontSize: 20),
                                      ),
                                      const SizedBox(width: 8),
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _selectedSport = null;
                                            _sportSearchController.clear();
                                            _showSportsList = false;
                                          });
                                        },
                                        child: const Icon(Icons.clear),
                                      ),
                                    ],
                                  )
                                : IconButton(
                                    icon: Icon(_showSportsList
                                        ? Icons.keyboard_arrow_up
                                        : Icons.keyboard_arrow_down),
                                    onPressed: () {
                                      setState(() {
                                        _showSportsList = !_showSportsList;
                                        if (_showSportsList) {
                                          _filterSports(_sportSearchController.text);
                                        }
                                      });
                                    },
                                  ),
                          ),
                          textCapitalization: TextCapitalization.sentences,
                          onChanged: (value) {
                            _filterSports(value);
                            setState(() {
                              _showSportsList = value.isNotEmpty || _showSportsList;
                            });
                          },
                          onTap: () {
                            setState(() {
                              _showSportsList = true;
                              _filterSports(_sportSearchController.text);
                            });
                          },
                        ),

                        // Category filter
                        if (_showSportsList) ...[
                          const SizedBox(height: 8),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                'Tous',
                                ...SportsDatabase.getAllCategories(),
                              ].map((category) {
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: FilterChip(
                                    label: Text(category),
                                    selected: _selectedCategory == category,
                                    onSelected: (selected) {
                                      if (selected) {
                                        _onCategoryChanged(category);
                                      }
                                    },
                                    selectedColor: PremiumTheme.primaryColor.withOpacity(0.2),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],

                        // Sports list
                        if (_showSportsList && _filteredSports.isNotEmpty)
                          Container(
                            margin: const EdgeInsets.only(top: 8),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            constraints: const BoxConstraints(maxHeight: 200),
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: _filteredSports.length,
                              itemBuilder: (context, index) {
                                final sport = _filteredSports[index];
                                return ListTile(
                                  dense: true,
                                  leading: Text(
                                    sport.icon,
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                  title: Text(sport.name),
                                  subtitle: Text(sport.category),
                                  trailing: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: _getIntensityColor(sport.recommendedIntensity)
                                          .withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: _getIntensityColor(sport.recommendedIntensity),
                                        width: 1,
                                      ),
                                    ),
                                    child: Text(
                                      _getIntensityLabel(sport.recommendedIntensity),
                                      style: TextStyle(
                                        color: _getIntensityColor(sport.recommendedIntensity),
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  onTap: () => _selectSport(sport),
                                );
                              },
                            ),
                          ),

                        if (_showSportsList && _filteredSports.isEmpty)
                          Container(
                            margin: const EdgeInsets.only(top: 8),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Center(
                              child: Text(
                                'Aucun sport trouvé.\nEssayez une autre recherche.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontStyle: FontStyle.italic,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ),
                      ],
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
                final sportData = SportsDatabase.getSportByName(activity.name);
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _getIntensityColor(activity.intensity)
                          .withOpacity(0.2),
                      child: sportData != null
                          ? Text(
                              sportData.icon,
                              style: const TextStyle(fontSize: 20),
                            )
                          : Icon(
                              Icons.sports,
                              color: _getIntensityColor(activity.intensity),
                            ),
                    ),
                    title: Row(
                      children: [
                        Expanded(child: Text(activity.name)),
                        if (sportData != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              sportData.category,
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                      ],
                    ),
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
