import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lym_nutrition/domain/entities/user_profile.dart';
import 'package:lym_nutrition/presentation/themes/lym_design_system.dart';

class ActivityLevelStep extends StatefulWidget {
  final UserProfile userProfile;
  final Function(UserProfile) onUpdateProfile;
  final VoidCallback onNextRequested;

  const ActivityLevelStep({
    Key? key,
    required this.userProfile,
    required this.onUpdateProfile,
    required this.onNextRequested,
  }) : super(key: key);

  @override
  State<ActivityLevelStep> createState() => ActivityLevelStepState();
}

class ActivityLevelStepState extends State<ActivityLevelStep> {
  late ActivityLevel _selectedActivityLevel;
  late List<UserSportActivity> _sportActivities;
  bool _showAddActivityForm = false;

  final TextEditingController _sportNameController = TextEditingController();
  final TextEditingController _minutesController = TextEditingController();
  final TextEditingController _sessionsController = TextEditingController();

  SportIntensity _selectedIntensity = SportIntensity.medium;
  bool _useCustomSport = false;
  String? _selectedCommonSport;

  // Common sports list with French names and default intensities
  final List<Map<String, dynamic>> _commonSports = [
    {
      'name': 'Course à pied',
      'icon': Icons.directions_run,
      'intensity': SportIntensity.medium
    },
    {
      'name': 'Natation',
      'icon': Icons.pool,
      'intensity': SportIntensity.medium
    },
    {
      'name': 'Cyclisme',
      'icon': Icons.directions_bike,
      'intensity': SportIntensity.medium
    },
    {
      'name': 'Musculation',
      'icon': Icons.fitness_center,
      'intensity': SportIntensity.high
    },
    {
      'name': 'Football',
      'icon': Icons.sports_soccer,
      'intensity': SportIntensity.high
    },
    {
      'name': 'Tennis',
      'icon': Icons.sports_tennis,
      'intensity': SportIntensity.medium
    },
    {
      'name': 'Basketball',
      'icon': Icons.sports_basketball,
      'intensity': SportIntensity.high
    },
    {
      'name': 'Yoga',
      'icon': Icons.self_improvement,
      'intensity': SportIntensity.low
    },
    {
      'name': 'Randonnée',
      'icon': Icons.hiking,
      'intensity': SportIntensity.medium
    },
    {
      'name': 'Danse',
      'icon': Icons.music_note,
      'intensity': SportIntensity.medium
    },
  ];

  @override
  void initState() {
    super.initState();
    _selectedActivityLevel = widget.userProfile.activityLevel;
    _sportActivities =
        List<UserSportActivity>.from(widget.userProfile.sportActivities);
  }

  @override
  void dispose() {
    _sportNameController.dispose();
    _minutesController.dispose();
    _sessionsController.dispose();
    super.dispose();
  }

  void _updateProfile() {
    final updated = widget.userProfile.copyWith(
      activityLevel: _selectedActivityLevel,
      sportActivities: List<UserSportActivity>.from(_sportActivities),
    );
    widget.onUpdateProfile(updated);
  }

  void _toggleAddActivityForm() {
    setState(() {
      _showAddActivityForm = !_showAddActivityForm;
      if (_showAddActivityForm) {
        _sportNameController.clear();
        _minutesController.text = '30';
        _sessionsController.text = '3';
        _selectedIntensity = SportIntensity.medium;
        _useCustomSport = false;
        _selectedCommonSport = null;
      }
    });
  }

  void _showErrorSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message,
            style: LymDesignSystem.textTheme.bodyMedium
                ?.copyWith(color: LymDesignSystem.white)),
        backgroundColor: LymDesignSystem.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(LymDesignSystem.radiusMd)),
        margin: const EdgeInsets.all(LymDesignSystem.spacing16),
      ),
    );
  }

  void _addSportActivity() {
    String name;
    SportIntensity intensity;

    if (_useCustomSport) {
      if (_sportNameController.text.trim().isEmpty) {
        _showErrorSnack('Veuillez remplir le nom de l\'activité.');
        return;
      }
      name = _sportNameController.text.trim();
      intensity = _selectedIntensity;
    } else {
      if (_selectedCommonSport == null) {
        _showErrorSnack('Veuillez sélectionner un sport.');
        return;
      }
      final selected =
          _commonSports.firstWhere((s) => s['name'] == _selectedCommonSport);
      name = selected['name'] as String;
      intensity = selected['intensity'] as SportIntensity;
    }

    if (_minutesController.text.isEmpty || _sessionsController.text.isEmpty) {
      _showErrorSnack('Veuillez remplir tous les champs d\'activité.');
      return;
    }

    final minutes = int.tryParse(_minutesController.text) ?? 30;
    final sessions = int.tryParse(_sessionsController.text) ?? 3;

    final newActivity = UserSportActivity(
      name: name,
      intensity: intensity,
      minutesPerSession: minutes,
      sessionsPerWeek: sessions,
    );

    setState(() {
      _sportActivities.add(newActivity);
      _showAddActivityForm = false;
    });

    _updateProfile();
  }

  void _removeSportActivity(int index) {
    setState(() {
      _sportActivities.removeAt(index);
    });
    _updateProfile();
  }

  String _getActivityLevelLabel(ActivityLevel level) {
    switch (level) {
      case ActivityLevel.sedentary:
        return 'Sédentaire';
      case ActivityLevel.lightlyActive:
        return 'Légèrement Actif';
      case ActivityLevel.moderatelyActive:
        return 'Modérément Actif';
      case ActivityLevel.veryActive:
        return 'Très Actif';
      case ActivityLevel.extremelyActive:
        return 'Extrêmement Actif';
    }
  }

  String _getActivityLevelDescription(ActivityLevel level) {
    switch (level) {
      case ActivityLevel.sedentary:
        return 'Activité physique minimale, travail de bureau.';
      case ActivityLevel.lightlyActive:
        return 'Exercice léger 1-3 jours/semaine.';
      case ActivityLevel.moderatelyActive:
        return 'Exercice modéré 3-5 jours/semaine.';
      case ActivityLevel.veryActive:
        return 'Exercice intense 6-7 jours/semaine.';
      case ActivityLevel.extremelyActive:
        return 'Exercice très intense, travail physique ou athlète professionnel.';
    }
  }

  String _getIntensityLabel(SportIntensity intensity) {
    switch (intensity) {
      case SportIntensity.low:
        return 'Faible';
      case SportIntensity.medium:
        return 'Modérée';
      case SportIntensity.high:
        return 'Élevée';
      case SportIntensity.extreme:
        return 'Extrême';
    }
  }

  Color _getIntensityColor(SportIntensity intensity) {
    switch (intensity) {
      case SportIntensity.low:
        return LymDesignSystem.success;
      case SportIntensity.medium:
        return LymDesignSystem.info;
      case SportIntensity.high:
        return LymDesignSystem.amber;
      case SportIntensity.extreme:
        return LymDesignSystem.error;
    }
  }

  IconData _getIntensityIcon(SportIntensity intensity) {
    switch (intensity) {
      case SportIntensity.low:
        return Icons.self_improvement_outlined;
      case SportIntensity.medium:
        return Icons.directions_run_outlined;
      case SportIntensity.high:
        return Icons.fitness_center_outlined;
      case SportIntensity.extreme:
        return Icons.local_fire_department_outlined;
    }
  }

  bool validateAndProceed() {
    _updateProfile();
    widget.onNextRequested();
    return true;
  }

  @override
  Widget build(BuildContext context) {
    const Color currentAccentColor = LymDesignSystem.coral;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(LymDesignSystem.spacing16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Niveau d\'Activité Général',
            style: LymDesignSystem.textTheme.headlineSmall?.copyWith(
              color: LymDesignSystem.gray800,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: LymDesignSystem.spacing4),
          Text(
            'À quel point êtes-vous actif dans une journée typique, en excluant les entraînements spécifiques?',
            style: LymDesignSystem.textTheme.bodyMedium?.copyWith(
              color: LymDesignSystem.gray600,
            ),
          ),
          const SizedBox(height: LymDesignSystem.spacing16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: ActivityLevel.values.length,
            itemBuilder: (context, index) {
              final activityLevel = ActivityLevel.values[index];
              final isSelected = _selectedActivityLevel == activityLevel;
              return Card(
                elevation: isSelected
                    ? LymDesignSystem.elevationSm
                    : LymDesignSystem.elevationXs,
                margin: const EdgeInsets.only(bottom: LymDesignSystem.spacing8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(LymDesignSystem.radiusMd),
                  side: BorderSide(
                    color: isSelected
                        ? currentAccentColor
                        : LymDesignSystem.gray300,
                    width: isSelected
                        ? LymDesignSystem.borderWidthMedium
                        : LymDesignSystem.borderWidthThin,
                  ),
                ),
                child: RadioListTile<ActivityLevel>(
                  title: Text(
                    _getActivityLevelLabel(activityLevel),
                    style: LymDesignSystem.textTheme.titleMedium?.copyWith(
                      color: LymDesignSystem.gray800,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  subtitle: Text(
                    _getActivityLevelDescription(activityLevel),
                    style: LymDesignSystem.textTheme.bodySmall
                        ?.copyWith(color: LymDesignSystem.gray600),
                  ),
                  value: activityLevel,
                  groupValue: _selectedActivityLevel,
                  onChanged: (ActivityLevel? value) {
                    if (value != null) {
                      setState(() => _selectedActivityLevel = value);
                      _updateProfile();
                    }
                  },
                  activeColor: currentAccentColor,
                  secondary: Icon(
                    activityLevel == ActivityLevel.sedentary
                        ? Icons.weekend_outlined
                        : activityLevel == ActivityLevel.lightlyActive
                            ? Icons.directions_walk_rounded
                            : activityLevel == ActivityLevel.moderatelyActive
                                ? Icons.fitness_center_outlined
                                : activityLevel == ActivityLevel.veryActive
                                    ? Icons.directions_run_rounded
                                    : Icons.local_fire_department_rounded,
                    color: isSelected
                        ? currentAccentColor
                        : LymDesignSystem.gray500,
                    size: 28,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: LymDesignSystem.spacing12,
                      horizontal: LymDesignSystem.spacing16),
                  controlAffinity: ListTileControlAffinity.trailing,
                ),
              );
            },
          ),
          const SizedBox(height: LymDesignSystem.spacing24),
          const Divider(
              color: LymDesignSystem.gray300,
              thickness: LymDesignSystem.borderWidthThin),
          const SizedBox(height: LymDesignSystem.spacing24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sports et Activités Spécifiques',
                      style: LymDesignSystem.textTheme.headlineSmall?.copyWith(
                          color: LymDesignSystem.gray800,
                          fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: LymDesignSystem.spacing4),
                    Text(
                      'Enregistrez tous les sports ou entraînements réguliers que vous pratiquez.',
                      style: LymDesignSystem.textTheme.bodyMedium
                          ?.copyWith(color: LymDesignSystem.gray600),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: LymDesignSystem.spacing8),
              ElevatedButton.icon(
                onPressed: _toggleAddActivityForm,
                icon: Icon(
                    _showAddActivityForm
                        ? Icons.close_rounded
                        : Icons.add_rounded,
                    size: 20),
                label: Text(_showAddActivityForm ? 'Annuler' : 'Ajouter'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _showAddActivityForm
                      ? LymDesignSystem.gray500
                      : currentAccentColor,
                  foregroundColor: LymDesignSystem.white,
                  padding: const EdgeInsets.symmetric(
                      horizontal: LymDesignSystem.spacing16,
                      vertical: LymDesignSystem.spacing12),
                  textStyle: LymDesignSystem.textTheme.labelLarge,
                ),
              ),
            ],
          ),
          const SizedBox(height: LymDesignSystem.spacing16),
          AnimatedSwitcher(
            duration: LymDesignSystem.durationMedium,
            transitionBuilder: (child, animation) => SizeTransition(
                sizeFactor: animation,
                child: FadeTransition(opacity: animation, child: child)),
            child: _showAddActivityForm
                ? Card(
                    key: const ValueKey('addActivityForm'),
                    elevation: LymDesignSystem.elevationSm,
                    margin: const EdgeInsets.only(
                        bottom: LymDesignSystem.spacing16,
                        top: LymDesignSystem.spacing8),
                    shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(LymDesignSystem.radiusLg)),
                    child: Padding(
                      padding: const EdgeInsets.all(LymDesignSystem.spacing16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: ChoiceChip(
                                  label: const Text('Sports Populaires'),
                                  selected: !_useCustomSport,
                                  onSelected: (selected) => setState(() {
                                    _useCustomSport = false;
                                    _selectedCommonSport = null;
                                  }),
                                  selectedColor:
                                      currentAccentColor.withValues(alpha: 0.15),
                                  checkmarkColor: currentAccentColor,
                                ),
                              ),
                              const SizedBox(width: LymDesignSystem.spacing8),
                              Expanded(
                                child: ChoiceChip(
                                  label: const Text('Sport Personnalisé'),
                                  selected: _useCustomSport,
                                  onSelected: (selected) => setState(() {
                                    _useCustomSport = true;
                                    _selectedCommonSport = null;
                                  }),
                                  selectedColor:
                                      currentAccentColor.withValues(alpha: 0.15),
                                  checkmarkColor: currentAccentColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: LymDesignSystem.spacing16),
                          if (!_useCustomSport) ...[
                            Text('Choisissez un sport:',
                                style: LymDesignSystem.textTheme.titleMedium
                                    ?.copyWith(color: LymDesignSystem.gray700)),
                            const SizedBox(height: LymDesignSystem.spacing8),
                            Wrap(
                              spacing: LymDesignSystem.spacing8,
                              runSpacing: LymDesignSystem.spacing8,
                              children: _commonSports.map((sport) {
                                final isSelected =
                                    _selectedCommonSport == sport['name'];
                                return ChoiceChip(
                                  label: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(sport['icon'], size: 16),
                                        const SizedBox(width: 4),
                                        Text(sport['name'])
                                      ]),
                                  selected: isSelected,
                                  onSelected: (selected) => setState(() =>
                                      _selectedCommonSport = selected
                                          ? sport['name'] as String
                                          : null),
                                  selectedColor:
                                      currentAccentColor.withValues(alpha: 0.15),
                                  checkmarkColor: currentAccentColor,
                                );
                              }).toList(),
                            ),
                          ] else ...[
                            TextFormField(
                              controller: _sportNameController,
                              decoration: InputDecoration(
                                labelText: 'Nom de l\'Activité',
                                hintText: 'ex: Escalade, Boxe, Pilates',
                                prefixIcon: const Icon(Icons.sports_soccer_outlined,
                                    color: currentAccentColor),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                        LymDesignSystem.radiusMd)),
                                focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                        LymDesignSystem.radiusMd),
                                    borderSide: const BorderSide(
                                        color: currentAccentColor,
                                        width:
                                            LymDesignSystem.borderWidthMedium)),
                              ),
                              style: LymDesignSystem.textTheme.bodyLarge
                                  ?.copyWith(color: LymDesignSystem.gray800),
                              textCapitalization: TextCapitalization.sentences,
                            ),
                            const SizedBox(height: LymDesignSystem.spacing16),
                            Text('Niveau d\'Intensité',
                                style: LymDesignSystem.textTheme.titleMedium
                                    ?.copyWith(color: LymDesignSystem.gray700)),
                            const SizedBox(height: LymDesignSystem.spacing8),
                            Wrap(
                              spacing: LymDesignSystem.spacing8,
                              runSpacing: LymDesignSystem.spacing8,
                              children: SportIntensity.values.map((intensity) {
                                final isSelected =
                                    _selectedIntensity == intensity;
                                final intensityColor =
                                    _getIntensityColor(intensity);
                                return ChoiceChip(
                                  label: Text(_getIntensityLabel(intensity)),
                                  avatar: Icon(_getIntensityIcon(intensity),
                                      color: isSelected
                                          ? LymDesignSystem.white
                                          : intensityColor,
                                      size: 18),
                                  selected: isSelected,
                                  onSelected: (selected) => setState(
                                      () => _selectedIntensity = intensity),
                                  selectedColor: intensityColor,
                                  labelStyle: TextStyle(
                                      color: isSelected
                                          ? LymDesignSystem.white
                                          : LymDesignSystem.gray800),
                                  backgroundColor:
                                      intensityColor.withValues(alpha: 0.1),
                                );
                              }).toList(),
                            ),
                          ],
                          const SizedBox(height: LymDesignSystem.spacing16),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _minutesController,
                                  decoration: InputDecoration(
                                    labelText: 'Min/Session',
                                    hintText: 'ex: 30',
                                    prefixIcon: const Icon(Icons.timer_outlined,
                                        color: currentAccentColor),
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                            LymDesignSystem.radiusMd)),
                                    focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                            LymDesignSystem.radiusMd),
                                        borderSide: const BorderSide(
                                            color: currentAccentColor,
                                            width: LymDesignSystem
                                                .borderWidthMedium)),
                                  ),
                                  style: LymDesignSystem.textTheme.bodyLarge
                                      ?.copyWith(
                                          color: LymDesignSystem.gray800),
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly
                                  ],
                                ),
                              ),
                              const SizedBox(width: LymDesignSystem.spacing16),
                              Expanded(
                                child: TextFormField(
                                  controller: _sessionsController,
                                  decoration: InputDecoration(
                                    labelText: 'Sessions/Sem.',
                                    hintText: 'ex: 3',
                                    prefixIcon: const Icon(
                                        Icons.calendar_today_outlined,
                                        color: currentAccentColor),
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                            LymDesignSystem.radiusMd)),
                                    focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                            LymDesignSystem.radiusMd),
                                        borderSide: const BorderSide(
                                            color: currentAccentColor,
                                            width: LymDesignSystem
                                                .borderWidthMedium)),
                                  ),
                                  style: LymDesignSystem.textTheme.bodyLarge
                                      ?.copyWith(
                                          color: LymDesignSystem.gray800),
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: LymDesignSystem.spacing24),
                          Center(
                            child: ElevatedButton.icon(
                              onPressed: _addSportActivity,
                              icon: const Icon(Icons.check_circle_outline_rounded),
                              label: const Text('Ajouter cette Activité'),
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: currentAccentColor,
                                  foregroundColor: LymDesignSystem.white,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: LymDesignSystem.spacing24,
                                      vertical: LymDesignSystem.spacing12)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : const SizedBox.shrink(key: ValueKey('emptyForm')),
          ),
          if (_sportActivities.isEmpty && !_showAddActivityForm) ...[
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: LymDesignSystem.spacing16),
              child: Center(
                child: Column(
                  children: [
                    const Icon(Icons.fitness_center_rounded,
                        size: 48, color: LymDesignSystem.gray400),
                    const SizedBox(height: LymDesignSystem.spacing8),
                    Text('Aucune activité spécifique ajoutée.',
                        style: LymDesignSystem.textTheme.bodyMedium
                            ?.copyWith(color: LymDesignSystem.gray600)),
                    Text(
                        'Cliquez sur "Ajouter" pour enregistrer vos entraînements.',
                        style: LymDesignSystem.textTheme.bodySmall
                            ?.copyWith(color: LymDesignSystem.gray500)),
                  ],
                ),
              ),
            ),
          ] else ...[
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _sportActivities.length,
              itemBuilder: (context, index) {
                final activity = _sportActivities[index];
                final intensityColor = _getIntensityColor(activity.intensity);
                return Card(
                  elevation: LymDesignSystem.elevationXs,
                  margin: const EdgeInsets.only(bottom: LymDesignSystem.spacing8),
                  shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(LymDesignSystem.radiusMd),
                      side: const BorderSide(
                          color: LymDesignSystem.gray300,
                          width: LymDesignSystem.borderWidthThin)),
                  child: ListTile(
                    leading: CircleAvatar(
                        backgroundColor: intensityColor.withValues(alpha: 0.15),
                        child: Icon(_getIntensityIcon(activity.intensity),
                            color: intensityColor, size: 22)),
                    title: Text(activity.name,
                        style: LymDesignSystem.textTheme.titleSmall?.copyWith(
                            color: LymDesignSystem.gray800,
                            fontWeight: FontWeight.w600)),
                    subtitle: Text(
                        '${_getIntensityLabel(activity.intensity)} - ${activity.minutesPerSession} min x ${activity.sessionsPerWeek} fois/sem.',
                        style: LymDesignSystem.textTheme.bodySmall
                            ?.copyWith(color: LymDesignSystem.gray600)),
                    trailing: IconButton(
                        icon: Icon(Icons.delete_outline_rounded,
                            color: LymDesignSystem.error.withValues(alpha: 0.8),
                            size: 22),
                        onPressed: () => _removeSportActivity(index),
                        tooltip: 'Supprimer l\'Activité',
                        splashRadius: 20),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: LymDesignSystem.spacing12,
                        horizontal: LymDesignSystem.spacing12),
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}
