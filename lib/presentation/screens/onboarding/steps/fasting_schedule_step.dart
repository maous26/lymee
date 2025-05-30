// lib/presentation/screens/onboarding/steps/fasting_schedule_step.dart
import 'package:flutter/material.dart';
import 'package:lym_nutrition/domain/entities/user_profile.dart';
import 'package:lym_nutrition/presentation/themes/premium_theme.dart';
import 'package:lym_nutrition/presentation/widgets/onboarding_step_container.dart';

class FastingScheduleStep extends StatefulWidget {
  final UserProfile userProfile;
  final Function(UserProfile) onUpdateProfile;
  final VoidCallback onNext;

  const FastingScheduleStep({
    Key? key,
    required this.userProfile,
    required this.onUpdateProfile,
    required this.onNext,
  }) : super(key: key);

  @override
  State<FastingScheduleStep> createState() => _FastingScheduleStepState();
}

class _FastingScheduleStepState extends State<FastingScheduleStep> {
  late IntermittentFastingSchedule _fastingSchedule;
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();

  // Jours de la semaine pour l'interface
  final List<String> _weekdays = [
    'Lundi',
    'Mardi',
    'Mercredi',
    'Jeudi',
    'Vendredi',
    'Samedi',
    'Dimanche',
  ];

  @override
  void initState() {
    super.initState();
    _fastingSchedule = widget.userProfile.fastingSchedule;
    _startTimeController.text = _fastingSchedule.fastingStartTime;
    _endTimeController.text = _fastingSchedule.fastingEndTime;
  }

  @override
  void dispose() {
    _startTimeController.dispose();
    _endTimeController.dispose();
    super.dispose();
  }

  void _updateFastingType(IntermittentFastingType? type) {
    if (type != null) {
      setState(() {
        if (type == IntermittentFastingType.none) {
          _fastingSchedule = IntermittentFastingSchedule(type: type);
        } else {
          _fastingSchedule = IntermittentFastingSchedule.fromType(type);
          _startTimeController.text = _fastingSchedule.fastingStartTime;
          _endTimeController.text = _fastingSchedule.fastingEndTime;
        }
      });
    }
  }

  void _selectStartTime() async {
    final TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: _parseTimeOfDay(_fastingSchedule.fastingStartTime),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: PremiumTheme.primaryColor,
              onPrimary: Colors.white,
              onSurface: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          child: child!,
        );
      },
    );

    if (selectedTime != null) {
      setState(() {
        final newStartTime =
            '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}';
        _startTimeController.text = newStartTime;
        _fastingSchedule = _fastingSchedule.copyWith(
          fastingStartTime: newStartTime,
        );
      });
    }
  }

  void _selectEndTime() async {
    final TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: _parseTimeOfDay(_fastingSchedule.fastingEndTime),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: PremiumTheme.primaryColor,
              onPrimary: Colors.white,
              onSurface: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          child: child!,
        );
      },
    );

    if (selectedTime != null) {
      setState(() {
        final newEndTime =
            '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}';
        _endTimeController.text = newEndTime;
        _fastingSchedule = _fastingSchedule.copyWith(
          fastingEndTime: newEndTime,
        );
      });
    }
  }

  TimeOfDay _parseTimeOfDay(String timeString) {
    final parts = timeString.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }

  void _toggleFastingDay(int dayIndex) {
    if (_fastingSchedule.type == IntermittentFastingType.fasting5_2 ||
        _fastingSchedule.type == IntermittentFastingType.alternateDay ||
        _fastingSchedule.type == IntermittentFastingType.custom) {
      setState(() {
        final dayNumber = dayIndex + 1; // Indexé à partir de 1 (lundi = 1)
        final updatedDays = List<int>.from(_fastingSchedule.fastingDays);

        if (updatedDays.contains(dayNumber)) {
          updatedDays.remove(dayNumber);
        } else {
          updatedDays.add(dayNumber);
        }

        _fastingSchedule = _fastingSchedule.copyWith(
          fastingDays: updatedDays,
        );
      });
    }
  }

  void _saveAndContinue() {
    // Mettre à jour le profil utilisateur
    final updatedProfile = widget.userProfile.copyWith(
      fastingSchedule: _fastingSchedule,
    );

    widget.onUpdateProfile(updatedProfile);
    widget.onNext();
  }

  String _getFastingTypeLabel(IntermittentFastingType type) {
    switch (type) {
      case IntermittentFastingType.none:
        return 'Aucun jeûne';
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

  String _getFastingTypeDescription(IntermittentFastingType type) {
    switch (type) {
      case IntermittentFastingType.none:
        return 'Pas de jeûne intermittent';
      case IntermittentFastingType.fasting16_8:
        return 'Jeûne 16/8 (16h de jeûne, 8h d\'alimentation)';
      case IntermittentFastingType.fasting18_6:
        return 'Jeûne 18/6 (18h de jeûne, 6h d\'alimentation)';
      case IntermittentFastingType.fasting20_4:
        return 'Jeûne 20/4 (20h de jeûne, 4h d\'alimentation)';
      case IntermittentFastingType.fasting5_2:
        return 'Jeûne 5:2 (5 jours normaux, 2 jours à calories réduites)';
      case IntermittentFastingType.alternateDay:
        return 'Jeûne alterné (un jour sur deux)';
      case IntermittentFastingType.custom:
        return 'Personnalisé';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return OnboardingStepContainer(
      title: 'Jeûne intermittent',
      subtitle:
          'Définissez votre planning de jeûne si vous pratiquez cette approche',
      onNext: _saveAndContinue,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sélection du type de jeûne
          Text(
            'Pratiquez-vous le jeûne intermittent?',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Liste des types de jeûne
          Card(
            elevation: 2,
            child: Column(
              children: IntermittentFastingType.values.map((type) {
                return RadioListTile<IntermittentFastingType>(
                  title: Text(
                    _getFastingTypeLabel(type),
                    style: TextStyle(
                      fontWeight: _fastingSchedule.type == type
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                  subtitle: Text(_getFastingTypeDescription(type)),
                  value: type,
                  groupValue: _fastingSchedule.type,
                  onChanged: _updateFastingType,
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

          // Configuration spécifique selon le type de jeûne
          if (_fastingSchedule.type != IntermittentFastingType.none)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Configuration',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Pour les types basés sur des heures
                if (_fastingSchedule.type ==
                        IntermittentFastingType.fasting16_8 ||
                    _fastingSchedule.type ==
                        IntermittentFastingType.fasting18_6 ||
                    _fastingSchedule.type ==
                        IntermittentFastingType.fasting20_4 ||
                    _fastingSchedule.type == IntermittentFastingType.custom)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Horaires de jeûne',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),

                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _startTimeController,
                                  readOnly: true,
                                  onTap: _selectStartTime,
                                  decoration: const InputDecoration(
                                    labelText: 'Début du jeûne',
                                    hintText: 'Ex: 20:00',
                                    prefixIcon: Icon(Icons.access_time),
                                    helperText: 'Fin des repas',
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: TextField(
                                  controller: _endTimeController,
                                  readOnly: true,
                                  onTap: _selectEndTime,
                                  decoration: const InputDecoration(
                                    labelText: 'Fin du jeûne',
                                    hintText: 'Ex: 12:00',
                                    prefixIcon: Icon(Icons.access_time),
                                    helperText: 'Premier repas',
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // Informations sur le jeûne
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: PremiumTheme.info.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(
                                  PremiumTheme.borderRadiusSmall),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.info_outline,
                                      color: PremiumTheme.info,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Récapitulatif',
                                      style:
                                          theme.textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: PremiumTheme.info,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                RichText(
                                  text: TextSpan(
                                    style: theme.textTheme.bodyMedium,
                                    children: [
                                      const TextSpan(
                                        text: 'Vous jeûnerez de ',
                                      ),
                                      TextSpan(
                                        text: _fastingSchedule.fastingStartTime,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const TextSpan(
                                        text: ' à ',
                                      ),
                                      TextSpan(
                                        text: _fastingSchedule.fastingEndTime,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const TextSpan(
                                        text: ' chaque jour.',
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Pour les types basés sur des jours (5:2, alterné)
                if (_fastingSchedule.type ==
                        IntermittentFastingType.fasting5_2 ||
                    _fastingSchedule.type ==
                        IntermittentFastingType.alternateDay)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Jours de jeûne',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),

                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: List.generate(_weekdays.length, (index) {
                              final isSelected = _fastingSchedule.fastingDays
                                  .contains(index + 1);
                              return FilterChip(
                                label: Text(_weekdays[index]),
                                selected: isSelected,
                                onSelected: (_) => _toggleFastingDay(index),
                                backgroundColor:
                                    PremiumTheme.primaryColor.withOpacity(0.1),
                                selectedColor:
                                    PremiumTheme.primaryColor.withOpacity(0.3),
                                checkmarkColor: PremiumTheme.primaryColor,
                                labelStyle: TextStyle(
                                  color: isSelected
                                      ? PremiumTheme.primaryColor
                                      : theme.textTheme.bodyMedium?.color,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              );
                            }),
                          ),

                          const SizedBox(height: 16),

                          // Vérification du nombre de jours pour 5:2
                          if (_fastingSchedule.type ==
                                  IntermittentFastingType.fasting5_2 &&
                              _fastingSchedule.fastingDays.length != 2)
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: PremiumTheme.warning.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(
                                    PremiumTheme.borderRadiusSmall),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.warning_amber,
                                    color: PremiumTheme.warning,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Pour le jeûne 5:2, veuillez sélectionner exactement 2 jours de jeûne.',
                                      style:
                                          theme.textTheme.bodySmall?.copyWith(
                                        color: PremiumTheme.warning,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          // Informations sur le jeûne
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: PremiumTheme.info.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(
                                  PremiumTheme.borderRadiusSmall),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.info_outline,
                                      color: PremiumTheme.info,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Récapitulatif',
                                      style:
                                          theme.textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: PremiumTheme.info,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                if (_fastingSchedule.fastingDays.isEmpty)
                                  const Text(
                                    'Veuillez sélectionner au moins un jour de jeûne.',
                                    style:
                                        TextStyle(fontStyle: FontStyle.italic),
                                  )
                                else
                                  RichText(
                                    text: TextSpan(
                                      style: theme.textTheme.bodyMedium,
                                      children: [
                                        const TextSpan(
                                          text:
                                              'Vous jeûnerez les jours suivants : ',
                                        ),
                                        TextSpan(
                                          text: _fastingSchedule.fastingDays
                                              .map((day) => _weekdays[day - 1])
                                              .join(', '),
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                const SizedBox(height: 16),

                // Informations générales sur le jeûne
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
                              'Jeûne intermittent',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: PremiumTheme.primaryColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Pendant les périodes de jeûne, l\'application vous proposera des rappels et adaptera vos recommandations caloriques. Vous pourrez modifier ces paramètres à tout moment.',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

extension IntermittentFastingScheduleExtension on IntermittentFastingSchedule {
  IntermittentFastingSchedule copyWith({
    IntermittentFastingType? type,
    int? fastingHours,
    int? eatingHours,
    List<int>? fastingDays,
    String? fastingStartTime,
    String? fastingEndTime,
  }) {
    return IntermittentFastingSchedule(
      type: type ?? this.type,
      fastingHours: fastingHours ?? this.fastingHours,
      eatingHours: eatingHours ?? this.eatingHours,
      fastingDays: fastingDays ?? this.fastingDays,
      fastingStartTime: fastingStartTime ?? this.fastingStartTime,
      fastingEndTime: fastingEndTime ?? this.fastingEndTime,
    );
  }
}
