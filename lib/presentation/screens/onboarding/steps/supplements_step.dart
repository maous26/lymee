// lib/presentation/screens/onboarding/steps/supplements_step.dart
import 'package:flutter/material.dart';
import 'package:lym_nutrition/domain/entities/user_profile.dart';
import 'package:lym_nutrition/presentation/themes/premium_theme.dart';
import 'package:lym_nutrition/presentation/widgets/onboarding_step_container.dart';

class SupplementsStep extends StatefulWidget {
  final UserProfile userProfile;
  final Function(UserProfile) onUpdateProfile;
  final VoidCallback onNext;

  const SupplementsStep({
    Key? key,
    required this.userProfile,
    required this.onUpdateProfile,
    required this.onNext,
  }) : super(key: key);

  @override
  State<SupplementsStep> createState() => _SupplementsStepState();
}

class _SupplementsStepState extends State<SupplementsStep> {
  List<Supplement> _supplements = [];
  bool _showAddSupplementForm = false;
  final _supplementNameController = TextEditingController();
  final _supplementDosageController = TextEditingController();
  final _supplementUnitController = TextEditingController();
  final _supplementTimingController = TextEditingController();
  final _supplementNotesController = TextEditingController();

  // Listes prédéfinies pour les auto-complétion
  final List<String> _commonSupplements = [
    'Vitamine D',
    'Vitamine C',
    'Magnésium',
    'Zinc',
    'Fer',
    'Calcium',
    'Oméga 3',
    'Vitamine B12',
    'Probiotiques',
    'Protéines en poudre',
    'Créatine',
    'BCAA',
    'Multivitamines',
  ];

  final List<String> _commonUnits = [
    'mg',
    'g',
    'μg',
    'mcg',
    'UI',
    'ml',
    'gouttes',
    'gélule(s)',
    'comprimé(s)',
    'cuillère(s) à café',
    'cuillère(s) à soupe',
    'sachet(s)',
  ];

  final List<String> _commonTimings = [
    'Matin',
    'Midi',
    'Soir',
    'Avant repas',
    'Pendant repas',
    'Après repas',
    'Avant entraînement',
    'Après entraînement',
    'Au coucher',
  ];

  @override
  void initState() {
    super.initState();
    _supplements = List.from(widget.userProfile.supplements);
  }

  @override
  void dispose() {
    _supplementNameController.dispose();
    _supplementDosageController.dispose();
    _supplementUnitController.dispose();
    _supplementTimingController.dispose();
    _supplementNotesController.dispose();
    super.dispose();
  }

  void _toggleAddSupplementForm() {
    setState(() {
      _showAddSupplementForm = !_showAddSupplementForm;
      if (_showAddSupplementForm) {
        // Réinitialiser le formulaire
        _supplementNameController.clear();
        _supplementDosageController.clear();
        _supplementUnitController.clear();
        _supplementTimingController.clear();
        _supplementNotesController.clear();
      }
    });
  }

  void _addSupplement() {
    if (_supplementNameController.text.isEmpty ||
        _supplementDosageController.text.isEmpty ||
        _supplementUnitController.text.isEmpty ||
        _supplementTimingController.text.isEmpty) {
      // Afficher un message d'erreur
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez remplir tous les champs obligatoires'),
          backgroundColor: PremiumTheme.error,
        ),
      );
      return;
    }

    final newSupplement = Supplement(
      name: _supplementNameController.text.trim(),
      dosage: _supplementDosageController.text.trim(),
      unit: _supplementUnitController.text.trim(),
      timing: _supplementTimingController.text.trim(),
      notes: _supplementNotesController.text.isEmpty
          ? null
          : _supplementNotesController.text.trim(),
    );

    setState(() {
      _supplements.add(newSupplement);
      _showAddSupplementForm = false;
    });
  }

  void _removeSupplement(int index) {
    setState(() {
      _supplements.removeAt(index);
    });
  }

  void _saveAndContinue() {
    // Mettre à jour le profil utilisateur
    final updatedProfile = widget.userProfile.copyWith(
      supplements: _supplements,
    );

    widget.onUpdateProfile(updatedProfile);
    widget.onNext();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return OnboardingStepContainer(
      title: 'Compléments alimentaires',
      subtitle:
          'Ajoutez vos compléments pour un suivi complet de votre nutrition',
      onNext: _saveAndContinue,
      nextButtonText: 'Continuer',
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Intro sur les compléments
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
                        'Compléments alimentaires',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: PremiumTheme.info,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Les compléments alimentaires sont des concentrés de nutriments destinés à compléter un régime alimentaire normal. Ajoutez ici ceux que vous prenez régulièrement.',
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Cette étape est optionnelle, vous pourrez toujours ajouter des compléments plus tard.',
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Compléments alimentaires
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Vos compléments',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton.icon(
                onPressed: _toggleAddSupplementForm,
                icon: Icon(_showAddSupplementForm ? Icons.close : Icons.add),
                label: Text(_showAddSupplementForm ? 'Annuler' : 'Ajouter'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _showAddSupplementForm
                      ? Colors.grey
                      : PremiumTheme.primaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Formulaire d'ajout de complément
          if (_showAddSupplementForm)
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nom du complément
                    Autocomplete<String>(
                      optionsBuilder: (TextEditingValue textEditingValue) {
                        if (textEditingValue.text.isEmpty) {
                          return const Iterable<String>.empty();
                        }
                        return _commonSupplements.where((String option) {
                          return option.toLowerCase().contains(
                                textEditingValue.text.toLowerCase(),
                              );
                        });
                      },
                      onSelected: (String selection) {
                        _supplementNameController.text = selection;
                      },
                      fieldViewBuilder: (context, textEditingController,
                          focusNode, onFieldSubmitted) {
                        _supplementNameController.text =
                            textEditingController.text;

                        return TextField(
                          controller: textEditingController,
                          focusNode: focusNode,
                          decoration: const InputDecoration(
                            labelText: 'Nom du complément *',
                            hintText: 'Ex: Vitamine D, Magnésium...',
                            prefixIcon: Icon(Icons.medical_services),
                          ),
                          textCapitalization: TextCapitalization.sentences,
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    // Dosage et unité
                    Row(
                      children: [
                        // Dosage
                        Expanded(
                          flex: 3,
                          child: TextField(
                            controller: _supplementDosageController,
                            decoration: const InputDecoration(
                              labelText: 'Dosage *',
                              hintText: 'Ex: 1000',
                              prefixIcon: Icon(Icons.scale),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),

                        const SizedBox(width: 16),

                        // Unité
                        Expanded(
                          flex: 2,
                          child: Autocomplete<String>(
                            optionsBuilder:
                                (TextEditingValue textEditingValue) {
                              if (textEditingValue.text.isEmpty) {
                                return const Iterable<String>.empty();
                              }
                              return _commonUnits.where((String option) {
                                return option.toLowerCase().contains(
                                      textEditingValue.text.toLowerCase(),
                                    );
                              });
                            },
                            onSelected: (String selection) {
                              _supplementUnitController.text = selection;
                            },
                            fieldViewBuilder: (context, textEditingController,
                                focusNode, onFieldSubmitted) {
                              _supplementUnitController.text =
                                  textEditingController.text;

                              return TextField(
                                controller: textEditingController,
                                focusNode: focusNode,
                                decoration: const InputDecoration(
                                  labelText: 'Unité *',
                                  hintText: 'Ex: mg, UI...',
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Moment de prise
                    Autocomplete<String>(
                      optionsBuilder: (TextEditingValue textEditingValue) {
                        if (textEditingValue.text.isEmpty) {
                          return const Iterable<String>.empty();
                        }
                        return _commonTimings.where((String option) {
                          return option.toLowerCase().contains(
                                textEditingValue.text.toLowerCase(),
                              );
                        });
                      },
                      onSelected: (String selection) {
                        _supplementTimingController.text = selection;
                      },
                      fieldViewBuilder: (context, textEditingController,
                          focusNode, onFieldSubmitted) {
                        _supplementTimingController.text =
                            textEditingController.text;

                        return TextField(
                          controller: textEditingController,
                          focusNode: focusNode,
                          decoration: const InputDecoration(
                            labelText: 'Moment de prise *',
                            hintText: 'Ex: Matin, Avant repas...',
                            prefixIcon: Icon(Icons.access_time),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 16),

                    // Notes (optionnel)
                    TextField(
                      controller: _supplementNotesController,
                      decoration: const InputDecoration(
                        labelText: 'Notes (optionnel)',
                        hintText: 'Ex: Marque, effets attendus...',
                        prefixIcon: Icon(Icons.note),
                      ),
                      minLines: 1,
                      maxLines: 3,
                    ),

                    const SizedBox(height: 16),

                    Center(
                      child: ElevatedButton.icon(
                        onPressed: _addSupplement,
                        icon: const Icon(Icons.check),
                        label: const Text('Ajouter ce complément'),
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

          // Liste des compléments
          if (_supplements.isEmpty && !_showAddSupplementForm)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(
                child: Text(
                  'Aucun complément alimentaire ajouté',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _supplements.length,
              itemBuilder: (context, index) {
                final supplement = _supplements[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8, top: 8),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: PremiumTheme.primaryColor,
                      child: Icon(
                        Icons.medical_services,
                        color: Colors.white,
                      ),
                    ),
                    title: Text(
                      supplement.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${supplement.dosage} ${supplement.unit}'),
                        Text('Prise : ${supplement.timing}'),
                        if (supplement.notes != null)
                          Text(
                            supplement.notes!,
                            style: const TextStyle(
                              fontStyle: FontStyle.italic,
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _removeSupplement(index),
                      color: PremiumTheme.error,
                    ),
                    isThreeLine: supplement.notes != null,
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
