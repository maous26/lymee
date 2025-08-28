// lib/presentation/screens/onboarding/steps/basic_info_step.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lym_nutrition/domain/entities/user_profile.dart';
import 'package:lym_nutrition/presentation/themes/lym_design_system.dart';

class BasicInfoStep extends StatefulWidget {
  final UserProfile userProfile;
  final Function(UserProfile) onUpdateProfile;
  final VoidCallback
      onNextRequested; // This will be called to signal the parent to move next

  const BasicInfoStep({
    Key? key,
    required this.userProfile,
    required this.onUpdateProfile,
    required this.onNextRequested,
  }) : super(key: key);

  @override
  State<BasicInfoStep> createState() => BasicInfoStepState();
}

class BasicInfoStepState extends State<BasicInfoStep> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _ageController;
  late TextEditingController _heightController;
  late TextEditingController _weightController;
  Gender _selectedGender = Gender.male;

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.userProfile.name ?? '');
    _ageController = TextEditingController(
        text: widget.userProfile.age > 0
            ? widget.userProfile.age.toString()
            : '');
    _heightController = TextEditingController(
        text: widget.userProfile.heightCm > 0
            ? widget.userProfile.heightCm.toString()
            : '');
    _weightController = TextEditingController(
        text: widget.userProfile.weightKg > 0
            ? widget.userProfile.weightKg.toString()
            : '');
    _selectedGender = widget.userProfile.gender;

    // Add listener to onNextRequested if LymOnboardingContainer needs to trigger validation externally
    // For now, we assume a button within this step's UI or LymOnboardingContainer's own button will call _validateAndProceed.
    // If LymOnboardingContainer's "Next" button is meant to validate this form,
    // OnboardingScreen would pass _validateAndProceed to LymOnboardingContainer's onNext.
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  // This method will be called by LymOnboardingContainer's "Next" button.
  // The parent OnboardingScreen will pass this function to LymOnboardingContainer.
  void validateAndProceed() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final updatedProfile = widget.userProfile.copyWith(
        name: _nameController.text.isEmpty ? null : _nameController.text,
        age: int.tryParse(_ageController.text) ?? widget.userProfile.age,
        gender: _selectedGender,
        heightCm: double.tryParse(_heightController.text) ??
            widget.userProfile.heightCm,
        weightKg: double.tryParse(_weightController.text) ??
            widget.userProfile.weightKg,
      );
      widget.onUpdateProfile(updatedProfile);
      widget.onNextRequested(); // Signal parent that this step is done
    }
  }

  @override
  Widget build(BuildContext context) {
    // This widget now returns only its specific form content.
    // LymOnboardingContainer in onboarding_screen.dart will handle titles, progress, and navigation.

    return Padding(
      padding: const EdgeInsets.all(LymDesignSystem.spacing16),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Parlez-nous de vous',
                style: LymDesignSystem.textTheme.headlineSmall?.copyWith(
                    color: LymDesignSystem.gray800,
                    fontWeight: FontWeight.w600),
              ),
              const SizedBox(
                  height:
                      LymDesignSystem.spacing4), // Adjusted for tighter spacing
              Text(
                'Cela nous aide à personnaliser votre plan nutritionnel.',
                style: LymDesignSystem.textTheme.bodyMedium
                    ?.copyWith(color: LymDesignSystem.gray600),
              ),
              const SizedBox(height: LymDesignSystem.spacing24),

              // Name (optional)
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Prénom (Optionnel)',
                  hintText: 'Comment devons-nous vous appeler ?',
                  prefixIcon: const Icon(Icons.person_outline,
                      color: LymDesignSystem.mint),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                          LymDesignSystem.radiusMd)), // Changed to radiusMd
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                        LymDesignSystem.radiusMd), // Changed to radiusMd
                    borderSide: const BorderSide(
                        color: LymDesignSystem.mint,
                        width: LymDesignSystem
                            .borderWidthMedium), // Used LymDesignSystem const
                  ),
                ),
                style: LymDesignSystem.textTheme.bodyLarge
                    ?.copyWith(color: LymDesignSystem.gray800),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: LymDesignSystem.spacing16),

              // Age
              TextFormField(
                controller: _ageController,
                decoration: InputDecoration(
                  labelText: 'Âge',
                  hintText: 'Votre âge en années',
                  prefixIcon: const Icon(Icons.calendar_today_outlined,
                      color: LymDesignSystem.mint),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                          LymDesignSystem.radiusMd)), // Changed to radiusMd
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                        LymDesignSystem.radiusMd), // Changed to radiusMd
                    borderSide: const BorderSide(
                        color: LymDesignSystem.mint,
                        width: LymDesignSystem
                            .borderWidthMedium), // Used LymDesignSystem const
                  ),
                ),
                style: LymDesignSystem.textTheme.bodyLarge
                    ?.copyWith(color: LymDesignSystem.gray800),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre âge';
                  }
                  final age = int.tryParse(value);
                  if (age == null || age < 15 || age > 100) {
                    return 'L\'âge doit être entre 15 et 100';
                  }
                  return null;
                },
              ),
              const SizedBox(
                  height: LymDesignSystem
                      .spacing24), // Increased spacing before Gender

              // Gender
              Text(
                'Genre',
                style: LymDesignSystem.textTheme.titleMedium?.copyWith(
                    color: LymDesignSystem.gray800,
                    fontWeight: FontWeight.w600),
              ),
              const SizedBox(
                  height: LymDesignSystem.spacing12), // Adjusted spacing
              Row(
                children: Gender.values.map((gender) {
                  final isSelected = _selectedGender == gender;
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                          right: gender == Gender.values.last
                              ? 0
                              : LymDesignSystem
                                  .spacing8), // Add spacing between cards
                      child: Card(
                        elevation: isSelected
                            ? LymDesignSystem.elevationXs
                            : LymDesignSystem.elevationNone,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(LymDesignSystem.radiusMd),
                          side: BorderSide(
                            color: isSelected
                                ? LymDesignSystem.mint
                                : LymDesignSystem.gray300,
                            width: isSelected
                                ? LymDesignSystem.borderWidthMedium
                                : LymDesignSystem.borderWidthThin,
                          ),
                        ),
                        child: InkWell(
                          onTap: () {
                            // Removed check for Gender.unknown as it doesn't exist
                            setState(() => _selectedGender = gender);
                          },
                          borderRadius:
                              BorderRadius.circular(LymDesignSystem.radiusMd),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: LymDesignSystem.spacing12,
                                horizontal: LymDesignSystem.spacing8),
                            child: Column(
                              // Use Column for icon and text
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  gender == Gender.male
                                      ? Icons.male_rounded
                                      : gender == Gender.female
                                          ? Icons.female_rounded
                                          : Icons.question_mark_rounded,
                                  color: isSelected
                                      ? LymDesignSystem.mint
                                      : LymDesignSystem.gray500,
                                  size: 28,
                                ),
                                const SizedBox(
                                    height: LymDesignSystem.spacing4),
                                Text(
                                  gender == Gender.male
                                      ? 'Homme'
                                      : gender == Gender.female
                                          ? 'Femme'
                                          : 'Autre',
                                  style: LymDesignSystem.textTheme.bodyMedium
                                      ?.copyWith(
                                    color: isSelected
                                        ? LymDesignSystem.mint
                                        : LymDesignSystem.gray700,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                // Radio button is now more for visual indication, tap handled by InkWell
                                SizedBox(
                                  height: 24, // Minimal height for the radio
                                  child: Radio<Gender>(
                                    value: gender,
                                    groupValue: _selectedGender,
                                    onChanged: (Gender? value) {
                                      // Removed check for Gender.unknown as it doesn't exist
                                      if (value != null) {
                                        setState(() => _selectedGender = value);
                                      }
                                    },
                                    activeColor: LymDesignSystem.mint,
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(), // Remove the unnecessary filter that was causing the error
              ),
              const SizedBox(
                  height: LymDesignSystem.spacing24), // Increased spacing

              // Height and Weight
              Card(
                // Wrap Height and Weight in a Card
                elevation: LymDesignSystem.elevationXs,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(LymDesignSystem
                      .radiusLg), // Slightly larger radius for the card
                  side: const BorderSide(
                      color: LymDesignSystem.gray200,
                      width: LymDesignSystem.borderWidthThin),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(LymDesignSystem.spacing16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mesures Physiques',
                        style: LymDesignSystem.textTheme.titleMedium?.copyWith(
                            color: LymDesignSystem.gray800,
                            fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: LymDesignSystem.spacing12),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _heightController,
                              decoration: InputDecoration(
                                labelText: 'Taille',
                                hintText: 'ex: 175',
                                prefixIcon: const Icon(Icons.height_outlined,
                                    color: LymDesignSystem.mint),
                                suffixText: 'cm',
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                        LymDesignSystem
                                            .radiusMd)), // Changed to radiusMd
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                      LymDesignSystem
                                          .radiusMd), // Changed to radiusMd
                                  borderSide: const BorderSide(
                                      color: LymDesignSystem.mint,
                                      width: LymDesignSystem
                                          .borderWidthMedium), // Used LymDesignSystem const
                                ),
                              ),
                              style: LymDesignSystem.textTheme.bodyLarge
                                  ?.copyWith(color: LymDesignSystem.gray800),
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'^\d+\.?\d{0,1}'))
                              ],
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Requis';
                                }
                                final height = double.tryParse(value);
                                if (height == null ||
                                    height < 100 ||
                                    height > 250) {
                                  return '100-250 cm';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: LymDesignSystem.spacing16),
                          Expanded(
                            child: TextFormField(
                              controller: _weightController,
                              decoration: InputDecoration(
                                labelText: 'Poids',
                                hintText: 'ex: 70.5',
                                prefixIcon: const Icon(
                                    Icons.monitor_weight_outlined,
                                    color: LymDesignSystem.mint),
                                suffixText: 'kg',
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                        LymDesignSystem
                                            .radiusMd)), // Changed to radiusMd
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                      LymDesignSystem
                                          .radiusMd), // Changed to radiusMd
                                  borderSide: const BorderSide(
                                      color: LymDesignSystem.mint,
                                      width: LymDesignSystem
                                          .borderWidthMedium), // Used LymDesignSystem const
                                ),
                              ),
                              style: LymDesignSystem.textTheme.bodyLarge
                                  ?.copyWith(color: LymDesignSystem.gray800),
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'^\d+\.?\d{0,1}'))
                              ],
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Required';
                                }
                                final weight = double.tryParse(value);
                                if (weight == null ||
                                    weight < 30 ||
                                    weight > 250) {
                                  return '30-250 kg';
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
              ),
              // The "Next" button is now part of LymOnboardingContainer.
              // LymOnboardingContainer will call validateAndProceed.
            ],
          ),
        ),
      ),
    );
  }
}
