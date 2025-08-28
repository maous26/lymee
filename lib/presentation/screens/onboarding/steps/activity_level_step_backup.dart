// lib/presentation/screens/onboarding/steps/activity_level_step.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lym_nutrition/domain/entities/user_profile.dart';
import 'package:lym_nutrition/presentation/themes/lym_design_system.dart';

class ActivityLevelStep extends StatefulWidget {
  final UserProfile userProfile;
  final Function(UserProfile) onUpdateProfile;
  final VoidCallback onNextRequested; // Changed from onNext

  const ActivityLevelStep({
    Key? key,
    required this.userProfile,
    required this.onUpdateProfile,
    required this.onNextRequested, // Changed from onNext
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  ActivityLevelStepState createState() =>
      ActivityLevelStepState(); // Made state public
}

// ignore: public_member_api_docs
class ActivityLevelStepState extends State<ActivityLevelStep> {
  // Made state public
  late ActivityLevel _selectedActivityLevel;
  late List<UserSportActivity> _sportActivities;
  bool _showAddActivityForm = false;
  final _sportNameController = TextEditingController();
  final _minutesController = TextEditingController();
  final _sessionsController = TextEditingController();
  SportIntensity _selectedIntensity = SportIntensity.medium;
  bool _useCustomSport = false;
  String? _selectedCommonSport;

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

  void _updateProfile() {
    final updatedProfile = widget.userProfile.copyWith(
      activityLevel: _selectedActivityLevel,
      sportActivities: _sportActivities,
    );
    widget.onUpdateProfile(updatedProfile);
  }

  void _toggleAddActivityForm() {
    setState(() {
      _showAddActivityForm = !_showAddActivityForm;
      if (_showAddActivityForm) {
        _sportNameController.clear();
        _minutesController.text = "30";
        _sessionsController.text = "3";
        _selectedIntensity = SportIntensity.medium;
        _useCustomSport = false;
        _selectedCommonSport = null;
      }
    });
  }

  void _addSportActivity() {
    String sportName;
    SportIntensity intensity;

    if (_useCustomSport) {
      if (_sportNameController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Veuillez remplir le nom de l\'activité.',
                style: LymDesignSystem.textTheme.bodyMedium
                    ?.copyWith(color: LymDesignSystem.white)),
            backgroundColor: LymDesignSystem.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(LymDesignSystem.radiusMd)),
            margin: const EdgeInsets.all(LymDesignSystem.spacing16),
          ),
        );
        return;
      }
      sportName = _sportNameController.text;
      intensity = _selectedIntensity;
    } else {
      if (_selectedCommonSport == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Veuillez sélectionner un sport.',
                style: LymDesignSystem.textTheme.bodyMedium
                    ?.copyWith(color: LymDesignSystem.white)),
            backgroundColor: LymDesignSystem.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(LymDesignSystem.radiusMd)),
            margin: const EdgeInsets.all(LymDesignSystem.spacing16),
          ),
        );
        return;
      }
      final selectedSport = _commonSports
          .firstWhere((sport) => sport['name'] == _selectedCommonSport);
      sportName = selectedSport['name'];
      intensity = selectedSport['intensity'];
    }

    if (_minutesController.text.isEmpty || _sessionsController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Veuillez remplir tous les champs d\'activité.',
              style: LymDesignSystem.textTheme.bodyMedium
                  ?.copyWith(color: LymDesignSystem.white)),
          backgroundColor: LymDesignSystem.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(LymDesignSystem.radiusMd)),
          margin: const EdgeInsets.all(LymDesignSystem.spacing16),
        ),
      );
      return;
    }

    final newActivity = UserSportActivity(
      name: sportName,
      intensity: intensity,
      minutesPerSession: int.tryParse(_minutesController.text) ?? 30,
      sessionsPerWeek: int.tryParse(_sessionsController.text) ?? 3,
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

  // Common sports list with French names
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
    // Using LymDesignSystem colors
    switch (intensity) {
      case SportIntensity.low:
        return LymDesignSystem.success; // Green for low
      case SportIntensity.medium:
        return LymDesignSystem.info; // Blue for medium
      case SportIntensity.high:
        return LymDesignSystem.amber; // Amber/Yellow for high
      case SportIntensity.extreme:
        return LymDesignSystem.error; // Red for extreme
    }
  }

  IconData _getIntensityIcon(SportIntensity intensity) {
    switch (intensity) {
      case SportIntensity.low:
        return Icons.self_improvement_outlined; // Yoga/Relaxation
      case SportIntensity.medium:
        return Icons.directions_run_outlined; // General activity
      case SportIntensity.high:
        return Icons.fitness_center_outlined; // Weights/Gym
      case SportIntensity.extreme:
        return Icons.local_fire_department_outlined; // Intense
    }
  }

  // New method for validation
  bool validateAndProceed() {
    // For this step, we might not have complex validation,
    // but we ensure the profile is updated before proceeding.
    _updateProfile();
    widget.onNextRequested();
    return true; // Assuming selection is always valid or handled by UI
  }

  @override
  Widget build(BuildContext context) {
    // The parent LymOnboardingContainer handles title, subtitle, and navigation.
    // This widget returns only its specific form content.
    const currentAccentColor = LymDesignSystem.coral; // Accent for this step

    return SingleChildScrollView(
      padding: const EdgeInsets.all(LymDesignSystem.spacing16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Niveau d\'Activité Général',
            style: LymDesignSystem.textTheme.headlineSmall?.copyWith(
                color: LymDesignSystem.gray800, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: LymDesignSystem.spacing4),
          Text(
            'À quel point êtes-vous actif dans une journée typique, en excluant les entraînements spécifiques?',
            style: LymDesignSystem.textTheme.bodyMedium
                ?.copyWith(color: LymDesignSystem.gray600),
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
                            isSelected ? FontWeight.bold : FontWeight.normal),
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
                      setState(() {
                        _selectedActivityLevel = value;
                      });
                      _updateProfile();
                    }
                  },
                  activeColor: currentAccentColor,
                  secondary: Icon(
                    // Added relevant icons
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
                      horizontal:
                          LymDesignSystem.spacing16), // Adjusted padding
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
                  textStyle:
                      LymDesignSystem.textTheme.labelLarge, // Added textStyle
                ),
              ),
            ],
          ),
          const SizedBox(height: LymDesignSystem.spacing16),
          AnimatedSwitcher(
            duration: LymDesignSystem.durationMedium,
            transitionBuilder: (Widget child, Animation<double> animation) {
              return SizeTransition(
                sizeFactor: animation,
                child: FadeTransition(opacity: animation, child: child),
              );
            },
            child: _showAddActivityForm
                ? Card(
                    key: const ValueKey('addActivityForm'),
                    elevation: LymDesignSystem.elevationSm,
                    margin: const EdgeInsets.only(
                        bottom: LymDesignSystem.spacing16,
                        top: LymDesignSystem.spacing8), // Added top margin
                    shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(LymDesignSystem.radiusLg)),
                    child: Padding(
                      padding: const EdgeInsets.all(LymDesignSystem.spacing16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFormField(
                            controller: _sportNameController,
                            decoration: InputDecoration(
                              labelText: 'Activity Name',
                              hintText: 'e.g., Running, Swimming, Yoga',
                              prefixIcon: const Icon(Icons.sports_soccer_outlined,
                                  color: currentAccentColor),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                      LymDesignSystem
                                          .radiusMd)), // Added border styling
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                    LymDesignSystem.radiusMd),
                                borderSide: const BorderSide(
                                    color: currentAccentColor,
                                    width: LymDesignSystem.borderWidthMedium),
                              ),
                            ),
                            style: LymDesignSystem.textTheme.bodyLarge
                                ?.copyWith(color: LymDesignSystem.gray800),
                            textCapitalization: TextCapitalization.sentences,
                          ),
                          const SizedBox(height: LymDesignSystem.spacing16),
                          Text(
                            'Intensity Level',
                            style: LymDesignSystem.textTheme.titleMedium
                                ?.copyWith(color: LymDesignSystem.gray700),
                          ),
                          const SizedBox(height: LymDesignSystem.spacing8),
                          Wrap(
                            spacing: LymDesignSystem.spacing8,
                            runSpacing: LymDesignSystem.spacing8,
                            children: SportIntensity.values.map((intensity) {
                              final bool isSelected =
                                  _selectedIntensity == intensity;
                              final Color intensityColor =
                                  _getIntensityColor(intensity);
                              return ChoiceChip(
                                label: Text(_getIntensityLabel(intensity)),
                                avatar: Icon(_getIntensityIcon(intensity),
                                    color: isSelected
                                        ? LymDesignSystem.white
                                        : intensityColor,
                                    size: 18),
                                selected: isSelected,
                                onSelected: (selected) {
                                  if (selected) {
                                    setState(
                                        () => _selectedIntensity = intensity);
                                  }
                                },
                                selectedColor: intensityColor,
                                backgroundColor: LymDesignSystem.gray100,
                                labelStyle: LymDesignSystem.textTheme.bodyMedium
                                    ?.copyWith(
                                  color: isSelected
                                      ? LymDesignSystem.white
                                      : LymDesignSystem.gray800,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                                pressElevation: LymDesignSystem.elevationXs,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        LymDesignSystem.radiusSm),
                                    side: BorderSide(
                                        color: isSelected
                                            ? intensityColor
                                            : LymDesignSystem.gray300)),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: LymDesignSystem.spacing12,
                                    vertical: LymDesignSystem.spacing8),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: LymDesignSystem.spacing16),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _minutesController,
                                  decoration: InputDecoration(
                                    labelText: 'Mins/Session',
                                    hintText: 'e.g., 30',
                                    prefixIcon: const Icon(Icons.timer_outlined,
                                        color: currentAccentColor),
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                            LymDesignSystem
                                                .radiusMd)), // Added border styling
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                          LymDesignSystem.radiusMd),
                                      borderSide: const BorderSide(
                                          color: currentAccentColor,
                                          width: LymDesignSystem
                                              .borderWidthMedium),
                                    ),
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
                                    labelText: 'Sessions/Week',
                                    hintText: 'e.g., 3',
                                    prefixIcon: const Icon(
                                        Icons.calendar_today_outlined,
                                        color: currentAccentColor),
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                            LymDesignSystem
                                                .radiusMd)), // Added border styling
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                          LymDesignSystem.radiusMd),
                                      borderSide: const BorderSide(
                                          color: currentAccentColor,
                                          width: LymDesignSystem
                                              .borderWidthMedium),
                                    ),
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
                              icon: const Icon(
                                  Icons.check_circle_outline_rounded),
                              label: const Text('Add This Activity'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: currentAccentColor,
                                foregroundColor: LymDesignSystem.white,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: LymDesignSystem.spacing24,
                                    vertical: LymDesignSystem.spacing12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : const SizedBox.shrink(
                    key: ValueKey(
                        'emptyForm')), // Ensure a child when form is not shown
          ),
          if (_sportActivities.isEmpty && !_showAddActivityForm)
            Padding(
              padding: const EdgeInsets.symmetric(
                  vertical: LymDesignSystem.spacing16),
              child: Center(
                child: Column(
                  children: [
                    const Icon(Icons.fitness_center_rounded,
                        size: 48, color: LymDesignSystem.gray400),
                    const SizedBox(height: LymDesignSystem.spacing8),
                    Text(
                      'No specific activities added yet.',
                      style: LymDesignSystem.textTheme.bodyMedium
                          ?.copyWith(color: LymDesignSystem.gray600),
                    ),
                    Text(
                      'Click "Add New" to log your workouts.',
                      style: LymDesignSystem.textTheme.bodySmall
                          ?.copyWith(color: LymDesignSystem.gray500),
                    ),
                  ],
                ),
              ),
            )
          else if (_sportActivities.isNotEmpty)
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _sportActivities.length,
              itemBuilder: (context, index) {
                final activity = _sportActivities[index];
                final intensityColor = _getIntensityColor(activity.intensity);
                return Card(
                  elevation: LymDesignSystem.elevationXs,
                  margin:
                      const EdgeInsets.only(bottom: LymDesignSystem.spacing8),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(LymDesignSystem.radiusMd),
                    side: const BorderSide(
                        color: LymDesignSystem.gray300,
                        width: LymDesignSystem.borderWidthThin),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: intensityColor
                          .withValues(alpha: 0.15), // Slightly more opaque
                      child: Icon(_getIntensityIcon(activity.intensity),
                          color: intensityColor, size: 22), // Adjusted size
                    ),
                    title: Text(
                      activity.name,
                      style: LymDesignSystem.textTheme.titleSmall?.copyWith(
                          color: LymDesignSystem.gray800,
                          fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      '${_getIntensityLabel(activity.intensity)} - ${activity.minutesPerSession} mins x ${activity.sessionsPerWeek} times/week',
                      style: LymDesignSystem.textTheme.bodySmall
                          ?.copyWith(color: LymDesignSystem.gray600),
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.delete_outline_rounded,
                          color: LymDesignSystem.error.withValues(alpha: 0.8),
                          size: 22), // Adjusted size and opacity
                      onPressed: () => _removeSportActivity(index),
                      tooltip: 'Remove Activity',
                      splashRadius:
                          20, // Added splash radius for better feedback
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: LymDesignSystem.spacing12,
                        horizontal:
                            LymDesignSystem.spacing12), // Adjusted padding
                  ),
                );
              },
            ),
          AnimatedSwitcher(
            duration: LymDesignSystem.durationMedium,
            child: _sportActivities.isEmpty && !_showAddActivityForm
                ? Container(
                    // Changed SizedBox to Container for more styling options
                    width: double
                        .infinity, // Ensure it takes full width for centering text
                    padding: const EdgeInsets.symmetric(
                        vertical: LymDesignSystem.spacing48,
                        horizontal:
                            LymDesignSystem.spacing16), // Increased padding
                    child: Center(
                      child: Column(
                        // Wrap in column for better layout of icon and text
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.directions_bike_rounded,
                              size: 56,
                              color: LymDesignSystem.gray400.withValues(alpha: 0.8)),
                          const SizedBox(height: LymDesignSystem.spacing16),
                          Text(
                            'No specific activities logged yet.',
                            style: LymDesignSystem.textTheme.bodyLarge
                                ?.copyWith(color: LymDesignSystem.gray600),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: LymDesignSystem.spacing4),
                          Text(
                            'Tap "Add New" to include your workouts and sports.',
                            style: LymDesignSystem.textTheme.bodyMedium
                                ?.copyWith(color: LymDesignSystem.gray500),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
