// lib/presentation/screens/onboarding/steps/basic_info_step.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lym_nutrition/domain/entities/user_profile.dart';
import 'package:lym_nutrition/presentation/themes/wellness_colors.dart';

class BasicInfoStep extends StatefulWidget {
  final UserProfile userProfile;
  final Function(UserProfile) onUpdateProfile;
  final VoidCallback onNext;

  const BasicInfoStep({
    Key? key,
    required this.userProfile,
    required this.onUpdateProfile,
    required this.onNext,
  }) : super(key: key);

  @override
  State<BasicInfoStep> createState() => _BasicInfoStepState();
}

class _BasicInfoStepState extends State<BasicInfoStep> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  Gender _selectedGender = Gender.male;

  @override
  void initState() {
    super.initState();

    // Initialiser les contrôleurs avec les valeurs existantes
    _nameController.text = widget.userProfile.name ?? '';
    _ageController.text = widget.userProfile.age.toString();
    _heightController.text = widget.userProfile.heightCm.toString();
    _weightController.text = widget.userProfile.weightKg.toString();
    _selectedGender = widget.userProfile.gender;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  bool get isValid => _formKey.currentState?.validate() ?? false;

  void _updateProfileFromForm() {
    if (_formKey.currentState?.validate() ?? false) {
      final updatedProfile = widget.userProfile.copyWith(
        name: _nameController.text.isEmpty ? null : _nameController.text,
        age: _ageController.text.isNotEmpty ? int.tryParse(_ageController.text) : widget.userProfile.age,
        gender: _selectedGender,
        heightCm: _heightController.text.isNotEmpty ? double.tryParse(_heightController.text) : widget.userProfile.heightCm,
        weightKg: _weightController.text.isNotEmpty ? double.tryParse(_weightController.text) : widget.userProfile.weightKg,
      );
      widget.onUpdateProfile(updatedProfile);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nom (optionnel)
          TextFormField(
            controller: _nameController,
            onChanged: (value) => _updateProfileFromForm(),
            decoration: InputDecoration(
              labelText: 'Prénom (optionnel)',
              hintText: 'Comment souhaitez-vous être appelé?',
              prefixIcon: Icon(Icons.person, color: WellnessColors.primaryGreen),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: WellnessColors.textTertiary),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: WellnessColors.primaryGreen, width: 2),
              ),
            ),
            textCapitalization: TextCapitalization.words,
          ),

          const SizedBox(height: 20),

          // Âge
          TextFormField(
            controller: _ageController,
            onChanged: (value) => _updateProfileFromForm(),
            decoration: InputDecoration(
              labelText: 'Âge',
              hintText: 'Votre âge',
              prefixIcon: Icon(Icons.cake, color: WellnessColors.primaryGreen),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: WellnessColors.textTertiary),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: WellnessColors.primaryGreen, width: 2),
              ),
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez entrer votre âge';
              }
              final age = int.tryParse(value);
              if (age == null || age < 15 || age > 100) {
                return 'Veuillez entrer un âge entre 15 et 100 ans';
              }
              return null;
            },
          ),

          const SizedBox(height: 20),

          // Genre
          Text(
            'Genre',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: WellnessColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: RadioListTile<Gender>(
                  title: const Text('Homme'),
                  value: Gender.male,
                  groupValue: _selectedGender,
                  onChanged: (Gender? value) {
                    if (value != null) {
                      setState(() {
                        _selectedGender = value;
                      });
                      _updateProfileFromForm();
                    }
                  },
                  activeColor: WellnessColors.primaryGreen,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              Expanded(
                child: RadioListTile<Gender>(
                  title: const Text('Femme'),
                  value: Gender.female,
                  groupValue: _selectedGender,
                  onChanged: (Gender? value) {
                    if (value != null) {
                      setState(() {
                        _selectedGender = value;
                      });
                      _updateProfileFromForm();
                    }
                  },
                  activeColor: WellnessColors.primaryGreen,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
          RadioListTile<Gender>(
            title: const Text('Autre'),
            value: Gender.other,
            groupValue: _selectedGender,
            onChanged: (Gender? value) {
              if (value != null) {
                setState(() {
                  _selectedGender = value;
                });
                _updateProfileFromForm();
              }
            },
            activeColor: WellnessColors.primaryGreen,
            contentPadding: EdgeInsets.zero,
          ),

          const SizedBox(height: 20),

          // Taille et poids
          Row(
            children: [
              // Taille
              Expanded(
                child: TextFormField(
                  controller: _heightController,
                  onChanged: (value) => _updateProfileFromForm(),
                  decoration: InputDecoration(
                    labelText: 'Taille',
                    hintText: 'En cm',
                    prefixIcon: Icon(Icons.height, color: WellnessColors.primaryGreen),
                    suffixText: 'cm',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: WellnessColors.textTertiary),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: WellnessColors.primaryGreen, width: 2),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                        RegExp(r'^\d+\.?\d{0,1}')),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Obligatoire';
                    }
                    final height = double.tryParse(value);
                    if (height == null || height < 100 || height > 250) {
                      return 'Entre 100-250 cm';
                    }
                    return null;
                  },
                ),
              ),

              const SizedBox(width: 16),

              // Poids
              Expanded(
                child: TextFormField(
                  controller: _weightController,
                  onChanged: (value) => _updateProfileFromForm(),
                  decoration: InputDecoration(
                    labelText: 'Poids',
                    hintText: 'En kg',
                    prefixIcon: Icon(Icons.monitor_weight, color: WellnessColors.primaryGreen),
                    suffixText: 'kg',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: WellnessColors.textTertiary),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: WellnessColors.primaryGreen, width: 2),
                    ),                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                        RegExp(r'^\d+\.?\d{0,1}')),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Obligatoire';
                    }
                    final weight = double.tryParse(value);
                    if (weight == null || weight < 30 || weight > 250) {
                      return 'Entre 30-250 kg';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
