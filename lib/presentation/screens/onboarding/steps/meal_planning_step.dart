// lib/presentation/screens/onboarding/steps/meal_planning_step.dart
import 'package:flutter/material.dart';
import 'package:lym_nutrition/domain/entities/user_profile.dart';
import 'package:lym_nutrition/presentation/themes/lym_design_system.dart';

class MealPlanningStep extends StatefulWidget {
  final UserProfile userProfile;
  final Function(UserProfile) onUpdateProfile;
  final VoidCallback onNextRequested;

  const MealPlanningStep({
    Key? key,
    required this.userProfile,
    required this.onUpdateProfile,
    required this.onNextRequested,
  }) : super(key: key);

  @override
  State<MealPlanningStep> createState() => MealPlanningStepState();
}

class MealPlanningStepState extends State<MealPlanningStep>
    with AutomaticKeepAliveClientMixin {
  late CookingLevel _cookingLevel;
  late CookingTime _weekdayCookingTime;
  late CookingTime _weekendCookingTime;
  late FoodBudget _weeklyBudget;
  double? _specificBudgetAmount;
  final _budgetController = TextEditingController();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    final prefs = widget.userProfile.mealPlanningPreferences;
    _cookingLevel = prefs.cookingLevel;
    _weekdayCookingTime = prefs.weekdayCookingTime;
    _weekendCookingTime = prefs.weekendCookingTime;
    _weeklyBudget = prefs.weeklyBudget;
    _specificBudgetAmount = prefs.specificBudgetAmount;

    if (_specificBudgetAmount != null) {
      _budgetController.text = _specificBudgetAmount!.toStringAsFixed(0);
    }
  }

  @override
  void dispose() {
    _budgetController.dispose();
    super.dispose();
  }

  void _updateProfile() {
    final updatedPreferences = MealPlanningPreferences(
      cookingLevel: _cookingLevel,
      weekdayCookingTime: _weekdayCookingTime,
      weekendCookingTime: _weekendCookingTime,
      weeklyBudget: _weeklyBudget,
      specificBudgetAmount: _specificBudgetAmount,
    );

    widget.onUpdateProfile(
      widget.userProfile.copyWith(
        mealPlanningPreferences: updatedPreferences,
      ),
    );
  }

  void validateAndProceed() {
    _updateProfile();
    widget.onNextRequested();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cooking Level Section
          _buildSectionTitle('Niveau de cuisine', 'Vos compétences culinaires'),
          const SizedBox(height: 16),
          ..._buildCookingLevelOptions(),

          const SizedBox(height: 32),

          // Weekday Cooking Time Section
          _buildSectionTitle('Temps de cuisine en semaine',
              'Combien de temps avez-vous pour cuisiner les jours de travail?'),
          const SizedBox(height: 16),
          ..._buildCookingTimeOptions(
            selectedTime: _weekdayCookingTime,
            onChanged: (time) {
              setState(() {
                _weekdayCookingTime = time;
              });
            },
          ),

          const SizedBox(height: 32),

          // Weekend Cooking Time Section
          _buildSectionTitle('Temps de cuisine le week-end',
              'Combien de temps avez-vous pour cuisiner les week-ends?'),
          const SizedBox(height: 16),
          ..._buildCookingTimeOptions(
            selectedTime: _weekendCookingTime,
            onChanged: (time) {
              setState(() {
                _weekendCookingTime = time;
              });
            },
          ),

          const SizedBox(height: 32),

          // Budget Section
          _buildSectionTitle('Budget alimentaire hebdomadaire',
              'Quel est votre budget pour les courses alimentaires par semaine?'),
          const SizedBox(height: 16),
          ..._buildBudgetOptions(),

          if (_weeklyBudget == FoodBudget.generous) ...[
            const SizedBox(height: 16),
            _buildSpecificBudgetInput(),
          ],

          const SizedBox(height: 48),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: LymDesignSystem.gray800,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Tooltip(
              message: subtitle,
              child: const Icon(
                Icons.info_outline,
                size: 16,
                color: LymDesignSystem.gray500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 14,
            color: LymDesignSystem.gray700,
          ),
        ),
      ],
    );
  }

  List<Widget> _buildCookingLevelOptions() {
    final levels = [
      (
        CookingLevel.beginner,
        'Débutant',
        'Recettes simples, peu d\'ingrédients',
        Icons.egg_outlined,
      ),
      (
        CookingLevel.intermediate,
        'Intermédiaire',
        'Recettes variées, techniques de base',
        Icons.restaurant,
      ),
      (
        CookingLevel.advanced,
        'Avancé',
        'Recettes complexes, techniques élaborées',
        Icons.restaurant_menu,
      ),
      (
        CookingLevel.expert,
        'Expert',
        'Toutes techniques, créativité culinaire',
        Icons.local_dining,
      ),
    ];

    return levels.map((level) {
      final isSelected = _cookingLevel == level.$1;
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: InkWell(
          onTap: () {
            setState(() {
              _cookingLevel = level.$1;
            });
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected
                  ? LymDesignSystem.primary.withOpacity(0.1)
                  : LymDesignSystem.gray100,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color:
                    isSelected ? LymDesignSystem.primary : Colors.transparent,
                width: 2,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  level.$4,
                  color: isSelected
                      ? LymDesignSystem.primary
                      : LymDesignSystem.gray600,
                  size: 32,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        level.$2,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? LymDesignSystem.primary
                              : LymDesignSystem.gray800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        level.$3,
                        style: TextStyle(
                          fontSize: 14,
                          color: LymDesignSystem.gray700,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  const Icon(
                    Icons.check_circle,
                    color: LymDesignSystem.primary,
                    size: 24,
                  ),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }

  List<Widget> _buildCookingTimeOptions({
    required CookingTime selectedTime,
    required Function(CookingTime) onChanged,
  }) {
    final times = [
      (CookingTime.minimal, '< 15 min', 'Repas très rapides'),
      (CookingTime.short, '15-30 min', 'Recettes simples et rapides'),
      (CookingTime.moderate, '30-60 min', 'Temps modéré pour cuisiner'),
      (CookingTime.long, '> 60 min', 'Plats élaborés, cuisine plaisir'),
    ];

    return times.map((time) {
      final isSelected = selectedTime == time.$1;
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: InkWell(
          onTap: () => onChanged(time.$1),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? LymDesignSystem.info.withOpacity(0.1)
                  : LymDesignSystem.gray100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? LymDesignSystem.info : Colors.transparent,
                width: 2,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.access_time,
                  color: isSelected
                      ? LymDesignSystem.info
                      : LymDesignSystem.gray600,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        time.$2,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? LymDesignSystem.info
                              : LymDesignSystem.gray800,
                        ),
                      ),
                      Text(
                        time.$3,
                        style: TextStyle(
                          fontSize: 13,
                          color: LymDesignSystem.gray600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  const Icon(
                    Icons.check_circle,
                    color: LymDesignSystem.info,
                    size: 20,
                  ),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }

  List<Widget> _buildBudgetOptions() {
    final budgets = [
      (
        FoodBudget.tight,
        'Budget serré',
        '< 50€ par semaine',
        Icons.savings_outlined,
      ),
      (
        FoodBudget.moderate,
        'Budget modéré',
        '50-100€ par semaine',
        Icons.account_balance_wallet_outlined,
      ),
      (
        FoodBudget.comfortable,
        'Budget confortable',
        '100-150€ par semaine',
        Icons.wallet_outlined,
      ),
      (
        FoodBudget.generous,
        'Budget généreux',
        '> 150€ par semaine',
        Icons.account_balance_outlined,
      ),
    ];

    return budgets.map((budget) {
      final isSelected = _weeklyBudget == budget.$1;
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: InkWell(
          onTap: () {
            setState(() {
              _weeklyBudget = budget.$1;
              if (budget.$1 != FoodBudget.generous) {
                _specificBudgetAmount = null;
                _budgetController.clear();
              }
            });
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected
                  ? LymDesignSystem.success.withOpacity(0.1)
                  : LymDesignSystem.gray100,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color:
                    isSelected ? LymDesignSystem.success : Colors.transparent,
                width: 2,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  budget.$4,
                  color: isSelected
                      ? LymDesignSystem.success
                      : LymDesignSystem.gray600,
                  size: 32,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        budget.$2,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? LymDesignSystem.success
                              : LymDesignSystem.gray800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        budget.$3,
                        style: TextStyle(
                          fontSize: 14,
                          color: LymDesignSystem.gray700,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  const Icon(
                    Icons.check_circle,
                    color: LymDesignSystem.success,
                    size: 24,
                  ),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }

  Widget _buildSpecificBudgetInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: LymDesignSystem.gray100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Montant spécifique (optionnel)',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: LymDesignSystem.gray800,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _budgetController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'Ex: 200',
              suffixText: '€/semaine',
              isDense: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: LymDesignSystem.gray400),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: LymDesignSystem.gray400),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: LymDesignSystem.gray400,
                  width: 1,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
            ),
            onChanged: (value) {
              setState(() {
                _specificBudgetAmount = double.tryParse(value);
              });
            },
          ),
        ],
      ),
    );
  }
}
