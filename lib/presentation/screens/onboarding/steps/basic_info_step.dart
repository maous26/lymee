// lib/presentation/screens/onboarding/steps/basic_info_step.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lym_nutrition/domain/entities/user_profile.dart';
import 'package:lym_nutrition/presentation/themes/premium_theme.dart';
import 'package:lym_nutrition/presentation/widgets/onboarding_step_container.dart';

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

  void _saveAndContinue() {
    if (_formKey.currentState!.validate()) {
      // Mettre à jour le profil utilisateur
      final updatedProfile = widget.userProfile.copyWith(
        name: _nameController.text.isEmpty ? null : _nameController.text,
        age: int.parse(_ageController.text),
        gender: _selectedGender,
        heightCm: double.parse(_heightController.text),
        weightKg: double.parse(_weightController.text),
      );

      widget.onUpdateProfile(updatedProfile);
      widget.onNext();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return OnboardingStepContainer(
      title: 'Vos informations personnelles',
      subtitle:
          'Ces informations nous aideront à calculer vos besoins nutritionnels',
      onNext: _saveAndContinue,
      content: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nom (optionnel)
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Prénom (optionnel)',
                hintText: 'Comment souhaitez-vous être appelé?',
                prefixIcon: Icon(Icons.person),
              ),
              textCapitalization: TextCapitalization.words,
            ),

            const SizedBox(height: 16),

            // Âge
            TextFormField(
              controller: _ageController,
              decoration: const InputDecoration(
                labelText: 'Âge',
                hintText: 'Votre âge',
                prefixIcon: Icon(Icons.cake),
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

            const SizedBox(height: 16),

            // Genre
            Text(
              'Genre',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
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
                      }
                    },
                    activeColor: PremiumTheme.primaryColor,
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
                      }
                    },
                    activeColor: PremiumTheme.primaryColor,
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
                }
              },
              activeColor: PremiumTheme.primaryColor,
              contentPadding: EdgeInsets.zero,
            ),

            const SizedBox(height: 16),

            // Taille et poids
            Row(
              children: [
                // Taille
                Expanded(
                  child: TextFormField(
                    controller: _heightController,
                    decoration: const InputDecoration(
                      labelText: 'Taille',
                      hintText: 'En cm',
                      prefixIcon: Icon(Icons.height),
                      suffixText: 'cm',
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
                    decoration: const InputDecoration(
                      labelText: 'Poids',
                      hintText: 'En kg',
                      prefixIcon: Icon(Icons.monitor_weight),
                      suffixText: 'kg',
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
      ),
    );
  }
}
