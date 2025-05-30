// lib/presentation/widgets/meal_selection_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lym_nutrition/domain/entities/food_item.dart';
import 'package:lym_nutrition/presentation/themes/premium_theme.dart';

class MealSelectionDialog extends StatefulWidget {
  final FoodItem food;
  
  const MealSelectionDialog({
    Key? key,
    required this.food,
  }) : super(key: key);

  @override
  State<MealSelectionDialog> createState() => _MealSelectionDialogState();
}

class _MealSelectionDialogState extends State<MealSelectionDialog> {
  String _selectedMeal = 'Déjeuner';
  double _quantity = 100.0;
  String _selectedUnit = 'g';
  
  final List<String> _meals = [
    'Petit-déjeuner',
    'Collation matin',
    'Déjeuner',
    'Collation après-midi',
    'Dîner',
    'En-cas'
  ];
  
  final List<String> _units = [
    'g',
    'ml',
    'portion',
    'cuillère à soupe',
    'cuillère à café',
    'tasse',
    'bol',
    'assiette',
  ];

  final TextEditingController _quantityController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _quantityController.text = _quantity.toString();
    _quantityController.addListener(_updateQuantity);
  }
  
  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }
  
  void _updateQuantity() {
    final value = double.tryParse(_quantityController.text);
    if (value != null && value > 0) {
      setState(() {
        _quantity = value;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(PremiumTheme.borderRadiusLarge),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Titre du dialogue
            Text(
              'Ajouter à un repas',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: PremiumTheme.primaryColor,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 8),
            
            // Nom de l'aliment
            Text(
              widget.food.name,
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 24),
            
            // Sélection du repas
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Repas',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: theme.colorScheme.onSurface.withOpacity(0.2),
                    ),
                    borderRadius: BorderRadius.circular(PremiumTheme.borderRadiusMedium),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedMeal,
                      isExpanded: true,
                      icon: const Icon(Icons.arrow_drop_down),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      borderRadius: BorderRadius.circular(PremiumTheme.borderRadiusMedium),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _selectedMeal = newValue;
                          });
                        }
                      },
                      items: _meals.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Quantité et unité
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Quantité
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Quantité',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _quantityController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*')),
                        ],
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(PremiumTheme.borderRadiusMedium),
                            borderSide: BorderSide(
                              color: theme.colorScheme.onSurface.withOpacity(0.2),
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // Unité
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Unité',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: theme.colorScheme.onSurface.withOpacity(0.2),
                          ),
                          borderRadius: BorderRadius.circular(PremiumTheme.borderRadiusMedium),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedUnit,
                            isExpanded: true,
                            icon: const Icon(Icons.arrow_drop_down),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            borderRadius: BorderRadius.circular(PremiumTheme.borderRadiusMedium),
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                setState(() {
                                  _selectedUnit = newValue;
                                });
                              }
                            },
                            items: _units.map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Résumé nutritionnel
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: PremiumTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(PremiumTheme.borderRadiusMedium),
              ),
              child: Column(
                children: [
                  Text(
                    'Résumé nutritionnel',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildNutrientInfo('Calories', _calculateNutrient(widget.food.calories), 'kcal'),
                      _buildNutrientInfo('Protéines', _calculateNutrient(widget.food.proteins), 'g'),
                      _buildNutrientInfo('Glucides', _calculateNutrient(widget.food.carbs), 'g'),
                      _buildNutrientInfo('Lipides', _calculateNutrient(widget.food.fats), 'g'),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Boutons d'action
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Annuler'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    // Retourner les informations sélectionnées
                    Navigator.of(context).pop({
                      'meal': _selectedMeal,
                      'quantity': _quantity,
                      'unit': _selectedUnit,
                      'food': widget.food,
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: PremiumTheme.primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Ajouter'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildNutrientInfo(String label, double value, String unit) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.black87,
          ),
        ),
        Text(
          '${value.toStringAsFixed(1)} $unit',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
  
  double _calculateNutrient(double value) {
    // Calculer la valeur nutritionnelle en fonction de la quantité sélectionnée
    // Les valeurs de base sont pour 100g
    return (value * _quantity) / 100;
  }
}