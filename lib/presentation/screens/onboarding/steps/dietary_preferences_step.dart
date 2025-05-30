// lib/presentation/screens/onboarding/steps/dietary_preferences_step.dart
import 'package:flutter/material.dart';
import 'package:lym_nutrition/domain/entities/user_dietary_preferences.dart';
import 'package:lym_nutrition/domain/entities/user_profile.dart';
import 'package:lym_nutrition/presentation/themes/premium_theme.dart';
import 'package:lym_nutrition/presentation/widgets/onboarding_step_container.dart';

class DietaryPreferencesStep extends StatefulWidget {
  final UserProfile userProfile;
  final Function(UserProfile) onUpdateProfile;
  final VoidCallback onNext;

  const DietaryPreferencesStep({
    Key? key,
    required this.userProfile,
    required this.onUpdateProfile,
    required this.onNext,
  }) : super(key: key);

  @override
  State<DietaryPreferencesStep> createState() => _DietaryPreferencesStepState();
}

class _DietaryPreferencesStepState extends State<DietaryPreferencesStep> {
  late UserDietaryPreferences _preferences;
  final TextEditingController _allergyController = TextEditingController();
  final FocusNode _allergyFocusNode = FocusNode();

  // Liste des allergènes courants pour les suggestions
  final List<String> _commonAllergens = [
    'Arachides',
    'Fruits à coque',
    'Lait',
    'Œufs',
    'Poisson',
    'Crustacés',
    'Mollusques',
    'Gluten',
    'Soja',
    'Sésame',
    'Moutarde',
    'Céleri',
    'Lupin',
    'Sulfites',
  ];

  @override
  void initState() {
    super.initState();
    _preferences = widget.userProfile.dietaryPreferences;
  }

  @override
  void dispose() {
    _allergyController.dispose();
    _allergyFocusNode.dispose();
    super.dispose();
  }

  void _saveAndContinue() {
    // Mettre à jour le profil utilisateur
    final updatedProfile = widget.userProfile.copyWith(
      dietaryPreferences: _preferences,
    );

    widget.onUpdateProfile(updatedProfile);
    widget.onNext();
  }

  void _addAllergy() {
    if (_allergyController.text.isNotEmpty) {
      final allergy = _allergyController.text.trim();
      setState(() {
        if (!_preferences.allergies.contains(allergy)) {
          final updatedAllergies = List<String>.from(_preferences.allergies)
            ..add(allergy);
          _preferences = _preferences.copyWith(allergies: updatedAllergies);
        }
        _allergyController.clear();
      });
    }
  }

  void _removeAllergy(String allergy) {
    setState(() {
      final updatedAllergies = List<String>.from(_preferences.allergies)
        ..remove(allergy);
      _preferences = _preferences.copyWith(allergies: updatedAllergies);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return OnboardingStepContainer(
      title: 'Vos préférences alimentaires',
      subtitle:
          'Indiquez vos régimes et allergies pour personnaliser vos recommandations',
      onNext: _saveAndContinue,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Régimes alimentaires
          Text(
            'Régimes alimentaires',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          Card(
            child: Column(
              children: [
                // Végétarien
                SwitchListTile(
                  title: const Text('Végétarien'),
                  subtitle: const Text('Pas de viande ni poisson'),
                  value: _preferences.isVegetarian,
                  onChanged: (value) {
                    setState(() {
                      _preferences = _preferences.copyWith(isVegetarian: value);
                      // Si végétarien est désactivé, désactiver aussi végétalien
                      if (!value && _preferences.isVegan) {
                        _preferences = _preferences.copyWith(isVegan: false);
                      }
                    });
                  },
                  activeColor: PremiumTheme.primaryColor,
                ),

                // Végétalien
                SwitchListTile(
                  title: const Text('Végétalien'),
                  subtitle: const Text('Aucun produit d\'origine animale'),
                  value: _preferences.isVegan,
                  onChanged: _preferences.isVegetarian
                      ? (value) {
                          setState(() {
                            _preferences =
                                _preferences.copyWith(isVegan: value);
                          });
                        }
                      : null,
                  activeColor: PremiumTheme.primaryColor,
                ),

                // Halal
                SwitchListTile(
                  title: const Text('Halal'),
                  subtitle: const Text('Conforme aux préceptes islamiques'),
                  value: _preferences.isHalal,
                  onChanged: (value) {
                    setState(() {
                      _preferences = _preferences.copyWith(isHalal: value);
                    });
                  },
                  activeColor: PremiumTheme.primaryColor,
                ),

                // Casher
                SwitchListTile(
                  title: const Text('Casher'),
                  subtitle: const Text('Conforme aux lois alimentaires juives'),
                  value: _preferences.isKosher,
                  onChanged: (value) {
                    setState(() {
                      _preferences = _preferences.copyWith(isKosher: value);
                    });
                  },
                  activeColor: PremiumTheme.primaryColor,
                ),

                // Sans gluten
                SwitchListTile(
                  title: const Text('Sans gluten'),
                  subtitle: const Text('Exclut le blé, l\'orge, le seigle...'),
                  value: _preferences.isGlutenFree,
                  onChanged: (value) {
                    setState(() {
                      _preferences = _preferences.copyWith(isGlutenFree: value);
                    });
                  },
                  activeColor: PremiumTheme.primaryColor,
                ),

                // Sans lactose
                SwitchListTile(
                  title: const Text('Sans lactose'),
                  subtitle: const Text('Exclut les produits laitiers'),
                  value: _preferences.isLactoseFree,
                  onChanged: (value) {
                    setState(() {
                      _preferences =
                          _preferences.copyWith(isLactoseFree: value);
                    });
                  },
                  activeColor: PremiumTheme.primaryColor,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Allergies
          Text(
            'Allergies et intolérances',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          // Champ pour ajouter une allergie
          Row(
            children: [
              Expanded(
                child: Autocomplete<String>(
                  optionsBuilder: (TextEditingValue textEditingValue) {
                    if (textEditingValue.text.isEmpty) {
                      return const Iterable<String>.empty();
                    }
                    return _commonAllergens.where((String option) {
                      return option.toLowerCase().contains(
                            textEditingValue.text.toLowerCase(),
                          );
                    });
                  },
                  onSelected: (String selection) {
                    _allergyController.text = selection;
                    _addAllergy();
                  },
                  fieldViewBuilder: (context, textEditingController, focusNode,
                      onFieldSubmitted) {
                    // Stocker les contrôleurs pour utilisation ultérieure
                    _allergyController.text = textEditingController.text;

                    return TextField(
                      controller: textEditingController,
                      focusNode: focusNode,
                      decoration: InputDecoration(
                        labelText: 'Ajouter une allergie',
                        hintText: 'Ex: Arachides, Lait, Œufs...',
                        prefixIcon: const Icon(Icons.warning_amber),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () {
                            _allergyController.text =
                                textEditingController.text;
                            _addAllergy();
                          },
                        ),
                      ),
                      onSubmitted: (String value) {
                        _allergyController.text = value;
                        _addAllergy();
                      },
                    );
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Liste des allergies ajoutées
          if (_preferences.allergies.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Text(
                  'Aucune allergie ajoutée',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _preferences.allergies.map((allergy) {
                return Chip(
                  label: Text(allergy),
                  deleteIcon: const Icon(Icons.close, size: 18),
                  onDeleted: () => _removeAllergy(allergy),
                  backgroundColor: PremiumTheme.error.withOpacity(0.1),
                  deleteIconColor: PremiumTheme.error,
                  labelStyle: TextStyle(color: PremiumTheme.error),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(PremiumTheme.borderRadiusSmall),
                    side: BorderSide(color: PremiumTheme.error.withOpacity(0.3)),
                  ),
                );
              }).toList(),
            ),

          const SizedBox(height: 16),

          // Information sur les allergies
          if (_preferences.allergies.isNotEmpty)
            Card(
              color: PremiumTheme.info.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: PremiumTheme.info,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Information',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: PremiumTheme.info,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Les aliments contenant ces allergènes seront filtrés dans vos résultats de recherche. Vous pourrez modifier ces préférences ultérieurement.',
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
