// lib/presentation/screens/meal_planning_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lym_nutrition/presentation/screens/food_search_screen.dart';
import 'package:lym_nutrition/presentation/themes/fresh_theme.dart';
import 'package:lym_nutrition/presentation/screens/main_app_shell.dart';
import 'package:lym_nutrition/presentation/screens/chat/nutrition_chat_service.dart';

import 'dart:async';

import 'package:lym_nutrition/domain/entities/user_profile.dart';
import 'package:lym_nutrition/domain/entities/user_dietary_preferences.dart';
import 'package:lym_nutrition/presentation/bloc/user_profile/user_profile_bloc.dart';
import 'package:lym_nutrition/presentation/bloc/user_profile/user_profile_state.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class MealPlanningScreen extends StatefulWidget {
  final DateTime? targetDate; // Optionnel: date du journal à compléter
  final PlanType? initialPlanType; // Pré-sélectionner Journée/Semaine
  final bool weeklyModeOnly; // Si true, n'afficher que la planification semaine
  final bool
      aiOnlyMode; // Si true, n'afficher que l'IA (pas de recherche manuelle)
  const MealPlanningScreen({
    Key? key,
    this.targetDate,
    this.initialPlanType,
    this.weeklyModeOnly = false,
    this.aiOnlyMode = false,
  }) : super(key: key);

  @override
  State<MealPlanningScreen> createState() => _MealPlanningScreenState();
}

class _MealPlanningScreenState extends State<MealPlanningScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  bool _isGeneratingMeals = false;
  List<MealSuggestion> _dailyMeals = [];
  Map<String, List<MealSuggestion>> _weeklyMeals = {};
  PlanType _selectedPlanType = PlanType.daily;
  // Slider value: 0.0 = très healthy, 1.0 = très gourmand
  double _indulgenceLevel = 0.5;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    if (widget.initialPlanType != null) {
      _selectedPlanType = widget.initialPlanType!;
    }
    if (widget.weeklyModeOnly) {
      _selectedPlanType = PlanType.weekly;
    } else {
      // Dans l'écran normal "Mes repas", seule l'option "Journée" est disponible
      _selectedPlanType = PlanType.daily;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.weeklyModeOnly
              ? 'Planifier la semaine'
              : widget.aiOnlyMode
                  ? 'Générer le plan du jour'
                  : 'Mes repas',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
        ),
        backgroundColor: FreshTheme.primaryMint,
        elevation: 0,
        automaticallyImplyLeading: true,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              )
            : null,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                FreshTheme.primaryMint,
                FreshTheme.serenityBlue,
              ],
            ),
          ),
        ),
        bottom: (widget.weeklyModeOnly || widget.aiOnlyMode)
            ? null
            : TabBar(
                controller: _tabController,
                indicatorColor: Colors.white,
                indicatorWeight: 3,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white.withValues(alpha: 0.7),
                labelStyle: const TextStyle(fontWeight: FontWeight.w600),
                tabs: const [
                  Tab(
                    icon: Icon(Icons.search_rounded),
                    text: 'Recherche',
                  ),
                  Tab(
                    icon: Icon(Icons.auto_awesome_rounded),
                    text: 'IA Coach',
                  ),
                ],
              ),
      ),
      body: (widget.weeklyModeOnly || widget.aiOnlyMode)
          ? _buildAIMealPlanningTab()
          : TabBarView(
              controller: _tabController,
              children: [
                // Manual search tab
                const FoodSearchScreen(),
                // AI meal planning tab
                _buildAIMealPlanningTab(),
              ],
            ),
    );
  }

  Widget _buildAIMealPlanningTab() {
    return BlocBuilder<UserProfileBloc, UserProfileState>(
      builder: (context, state) {
        if (state is UserProfileLoaded) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  FreshTheme.cloudWhite,
                  FreshTheme.mistGray.withAlpha(100),
                ],
              ),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FutureBuilder<Map<String, dynamic>>(
                    future: _getConsumedMealsToday(),
                    builder: (context, snapshot) {
                      // SECURISE: Vérifie que snapshot.data et la clé 'calories' ne sont pas null
                      if (snapshot.hasData &&
                          (snapshot.data?['calories'] ?? 0) > 0) {
                        return _buildConsumedMealsInfo(snapshot.data!);
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                  const SizedBox(height: 16),
                  if (!widget.weeklyModeOnly) _buildPlanTypeSelector(),
                  const SizedBox(height: 16),
                  _buildIndulgenceSlider(),
                  const SizedBox(height: 20),
                  _buildGenerateButton(state.userProfile),
                  const SizedBox(height: 20),
                  if (_isGeneratingMeals)
                    const Center(
                      child: Column(
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('L\'IA prépare vos repas...'),
                        ],
                      ),
                    ),
                  if (!widget.weeklyModeOnly &&
                      !_isGeneratingMeals &&
                      _selectedPlanType == PlanType.daily &&
                      _dailyMeals.isNotEmpty)
                    _buildDailyMealPlan(),
                  if (!_isGeneratingMeals &&
                      _selectedPlanType == PlanType.weekly &&
                      _weeklyMeals.isNotEmpty)
                    _buildWeeklyMealPlan(),
                ],
              ),
            ),
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildConsumedMealsInfo(Map<String, dynamic> consumedData) {
    final calories = (consumedData['calories'] as double? ?? 0.0).round();
    final protein = (consumedData['protein'] as double? ?? 0.0).round();
    final carbs = (consumedData['carbs'] as double? ?? 0.0).round();
    final fat = (consumedData['fat'] as double? ?? 0.0).round();
    final mealTypes = consumedData['mealTypes'] as List<String>? ?? [];

    return Card(
      elevation: 2,
      shadowColor: FreshTheme.primaryMint.withAlpha(60),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline,
                    color: FreshTheme.primaryMint, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Repas déjà consommés aujourd\'hui',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: FreshTheme.primaryMint,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'L\'IA tiendra compte de ces repas pour proposer les repas restants:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: FreshTheme.stormGray,
                  ),
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNutrientInfo('Calories', '$calories', Colors.orange),
                  const SizedBox(width: 16),
                  _buildNutrientInfo('Protéines', '${protein}g', Colors.blue),
                  const SizedBox(width: 16),
                  _buildNutrientInfo('Glucides', '${carbs}g', Colors.green),
                  const SizedBox(width: 16),
                  _buildNutrientInfo('Lipides', '${fat}g', Colors.redAccent),
                ],
              ),
            ),
            if (mealTypes.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Types de repas: ${mealTypes.join(', ')}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: FreshTheme.stormGray,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNutrientInfo(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildPlanTypeSelector() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.calendar_today, color: FreshTheme.primaryMint),
              const SizedBox(width: 12),
              Text(
                'Type de planification',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: FreshTheme.primaryMint,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Option "Journée" seulement - "Semaine" est disponible depuis le Journal
          _buildPlanTypeOption(
            PlanType.daily,
            'Journée',
            Icons.today,
            'Plan pour aujourd\'hui',
          ),
        ],
      ),
    );
  }

  Widget _buildIndulgenceSlider() {
    return Card(
      elevation: 2,
      shadowColor: FreshTheme.primaryMint.withAlpha(60),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.emoji_emotions_outlined,
                    color: FreshTheme.primaryMint),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Niveau de plaisir des repas',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: FreshTheme.primaryMint,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Faites-vous plaisir, sans compromettre vos objectifs',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: FreshTheme.stormGray),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text('Healthy',
                    style: Theme.of(context)
                        .textTheme
                        .labelMedium
                        ?.copyWith(color: Colors.grey[700])),
                Expanded(
                  child: Slider(
                    value: _indulgenceLevel,
                    min: 0,
                    max: 1,
                    divisions: 10,
                    label: _indulgenceLevel <= 0.33
                        ? 'Très healthy'
                        : (_indulgenceLevel >= 0.67
                            ? 'Très gourmand'
                            : 'Équilibré'),
                    activeColor: FreshTheme.primaryMint,
                    onChanged: (value) {
                      setState(() {
                        _indulgenceLevel = value;
                      });
                    },
                  ),
                ),
                Text('Gourmand',
                    style: Theme.of(context)
                        .textTheme
                        .labelMedium
                        ?.copyWith(color: Colors.grey[700])),
              ],
            ),
            Text(
              _indulgenceLevel <= 0.33
                  ? 'Léger, frais, peu sucré'
                  : (_indulgenceLevel >= 0.67
                      ? 'Confort, plus de gourmandise (toujours dans vos calories)'
                      : 'Équilibré, plaisir et légèreté'),
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanTypeOption(
      PlanType type, String label, IconData icon, String description) {
    final isSelected = _selectedPlanType == type;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedPlanType = type;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color:
              isSelected ? FreshTheme.primaryMint.withAlpha(30) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? FreshTheme.primaryMint : FreshTheme.mistGray,
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: FreshTheme.primaryMint.withAlpha(50),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ]
              : [],
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? FreshTheme.primaryMint : FreshTheme.stormGray,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isSelected
                        ? FreshTheme.primaryMintDark
                        : FreshTheme.midnightGray,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: FreshTheme.stormGray,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenerateButton(UserProfile userProfile) {
    return Center(
      child: ElevatedButton.icon(
        onPressed:
            _isGeneratingMeals ? null : () => _generateMealPlan(userProfile),
        icon: const Icon(Icons.auto_awesome),
        label: Text(_selectedPlanType == PlanType.daily
            ? 'Générer le plan du jour'
            : 'Générer le plan de la semaine'),
        style: ElevatedButton.styleFrom(
          backgroundColor: FreshTheme.primaryMint,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 5,
          shadowColor: FreshTheme.primaryMint.withAlpha(100),
        ),
      ),
    );
  }

  Widget _buildDailyMealPlan() {
    final totals = _calculateTotals(_dailyMeals);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Plan du jour',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: FreshTheme.primaryMint,
                  ),
            ),
            _buildActionButtons(),
          ],
        ),
        const SizedBox(height: 16),

        // Totals Card
        _buildTotalsCard(totals),
        const SizedBox(height: 16),

        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _dailyMeals.length,
          itemBuilder: (context, index) {
            final meal = _dailyMeals[index];
            return _buildMealCard(meal, index, null);
          },
        ),
      ],
    );
  }

  String _getDayName(int weekday) {
    switch (weekday) {
      case 1:
        return 'Lundi';
      case 2:
        return 'Mardi';
      case 3:
        return 'Mercredi';
      case 4:
        return 'Jeudi';
      case 5:
        return 'Vendredi';
      case 6:
        return 'Samedi';
      case 7:
        return 'Dimanche';
      default:
        return 'Jour';
    }
  }

  Widget _buildWeeklyMealPlan() {
    // Générer les 7 prochains jours avec dates exactes
    final now = DateTime.now();
    final daysWithDates = <Map<String, String>>[];

    for (int i = 0; i < 7; i++) {
      final date = now.add(Duration(days: i));
      final dayName = _getDayName(date.weekday);
      final dateString = date.toIso8601String().split('T').first;
      final displayDate =
          '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}';

      daysWithDates.add({
        'name': dayName,
        'date': dateString,
        'display': displayDate,
      });
    }

    final days = daysWithDates.map((d) => d['name']!).toList();

    // Calculate weekly totals
    final allMeals = <MealSuggestion>[];
    for (final day in days) {
      allMeals.addAll(_weeklyMeals[day] ?? []);
    }
    final weeklyTotals = _calculateTotals(allMeals);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Plan de la semaine',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: FreshTheme.primaryMint,
                  ),
            ),
            _buildActionButtons(),
          ],
        ),
        const SizedBox(height: 16),

        // Weekly Totals Card
        _buildTotalsCard(weeklyTotals),
        const SizedBox(height: 16),

        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: days.length,
          itemBuilder: (context, index) {
            final day = days[index];
            final dayData = daysWithDates[index];
            final meals = _weeklyMeals[day] ?? [];
            final dayTotals = _calculateTotals(meals);
            return ExpansionTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide.none,
              ),
              collapsedShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide.none,
              ),
              backgroundColor: Colors.white,
              collapsedBackgroundColor: FreshTheme.mistGray,
              iconColor: FreshTheme.primaryMint,
              collapsedIconColor: FreshTheme.stormGray,
              childrenPadding: const EdgeInsets.symmetric(horizontal: 8),
              title: Text(
                '$day ${dayData['display']}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                '${meals.length} repas • ${dayTotals.calories} kcal',
                style: const TextStyle(fontSize: 12),
              ),
              children: meals.asMap().entries.map((entry) {
                final index = entry.key;
                final meal = entry.value;
                return _buildMealCard(meal, index, day);
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.refresh),
          color: FreshTheme.primaryMint,
          tooltip: 'Nouveau programme',
          onPressed: () => _showNewProgramDialog(),
        ),
        IconButton(
          icon: const Icon(Icons.save_alt),
          color: Colors.green,
          tooltip: 'Sauvegarder',
          onPressed: () => _saveMealPlan(),
        ),
      ],
    );
  }

  Widget _buildMealCard(MealSuggestion meal, int index, String? day) {
    return Card(
      elevation: 2,
      shadowColor: Colors.black.withAlpha(30),
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image preview removed (no external providers)
            if (meal.name.isNotEmpty) const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        meal.mealType,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: FreshTheme.primaryMint,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        meal.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: FreshTheme.midnightGray,
                            ),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Recettes consultables désormais depuis le Journal uniquement
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline, size: 20),
                      color: FreshTheme.primaryMint,
                      tooltip: 'Ajouter au jour',
                      onPressed: () => _saveSingleMeal(
                        meal,
                        dateString: _resolveDateForDay(day),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit, size: 20),
                      color: Colors.blue,
                      onPressed: () => _editMeal(meal, index, day),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, size: 20),
                      color: Colors.red,
                      onPressed: () => _deleteMeal(index, day),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              meal.description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: FreshTheme.stormGray,
                  ),
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildNutrientChip(
                      'Calories', '${meal.calories} kcal', Colors.orange),
                  const SizedBox(width: 8),
                  _buildNutrientChip(
                      'Protéines', '${meal.protein}g', Colors.blue),
                  const SizedBox(width: 8),
                  _buildNutrientChip(
                      'Glucides', '${meal.carbs}g', Colors.green),
                  const SizedBox(width: 8),
                  _buildNutrientChip(
                      'Lipides', '${meal.fat}g', Colors.redAccent),
                ],
              ),
            ),
            if (meal.cookingTime != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.schedule, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(
                    '${meal.cookingTime} min',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Resolve ISO date for a given localized weekday name from the generated list
  String? _resolveDateForDay(String? dayName) {
    if (dayName == null) return null;
    final now = DateTime.now();
    for (int i = 0; i < 7; i++) {
      final d = now.add(Duration(days: i));
      if (_getDayName(d.weekday) == dayName) {
        return d.toIso8601String().split('T').first;
      }
    }
    return null;
  }

  Widget _buildNutrientChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Future<Map<String, dynamic>> _getConsumedMealsToday() async {
    final today = DateTime.now().toIso8601String().split('T').first;
    return _getConsumedMealsForDate(today);
  }

  Future<Map<String, dynamic>> _getConsumedMealsForDate(String date) async {
    final prefs = await SharedPreferences.getInstance();
    final journalKey = 'journal_$date';

    // Get all meals consumed today ONLY from journal (like Dashboard)
    double consumedCalories = 0;
    double consumedProtein = 0;
    double consumedCarbs = 0;
    double consumedFat = 0;
    List<String> consumedMealTypes = [];

    // Load from journal (unified source)
    final journalJson = prefs.getString(journalKey);
    print('🔍 Loading consumed meals from: $journalKey');

    if (journalJson != null) {
      try {
        final journalData = jsonDecode(journalJson) as Map<String, dynamic>;
        final meals = journalData['meals'] as List<dynamic>? ?? [];

        print('✅ Found ${meals.length} meals in journal for $date');
        for (final mealData in meals) {
          // Accès direct aux données JSON sans UserFoodModel
          final calories = (mealData['calories'] ?? 0).toDouble();
          final proteins =
              (mealData['proteins'] ?? mealData['protein'] ?? 0).toDouble();
          final carbs = (mealData['carbs'] ?? 0).toDouble();
          final fats = (mealData['fats'] ?? mealData['fat'] ?? 0).toDouble();
          final mealType = mealData['mealType'] as String?;

          consumedCalories += calories;
          consumedProtein += proteins;
          consumedCarbs += carbs;
          consumedFat += fats;

          if (mealType != null && !consumedMealTypes.contains(mealType)) {
            consumedMealTypes.add(mealType);
          }
        }
      } catch (e) {
        print('❌ Error parsing journal meals for $date: $e');
      }
    } else {
      print('✅ No journal data found for $date - clean slate');
    }

    print(
        '📊 Total consumed on $date: ${consumedCalories.round()} kcal from ${consumedMealTypes.length} meal types');

    return {
      'calories': consumedCalories,
      'protein': consumedProtein,
      'carbs': consumedCarbs,
      'fat': consumedFat,
      'mealTypes': consumedMealTypes,
    };
  }

  Future<void> _generateMealPlan(UserProfile userProfile) async {
    setState(() {
      _isGeneratingMeals = true;
    });

    try {
      // Get already consumed meals for context
      final consumedToday = await _getConsumedMealsToday();

      if (_selectedPlanType == PlanType.daily) {
        // Generate meals using GPT AI with user profile analysis
        final mealSuggestions =
            await _generateGPTMeals(userProfile, consumedToday);

        setState(() {
          _dailyMeals = mealSuggestions;
          _isGeneratingMeals = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Plan personnalisé généré avec ${mealSuggestions.length} repas!'),
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: 'Voir Journal',
              textColor: Colors.white,
              onPressed: () {
                // Navigate to main app with journal tab selected
                // Aller au Journal (onglet 2) via dashboard
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                        builder: (_) => const MainAppShell(initialIndex: 1)),
                    (route) => false);
              },
            ),
          ),
        );
      } else {
        // For weekly plans, fallback to existing logic for now
        _generateSimulatedMeals(userProfile);
      }
    } catch (e) {
      print('Meal generation error: $e');

      setState(() {
        _isGeneratingMeals = false;
      });

      // Fallback to simulated meals if hybrid generation fails
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Utilisation du mode de secours: ${e.toString()}'),
          backgroundColor: Colors.orange,
        ),
      );

      _generateSimulatedMeals(userProfile);
    }
  }

  void _editMeal(MealSuggestion meal, int index, String? day) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Modifier le repas'),
        content: const Text(
            'Fonctionnalité à venir: modification manuelle des repas'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _deleteMeal(int index, String? day) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer ce repas?'),
        content: const Text('Cette action est irréversible.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                if (day == null) {
                  _dailyMeals.removeAt(index);
                } else {
                  _weeklyMeals[day]?.removeAt(index);
                }
              });
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  void _showNewProgramDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nouveau programme'),
        content: const Text('Voulez-vous générer un nouveau plan de repas?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              final userProfile = context.read<UserProfileBloc>().state;
              if (userProfile is UserProfileLoaded) {
                _generateMealPlan(userProfile.userProfile);
              }
            },
            child: const Text('Générer'),
          ),
        ],
      ),
    );
  }

  void _saveMealPlan() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      int addedCount = 0;

      if (_selectedPlanType == PlanType.daily) {
        // Save daily meals with proper date format
        final mealsJson = _dailyMeals.map((meal) => meal.toJson()).toList();
        final dateString =
            DateTime.now().toIso8601String().split('T').first; // Only date part

        print('💾 Saving daily meals: ${mealsJson.length} meals');
        print('📅 Date string: $dateString');

        await prefs.setString('saved_daily_meals', jsonEncode(mealsJson));
        await prefs.setString('saved_daily_meals_date', dateString);

        // Also save to unified journal for consistency
        addedCount = await _saveToJournal(prefs, dateString, mealsJson);

        // Verify save
        final savedJson = prefs.getString('saved_daily_meals');
        final savedDate = prefs.getString('saved_daily_meals_date');
        print(
            'Verification - Saved JSON: ${savedJson != null ? 'Success' : 'Failed'}');
        print('Verification - Saved Date: $savedDate');
      } else {
        // Save weekly meals
        final weeklyJson = _weeklyMeals.map((day, meals) =>
            MapEntry(day, meals.map((meal) => meal.toJson()).toList()));
        await prefs.setString('saved_weekly_meals', jsonEncode(weeklyJson));
        await prefs.setString('saved_weekly_meals_date',
            DateTime.now().toIso8601String().split('T').first);

        // For weekly meals, count total meals saved
        addedCount =
            _weeklyMeals.values.fold(0, (sum, meals) => sum + meals.length);
      }

      // Show appropriate message based on duplicates
      String message;
      Color color = Colors.green;

      if (_selectedPlanType == PlanType.daily) {
        final duplicateCount = _dailyMeals.length - addedCount;
        if (duplicateCount > 0) {
          message =
              '$addedCount repas ajoutés (${duplicateCount} doublons ignorés)';
          color = Colors.orange;
        } else {
          message = 'Plan de repas sauvegardé! ($addedCount repas ajoutés)';
        }
      } else {
        message = 'Plan de repas sauvegardé! ($addedCount repas)';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: color,
        ),
      );
    } catch (e) {
      print('Error saving meal plan: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la sauvegarde: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<int> _saveToJournal(SharedPreferences prefs, String dateString,
      List<Map<String, dynamic>> mealsJson) async {
    final journalKey = 'journal_$dateString';

    // Get existing journal data to preserve sports sessions
    Map<String, dynamic> journalData = {};
    final existingJournal = prefs.getString(journalKey);
    if (existingJournal != null) {
      try {
        journalData = jsonDecode(existingJournal) as Map<String, dynamic>;
      } catch (e) {
        print('❌ Error parsing existing journal: $e');
      }
    }

    // Calculate totals
    double totalCalories = 0;
    double totalProtein = 0;
    double totalCarbs = 0;
    double totalFat = 0;

    for (final meal in mealsJson) {
      totalCalories += (meal['calories'] ?? 0).toDouble();
      totalProtein += (meal['protein'] ?? 0).toDouble();
      totalCarbs += (meal['carbs'] ?? 0).toDouble();
      totalFat += (meal['fat'] ?? 0).toDouble();
    }

    // Get existing meals to check for duplicates
    final existingMeals =
        List<Map<String, dynamic>>.from(journalData['meals'] ?? []);

    // Filter out duplicates (same name and mealType)
    final uniqueNewMeals = <Map<String, dynamic>>[];
    for (final newMeal in mealsJson) {
      final isDuplicate = existingMeals.any((existing) =>
          existing['name'] == newMeal['name'] &&
          existing['mealType'] == newMeal['mealType']);

      if (!isDuplicate) {
        uniqueNewMeals.add(newMeal);
      } else {
        print(
            '⚠️ Skipping duplicate meal: ${newMeal['name']} (${newMeal['mealType']})');
      }
    }

    // Add unique new meals to existing ones
    existingMeals.addAll(uniqueNewMeals);

    // Recalculate totals with all meals
    totalCalories = 0;
    totalProtein = 0;
    totalCarbs = 0;
    totalFat = 0;

    for (final meal in existingMeals) {
      totalCalories += (meal['calories'] ?? 0).toDouble();
      totalProtein += (meal['protein'] ?? 0).toDouble();
      totalCarbs += (meal['carbs'] ?? 0).toDouble();
      totalFat += (meal['fat'] ?? 0).toDouble();
    }

    // Update journal data
    journalData['calories'] = totalCalories.round();
    journalData['protein'] = totalProtein.round();
    journalData['carbs'] = totalCarbs.round();
    journalData['fat'] = totalFat.round();
    journalData['meals'] = existingMeals;
    // Preserve existing sports if any
    journalData['sports'] = journalData['sports'] ?? [];

    // Save updated journal
    await prefs.setString(journalKey, jsonEncode(journalData));

    // Update journal index
    final indexRaw = prefs.getString('journal_index');
    final Set<String> index = indexRaw != null
        ? (Set<String>.from(jsonDecode(indexRaw)))
        : <String>{};
    index.add(journalKey);
    await prefs.setString('journal_index', jsonEncode(index.toList()));

    print(
        '📝 Saved ${uniqueNewMeals.length}/${mealsJson.length} meals to journal for $dateString (${mealsJson.length - uniqueNewMeals.length} duplicates skipped)');
    return uniqueNewMeals.length;
  }

  void _saveSingleMeal(MealSuggestion meal, {String? dateString}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final date = (dateString ??
              widget.targetDate?.toIso8601String().split('T')[0] ??
              DateTime.now().toIso8601String().split('T')[0])
          .toString();

      // Get existing individual meals for selected date (new key)
      final existingMealsJson = prefs.getString('individual_meals_' + date) ??
          // Backward compat: today-only key
          (prefs.getString('individual_meals_today'));

      List<Map<String, dynamic>> individualMeals = [];

      if (existingMealsJson != null) {
        final savedData = jsonDecode(existingMealsJson);
        final savedDate = savedData['date'];
        if (savedDate == date) {
          individualMeals = List<Map<String, dynamic>>.from(savedData['meals']);
        }
      }

      // Add the new meal
      individualMeals.add(meal.toJson());

      // Save back under the specific date
      await prefs.setString(
          'individual_meals_' + date,
          jsonEncode({
            'date': date,
            'meals': individualMeals,
          }));

      // Maintain legacy key for current day to avoid breaking other flows
      final todayDate = DateTime.now().toIso8601String().split('T')[0];
      if (date == todayDate) {
        await prefs.setString(
            'individual_meals_today',
            jsonEncode({
              'date': todayDate,
              'meals': individualMeals,
            }));
      }

      // Also save into unified journal for that date
      await _saveToJournal(prefs, date, [meal.toJson()]);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${meal.name} ajouté au journal du ' + date + '!'),
          backgroundColor: Colors.green,
          action: SnackBarAction(
            label: 'Voir',
            textColor: Colors.white,
            onPressed: () {
              // Navigate back to dashboard - this will trigger a refresh
              if (Navigator.canPop(context)) {
                Navigator.pop(
                    context, true); // Return true to indicate meals were saved
              } else {
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                        builder: (_) => const MainAppShell(initialIndex: 1)),
                    (route) => false);
              }
            },
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de l\'ajout: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildTotalsCard(MealTotals totals) {
    return Card(
      elevation: 2,
      shadowColor: FreshTheme.primaryMint.withAlpha(60),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: FreshTheme.primaryMint.withAlpha(20),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.analytics, color: FreshTheme.primaryMint),
                const SizedBox(width: 12),
                Text(
                  'Totaux nutritionnels',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: FreshTheme.primaryMint,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTotalItem(
                    'Calories',
                    '${totals.calories}',
                    'kcal',
                    Colors.orange,
                    Icons.local_fire_department,
                  ),
                ),
                Expanded(
                  child: _buildTotalItem(
                    'Protéines',
                    '${totals.protein}',
                    'g',
                    Colors.blueAccent,
                    Icons.fitness_center,
                  ),
                ),
                Expanded(
                  child: _buildTotalItem(
                    'Glucides',
                    '${totals.carbs}',
                    'g',
                    Colors.green,
                    Icons.grain,
                  ),
                ),
                Expanded(
                  child: _buildTotalItem(
                    'Lipides',
                    '${totals.fat}',
                    'g',
                    Colors.redAccent,
                    Icons.water_drop,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalItem(
      String label, String value, String unit, Color color, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          unit,
          style: TextStyle(
            fontSize: 12,
            color: color.withAlpha(200),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: FreshTheme.stormGray,
              ),
        ),
      ],
    );
  }

  MealTotals _calculateTotals(List<MealSuggestion> meals) {
    int totalCalories = 0;
    int totalProtein = 0;
    int totalCarbs = 0;
    int totalFat = 0;

    for (final meal in meals) {
      totalCalories += meal.calories;
      totalProtein += meal.protein;
      totalCarbs += meal.carbs;
      totalFat += meal.fat;
    }

    return MealTotals(
      calories: totalCalories,
      protein: totalProtein,
      carbs: totalCarbs,
      fat: totalFat,
    );
  }

  void _generateSimulatedMeals(UserProfile userProfile) {
    setState(() {
      _isGeneratingMeals = true;
    });

    // Simuler un délai de génération
    Future.delayed(const Duration(seconds: 2), () async {
      final targetCalories = userProfile.calculateDailyCalories();
      final mealsPerDay = 4; // Petit-déjeuner, Déjeuner, Collation, Dîner
      final caloriesPerMeal = (targetCalories / mealsPerDay).round();
      final indulgence = _indulgenceLevel; // 0 healthy -> 1 gourmand
      int carbsBalanced(int base) => (base * (1 - 0.15 * indulgence)).round();
      int fatBalanced(int base) => (base * (1 + 0.3 * indulgence)).round();
      int proteinBalanced(int base) => (base * (1 - 0.1 * indulgence)).round();

      if (_selectedPlanType == PlanType.daily) {
        _dailyMeals = [
          MealSuggestion(
            mealType: 'Petit-déjeuner',
            name: indulgence < 0.5
                ? 'Porridge aux fruits'
                : 'Pain perdu léger au yaourt',
            description: indulgence < 0.5
                ? 'Flocons d\'avoine, banane, myrtilles et amandes'
                : 'Tranches dorées, yaourt nature, sirop d\'érable léger',
            calories: caloriesPerMeal,
            protein: proteinBalanced(15),
            carbs: carbsBalanced(60),
            fat: fatBalanced(12),
            cookingTime: 10,
          ),
          MealSuggestion(
            mealType: 'Déjeuner',
            name: indulgence < 0.5
                ? 'Salade de poulet grillé'
                : 'Pâtes crémeuses au poulet',
            description: indulgence < 0.5
                ? 'Poulet, quinoa, légumes verts, vinaigrette légère'
                : 'Poulet, pâtes al dente, crème légère, champignons',
            calories: caloriesPerMeal + 100,
            protein: proteinBalanced(35),
            carbs: carbsBalanced(40),
            fat: fatBalanced(15),
            cookingTime: 20,
          ),
          MealSuggestion(
            mealType: 'Collation',
            name: indulgence < 0.5
                ? 'Yaourt grec et noix'
                : 'Carré de chocolat + yaourt',
            description: indulgence < 0.5
                ? 'Yaourt nature, noix mélangées, miel'
                : 'Yaourt nature et un petit carré de chocolat noir',
            calories: caloriesPerMeal - 150,
            protein: proteinBalanced(12),
            carbs: carbsBalanced(20),
            fat: fatBalanced(8),
            cookingTime: 5,
          ),
          MealSuggestion(
            mealType: 'Dîner',
            name: indulgence < 0.5
                ? 'Saumon aux légumes'
                : 'Burger maison équilibré',
            description: indulgence < 0.5
                ? 'Saumon grillé, brocoli, patates douces'
                : 'Steak haché maison, bun complet, légumes, sauce légère',
            calories: caloriesPerMeal + 50,
            protein: proteinBalanced(30),
            carbs: carbsBalanced(35),
            fat: fatBalanced(18),
            cookingTime: 25,
          ),
        ];
      } else {
        // Générer une semaine complète avec dates exactes et calories ajustées
        await _generateWeeklyMealsWithDates(userProfile, targetCalories,
            indulgence, proteinBalanced, carbsBalanced, fatBalanced);
      }

      setState(() {
        _isGeneratingMeals = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Plan de repas généré (mode simulation)'),
          backgroundColor: Colors.orange,
        ),
      );
    });
  }

  Future<void> _generateWeeklyMealsWithDates(
    UserProfile userProfile,
    double targetCalories,
    double indulgence,
    int Function(int) proteinBalanced,
    int Function(int) carbsBalanced,
    int Function(int) fatBalanced,
  ) async {
    _weeklyMeals = {};

    // Générer les 7 prochains jours avec dates exactes
    final now = DateTime.now();

    // Variété basée sur le niveau de cuisine
    final cookingLevel = userProfile.mealPlanningPreferences.cookingLevel;
    final isBeginner = cookingLevel == CookingLevel.beginner;
    final isAdvanced = cookingLevel == CookingLevel.advanced ||
        cookingLevel == CookingLevel.expert;

    for (int i = 0; i < 7; i++) {
      final date = now.add(Duration(days: i));
      final dayName = _getDayName(date.weekday);
      final dateString = date.toIso8601String().split('T').first;

      // Obtenir les repas déjà consommés pour ce jour spécifique
      final consumedForDay = await _getConsumedMealsForDate(dateString);
      final consumedCalories = (consumedForDay['calories'] ?? 0).toDouble();
      final consumedMealTypes =
          List<String>.from(consumedForDay['mealTypes'] ?? []);

      // Calculer les calories restantes pour ce jour spécifique
      final remainingCalories = targetCalories - consumedCalories;

      // Déterminer quels repas sont nécessaires selon le profil utilisateur pour ce jour
      final requiredMeals = _determineRequiredMealsForDay(userProfile, consumedMealTypes);

      print(
          '📅 $dayName $dateString: ${remainingCalories.round()} kcal restantes, repas requis: ${requiredMeals.join(', ')}');

      // Répartir les calories entre les repas requis
      if (requiredMeals.isNotEmpty && remainingCalories > 0) {
        final caloriesPerMeal =
            (remainingCalories / requiredMeals.length).round();

        _weeklyMeals[dayName] = requiredMeals.map((mealType) {
          return _generateVariedMealForDay(
            mealType,
            caloriesPerMeal,
            indulgence,
            proteinBalanced,
            carbsBalanced,
            fatBalanced,
            dayName,
            i,
            isBeginner,
            isAdvanced,
          );
        }).toList();
      } else {
        // Si pas de calories restantes ou pas de repas manquants, générer un plan complet
        final completeMealPlan = _generateCompleteMealPlan(
          userProfile, targetCalories, indulgence, proteinBalanced, carbsBalanced, fatBalanced, dayName, i, isBeginner, isAdvanced);
        _weeklyMeals[dayName] = completeMealPlan;
      }
    }
  }

  MealSuggestion _generateVariedMealForDay(
    String mealType,
    int calories,
    double indulgence,
    int Function(int) proteinBalanced,
    int Function(int) carbsBalanced,
    int Function(int) fatBalanced,
    String dayName,
    int dayIndex,
    bool isBeginner,
    bool isAdvanced,
  ) {
    // Variété basée sur le jour de la semaine et le niveau de cuisine
    final dayVariation = dayIndex % 5; // 5 variations différentes
    final mealVariation = _getMealVariation(mealType, dayVariation, indulgence, isBeginner, isAdvanced);

    return MealSuggestion(
      mealType: mealType,
      name: mealVariation['name']!,
      description: mealVariation['description']!,
      calories: calories,
      protein: proteinBalanced(mealVariation['protein_base']!),
      carbs: carbsBalanced(mealVariation['carbs_base']!),
      fat: fatBalanced(mealVariation['fat_base']!),
      cookingTime: mealVariation['cooking_time']!,
    );
  }

  Map<String, dynamic> _getMealVariation(String mealType, int dayVariation, double indulgence, bool isBeginner, bool isAdvanced) {
    final variations = {
      'Petit-déjeuner': {
        0: {
          'name': indulgence < 0.5
              ? (isBeginner ? 'Porridge aux fruits rouges' : 'Smoothie bowl aux baies')
              : (isBeginner ? 'Pain grillé à l\'avocat' : 'Pancakes à la banane'),
          'description': indulgence < 0.5
              ? (isBeginner ? 'Flocons d\'avoine, myrtilles et graines de chia'
                  : 'Smoothie vert avec épinards, banane et fruits rouges')
              : (isBeginner ? 'Pain complet, avocat frais et œuf poché'
                  : 'Pancakes légers avec banane et sirop d\'érable'),
          'protein_base': indulgence < 0.5 ? 12 : 18,
          'carbs_base': indulgence < 0.5 ? 55 : 65,
          'fat_base': indulgence < 0.5 ? 8 : 12,
          'cooking_time': indulgence < 0.5 ? (isBeginner ? 5 : 8) : (isBeginner ? 10 : 15),
        },
        1: {
          'name': indulgence < 0.5
              ? (isBeginner ? 'Yaourt grec aux fruits' : 'Chia pudding aux fruits tropicaux')
              : (isBeginner ? 'Croissant aux amandes' : 'French toast aux fruits'),
          'description': indulgence < 0.5
              ? (isBeginner ? 'Yaourt nature, grenade et miel'
                  : 'Graines de chia, lait de coco, mangue et passion')
              : (isBeginner ? 'Croissant, amandes effilées et café'
                  : 'Pain perdu, fruits frais et crème légère'),
          'protein_base': indulgence < 0.5 ? 18 : 15,
          'carbs_base': indulgence < 0.5 ? 35 : 70,
          'fat_base': indulgence < 0.5 ? 5 : 20,
          'cooking_time': indulgence < 0.5 ? 2 : 12,
        },
        2: {
          'name': indulgence < 0.5
              ? (isBeginner ? 'Compote de pommes' : 'Salade de fruits frais')
              : (isBeginner ? 'Pain au chocolat' : 'Crêpes aux fruits rouges'),
          'description': indulgence < 0.5
              ? (isBeginner ? 'Pommes au four avec cannelle'
                  : 'Mélange de fruits de saison avec fromage blanc')
              : (isBeginner ? 'Pain au chocolat et café au lait'
                  : 'Crêpes fines, fruits rouges et chantilly légère'),
          'protein_base': indulgence < 0.5 ? 8 : 12,
          'carbs_base': indulgence < 0.5 ? 45 : 75,
          'fat_base': indulgence < 0.5 ? 3 : 18,
          'cooking_time': indulgence < 0.5 ? 20 : 25,
        },
        3: {
          'name': indulgence < 0.5
              ? (isBeginner ? 'Muesli maison' : 'Buddha bowl petit-déjeuner')
              : (isBeginner ? 'Pain perdu' : 'Omelette aux légumes'),
          'description': indulgence < 0.5
              ? (isBeginner ? 'Flocons d\'avoine, fruits secs et lait'
                  : 'Quinoa, avocat, œuf et légumes croquants')
              : (isBeginner ? 'Pain trempé dans œuf et lait'
                  : 'Omelette aux légumes et fromage de chèvre'),
          'protein_base': indulgence < 0.5 ? 14 : 22,
          'carbs_base': indulgence < 0.5 ? 50 : 40,
          'fat_base': indulgence < 0.5 ? 10 : 25,
          'cooking_time': indulgence < 0.5 ? 5 : 15,
        },
        4: {
          'name': indulgence < 0.5
              ? (isBeginner ? 'Fruits frais au yaourt' : 'Overnight oats aux graines')
              : (isBeginner ? 'Brioche au sucre' : 'Frittata aux légumes'),
          'description': indulgence < 0.5
              ? (isBeginner ? 'Yaourt nature avec fruits frais'
                  : 'Avoine préparée la veille avec graines et fruits')
              : (isBeginner ? 'Brioche fraîche avec beurre'
                  : 'Omelette cuite au four avec légumes et herbes'),
          'protein_base': indulgence < 0.5 ? 16 : 20,
          'carbs_base': indulgence < 0.5 ? 40 : 55,
          'fat_base': indulgence < 0.5 ? 6 : 22,
          'cooking_time': indulgence < 0.5 ? 5 : 20,
        },
      },
      'Déjeuner': {
        0: {
          'name': indulgence < 0.5
              ? (isBeginner ? 'Salade composée' : 'Poké bowl au saumon')
              : (isBeginner ? 'Quiche aux légumes' : 'Burger maison équilibré'),
          'description': indulgence < 0.5
              ? (isBeginner ? 'Mélange de légumes verts avec vinaigrette légère'
                  : 'Saumon frais, riz vinaigré, avocat et légumes croquants')
              : (isBeginner ? 'Quiche aux légumes et fromage'
                  : 'Bun complet, steak haché maison, légumes grillés'),
          'protein_base': indulgence < 0.5 ? 25 : 35,
          'carbs_base': indulgence < 0.5 ? 35 : 50,
          'fat_base': indulgence < 0.5 ? 12 : 22,
          'cooking_time': indulgence < 0.5 ? 10 : (isBeginner ? 45 : 25),
        },
        1: {
          'name': indulgence < 0.5
              ? (isBeginner ? 'Soupe de légumes' : 'Risotto aux champignons')
              : (isBeginner ? 'Pizza aux légumes' : 'Pâtes à la carbonara légère'),
          'description': indulgence < 0.5
              ? (isBeginner ? 'Légumes de saison mixés'
                  : 'Riz arborio, champignons sauvages et parmesan')
              : (isBeginner ? 'Pâte à pizza, légumes grillés et mozzarella'
                  : 'Spaghetti, pancetta, œuf et pecorino'),
          'protein_base': indulgence < 0.5 ? 18 : 28,
          'carbs_base': indulgence < 0.5 ? 45 : 65,
          'fat_base': indulgence < 0.5 ? 8 : 25,
          'cooking_time': indulgence < 0.5 ? 20 : (isBeginner ? 25 : 30),
        },
        2: {
          'name': indulgence < 0.5
              ? (isBeginner ? 'Sandwich au poulet' : 'Wrap au thon et légumes')
              : (isBeginner ? 'Tarte salée' : 'Lasagnes végétariennes'),
          'description': indulgence < 0.5
              ? (isBeginner ? 'Poulet grillé, salade et pain complet'
                  : 'Thon au naturel, crudités et tortilla de blé')
              : (isBeginner ? 'Pâte brisée, légumes et fromage'
                  : 'Feuilles de lasagnes, légumes grillés et béchamel légère'),
          'protein_base': indulgence < 0.5 ? 32 : 26,
          'carbs_base': indulgence < 0.5 ? 40 : 55,
          'fat_base': indulgence < 0.5 ? 15 : 20,
          'cooking_time': indulgence < 0.5 ? 5 : (isBeginner ? 50 : 35),
        },
        3: {
          'name': indulgence < 0.5
              ? (isBeginner ? 'Taboulé' : 'Couscous aux légumes')
              : (isBeginner ? 'Gratin de légumes' : 'Boeuf bourguignon allégé'),
          'description': indulgence < 0.5
              ? (isBeginner ? 'Semoule, tomates et herbes'
                  : 'Semoule de couscous, légumes d\'été et pois chiches')
              : (isBeginner ? 'Légumes au four avec fromage'
                  : 'Boeuf mijoté avec carottes et pommes de terre'),
          'protein_base': indulgence < 0.5 ? 20 : 38,
          'carbs_base': indulgence < 0.5 ? 50 : 45,
          'fat_base': indulgence < 0.5 ? 10 : 18,
          'cooking_time': indulgence < 0.5 ? 15 : (isBeginner ? 40 : 120),
        },
        4: {
          'name': indulgence < 0.5
              ? (isBeginner ? 'Riz aux légumes' : 'Sushi bowl maison')
              : (isBeginner ? 'Croque monsieur' : 'Chili con carne léger'),
          'description': indulgence < 0.5
              ? (isBeginner ? 'Riz complet et légumes vapeur'
                  : 'Riz vinaigré, légumes crus et sauce soja légère')
              : (isBeginner ? 'Pain de mie, jambon et fromage'
                  : 'Boeuf haché, haricots rouges et tomates'),
          'protein_base': indulgence < 0.5 ? 22 : 35,
          'carbs_base': indulgence < 0.5 ? 55 : 50,
          'fat_base': indulgence < 0.5 ? 8 : 20,
          'cooking_time': indulgence < 0.5 ? 15 : (isBeginner ? 15 : 45),
        },
      },
      'Collation': {
        0: {
          'name': indulgence < 0.5
              ? (isBeginner ? 'Yaourt grec aux fruits' : 'Smoothie aux baies')
              : (isBeginner ? 'Carré de chocolat' : 'Tiramisu minute'),
          'description': indulgence < 0.5
              ? (isBeginner ? 'Yaourt nature, myrtilles et graines de chia'
                  : 'Banane, baies mélangées et yaourt grec')
              : (isBeginner ? 'Chocolat noir et café'
                  : 'Café, mascarpone et biscuits au cacao'),
          'protein_base': indulgence < 0.5 ? 12 : 8,
          'carbs_base': indulgence < 0.5 ? 25 : 35,
          'fat_base': indulgence < 0.5 ? 5 : 12,
          'cooking_time': indulgence < 0.5 ? 2 : 5,
        },
        1: {
          'name': indulgence < 0.5
              ? (isBeginner ? 'Pomme au fromage blanc' : 'Chia pudding aux fruits')
              : (isBeginner ? 'Pain d\'épices' : 'Crème brûlée express'),
          'description': indulgence < 0.5
              ? (isBeginner ? 'Pomme fraîche avec fromage blanc 0%'
                  : 'Graines de chia, lait d\'amande et mangue')
              : (isBeginner ? 'Pain d\'épices traditionnel'
                  : 'Crème anglaise, sucre caramélisé et fruits rouges'),
          'protein_base': indulgence < 0.5 ? 8 : 6,
          'carbs_base': indulgence < 0.5 ? 30 : 45,
          'fat_base': indulgence < 0.5 ? 2 : 15,
          'cooking_time': indulgence < 0.5 ? 2 : 10,
        },
        2: {
          'name': indulgence < 0.5
              ? (isBeginner ? 'Mix de noix et fruits secs' : 'Avocat sur toast complet')
              : (isBeginner ? 'Barre chocolatée' : 'Macarons maison'),
          'description': indulgence < 0.5
              ? (isBeginner ? 'Amandes, noix et raisins secs'
                  : 'Pain complet, avocat frais et graines de sésame')
              : (isBeginner ? 'Chocolat au lait et noisettes'
                  : 'Coquilles meringuées, crème et confiture de framboises'),
          'protein_base': indulgence < 0.5 ? 10 : 8,
          'carbs_base': indulgence < 0.5 ? 20 : 40,
          'fat_base': indulgence < 0.5 ? 18 : 25,
          'cooking_time': indulgence < 0.5 ? 0 : 15,
        },
        3: {
          'name': indulgence < 0.5
              ? (isBeginner ? 'Banane au beurre d\'arachide' : 'Salade de fruits frais')
              : (isBeginner ? 'Cookies aux pépites' : 'Tarte au citron meringuée'),
          'description': indulgence < 0.5
              ? (isBeginner ? 'Banane bio avec beurre d\'arachide naturel'
                  : 'Mélange de fruits de saison avec jus de citron')
              : (isBeginner ? 'Pâte sablée, chocolat et beurre'
                  : 'Pâte sucrée, crème au citron et meringue italienne'),
          'protein_base': indulgence < 0.5 ? 8 : 6,
          'carbs_base': indulgence < 0.5 ? 35 : 50,
          'fat_base': indulgence < 0.5 ? 12 : 20,
          'cooking_time': indulgence < 0.5 ? 2 : 45,
        },
        4: {
          'name': indulgence < 0.5
              ? (isBeginner ? 'Compote de pommes maison' : 'Overnight oats aux graines')
              : (isBeginner ? 'Muffin aux myrtilles' : 'Éclair au chocolat'),
          'description': indulgence < 0.5
              ? (isBeginner ? 'Pommes au four avec cannelle'
                  : 'Avoine préparée la veille avec graines et fruits')
              : (isBeginner ? 'Pâte à muffin, myrtilles et sucre'
                  : 'Pâte à choux, crème pâtissière et glaçage au chocolat'),
          'protein_base': indulgence < 0.5 ? 6 : 8,
          'carbs_base': indulgence < 0.5 ? 40 : 55,
          'fat_base': indulgence < 0.5 ? 3 : 22,
          'cooking_time': indulgence < 0.5 ? 30 : 60,
        },
      },
      'Dîner': {
        0: {
          'name': indulgence < 0.5
              ? (isBeginner ? 'Poisson aux légumes' : 'Papillote de saumon')
              : (isBeginner ? 'Escalope de veau' : 'Magret de canard aux fruits'),
          'description': indulgence < 0.5
              ? (isBeginner ? 'Cabillaud vapeur avec brocolis'
                  : 'Saumon en papillote avec légumes et herbes')
              : (isBeginner ? 'Escalope panée avec purée'
                  : 'Magret saisi avec compote de pommes et miel'),
          'protein_base': indulgence < 0.5 ? 35 : 40,
          'carbs_base': indulgence < 0.5 ? 25 : 35,
          'fat_base': indulgence < 0.5 ? 12 : 28,
          'cooking_time': indulgence < 0.5 ? 15 : (isBeginner ? 20 : 30),
        },
        1: {
          'name': indulgence < 0.5
              ? (isBeginner ? 'Légumes grillés' : 'Ratatouille provençale')
              : (isBeginner ? 'Steak frites' : 'Boeuf Wellington simplifié'),
          'description': indulgence < 0.5
              ? (isBeginner ? 'Assortiment de légumes au four'
                  : 'Aubergines, courgettes, tomates et herbes')
              : (isBeginner ? 'Steak grillé avec frites maison'
                  : 'Boeuf en croûte de champignons et légumes'),
          'protein_base': indulgence < 0.5 ? 15 : 45,
          'carbs_base': indulgence < 0.5 ? 30 : 40,
          'fat_base': indulgence < 0.5 ? 8 : 30,
          'cooking_time': indulgence < 0.5 ? 20 : (isBeginner ? 25 : 60),
        },
        2: {
          'name': indulgence < 0.5
              ? (isBeginner ? 'Omelette aux légumes' : 'Tian de légumes')
              : (isBeginner ? 'Poulet rôti' : 'Coq au vin léger'),
          'description': indulgence < 0.5
              ? (isBeginner ? 'Oeufs battus avec légumes frais'
                  : 'Légumes en gratin avec œuf et fromage')
              : (isBeginner ? 'Poulet aux herbes avec pommes de terre'
                  : 'Poulet mijoté au vin rouge avec champignons'),
          'protein_base': indulgence < 0.5 ? 28 : 42,
          'carbs_base': indulgence < 0.5 ? 20 : 30,
          'fat_base': indulgence < 0.5 ? 18 : 25,
          'cooking_time': indulgence < 0.5 ? 10 : (isBeginner ? 45 : 90),
        },
        3: {
          'name': indulgence < 0.5
              ? (isBeginner ? 'Soupe de poisson' : 'Bouillabaisse légère')
              : (isBeginner ? 'Sauté de porc' : 'Filet mignon aux morilles'),
          'description': indulgence < 0.5
              ? (isBeginner ? 'Soupe de légumes au poisson'
                  : 'Soupe de poissons méditerranéenne')
              : (isBeginner ? 'Porc émincé aux légumes'
                  : 'Filet de porc aux champignons sauvages'),
          'protein_base': indulgence < 0.5 ? 32 : 45,
          'carbs_base': indulgence < 0.5 ? 25 : 35,
          'fat_base': indulgence < 0.5 ? 15 : 28,
          'cooking_time': indulgence < 0.5 ? 20 : (isBeginner ? 25 : 45),
        },
        4: {
          'name': indulgence < 0.5
              ? (isBeginner ? 'Salade de quinoa' : 'Taboulé libanais')
              : (isBeginner ? 'Agneau grillé' : 'Carré d\'agneau rôti'),
          'description': indulgence < 0.5
              ? (isBeginner ? 'Quinoa, tomates et concombres'
                  : 'Semoule fine, légumes frais et menthe')
              : (isBeginner ? 'Côtes d\'agneau grillées'
                  : 'Carré d\'agneau avec ratatouille'),
          'protein_base': indulgence < 0.5 ? 22 : 40,
          'carbs_base': indulgence < 0.5 ? 45 : 35,
          'fat_base': indulgence < 0.5 ? 12 : 32,
          'cooking_time': indulgence < 0.5 ? 15 : (isBeginner ? 15 : 50),
        },
      },
    };

    final mealVariations = variations[mealType] ?? variations['Déjeuner']!;
    return mealVariations[dayVariation] ?? mealVariations[0]!;
  }

  Future<List<MealSuggestion>> _generateGPTMeals(
      UserProfile userProfile, Map<String, dynamic> consumedToday) async {
    final chatService = NutritionChatService();

    // Calculer les besoins nutritionnels
    final targetCalories = userProfile.calculateDailyCalories();
    final remainingCalories = targetCalories - (consumedToday['calories'] ?? 0);
    final consumedMealTypes =
        List<String>.from(consumedToday['mealTypes'] ?? []);

    // Déterminer quels repas sont nécessaires selon le profil utilisateur
    final requiredMeals = _determineRequiredMeals(userProfile, consumedMealTypes, consumedToday);

    print(
        '🎯 Profil ${userProfile.name}: ${remainingCalories.round()} kcal restantes');
    print('📊 Calories totales: ${targetCalories.round()} kcal');
    print('📊 Calories consommées: ${consumedToday['calories']} kcal');
    print('🍽️ Repas requis: ${requiredMeals.join(', ')}');

    // Créer un prompt personnalisé intelligent
    final prompt = _buildIntelligentMealPrompt(
        userProfile, remainingCalories, requiredMeals);

    // Appeler GPT
    final messages = [
      {'role': 'user', 'content': prompt}
    ];
    final response = await chatService.getAnswer(messages);

    // Parser la réponse en JSON
    return _parseGPTResponse(response, requiredMeals);
  }

  List<String> _determineRequiredMeals(UserProfile userProfile, List<String> consumedMealTypes, Map<String, dynamic> consumedToday) {
    final allMealTypes = ['Petit-déjeuner', 'Déjeuner', 'Collation', 'Dîner'];
    final missingMeals = allMealTypes.where((meal) => !consumedMealTypes.contains(meal)).toList();

    // Toujours inclure des encas pour certains profils
    final needsSnacks = _userNeedsSnacks(userProfile);

    print('🏃 Profil utilisateur analyse:');
    print('  - Niveau d\'activité: ${userProfile.activityLevel}');
    print('  - Objectif: ${userProfile.weightGoal}');
    print('  - Activités sportives: ${userProfile.sportActivities.length}');
    print('  - A besoin d\'encas: $needsSnacks');

    if (needsSnacks) {
      // Ajouter 'Collation' si elle n'est pas déjà dans les repas manquants
      if (!missingMeals.contains('Collation') && !consumedMealTypes.contains('Collation')) {
        missingMeals.add('Collation');
        print('  ✅ Encas ajouté automatiquement');
      }

      // Pour les sportifs très actifs, ajouter un deuxième encas
      if (_isExtremelyActive(userProfile) && !missingMeals.contains('Collation')) {
        // Logique pour deuxième encas si nécessaire
        print('  💪 Profil extrêmement actif - encas supplémentaire recommandé');
      }
    }

    return missingMeals;
  }

  bool _userNeedsSnacks(UserProfile userProfile) {
    // Critères pour avoir besoin d'encas :
    // 1. Niveau d'activité très élevé
    // 2. Objectif de prise de poids
    // 3. Activités sportives intenses

    final isVeryActive = userProfile.activityLevel == ActivityLevel.veryActive ||
                        userProfile.activityLevel == ActivityLevel.extremelyActive;

    final wantsToGainWeight = userProfile.weightGoal == WeightGoal.gain;

    final hasIntenseSports = userProfile.sportActivities.any((sport) =>
      sport.intensity == SportIntensity.high ||
      sport.intensity == SportIntensity.extreme
    );

    return isVeryActive || wantsToGainWeight || hasIntenseSports;
  }

  bool _isExtremelyActive(UserProfile userProfile) {
    final isExtremelyActive = userProfile.activityLevel == ActivityLevel.extremelyActive;

    final hasExtremeSports = userProfile.sportActivities.any((sport) =>
      sport.intensity == SportIntensity.extreme
    );

    final highWeeklySports = userProfile.sportActivities.fold<int>(0, (sum, sport) => sum + sport.sessionsPerWeek) >= 10;

    return isExtremelyActive || hasExtremeSports || highWeeklySports;
  }

  List<String> _determineRequiredMealsForDay(UserProfile userProfile, List<String> consumedMealTypes) {
    final allMealTypes = ['Petit-déjeuner', 'Déjeuner', 'Dîner'];
    final missingMeals = allMealTypes.where((meal) => !consumedMealTypes.contains(meal)).toList();

    // Toujours inclure des encas pour certains profils
    final needsSnacks = _userNeedsSnacks(userProfile);

    if (needsSnacks) {
      // Ajouter 'Collation' si elle n'est pas déjà dans les repas manquants
      if (!missingMeals.contains('Collation') && !consumedMealTypes.contains('Collation')) {
        missingMeals.add('Collation');
      }
    }

    return missingMeals;
  }

  List<MealSuggestion> _generateCompleteMealPlan(
    UserProfile userProfile,
    double targetCalories,
    double indulgence,
    int Function(int) proteinBalanced,
    int Function(int) carbsBalanced,
    int Function(int) fatBalanced,
    String dayName,
    int dayIndex,
    bool isBeginner,
    bool isAdvanced,
  ) {
    // Déterminer quels repas inclure selon le profil
    final needsSnacks = _userNeedsSnacks(userProfile);
    final baseMeals = ['Petit-déjeuner', 'Déjeuner', 'Dîner'];
    final allMeals = needsSnacks ? [...baseMeals, 'Collation'] : baseMeals;

    final caloriesPerMeal = (targetCalories / allMeals.length).round();

    return allMeals.map((mealType) {
      return _generateVariedMealForDay(
        mealType,
        caloriesPerMeal,
        indulgence,
        proteinBalanced,
        carbsBalanced,
        fatBalanced,
        dayName,
        dayIndex,
        isBeginner,
        isAdvanced,
      );
    }).toList();
  }

  String _buildIntelligentMealPrompt(UserProfile userProfile,
      double remainingCalories, List<String> missingMeals) {
    final indulgenceText = _indulgenceLevel < 0.3
        ? "très sains et équilibrés"
        : _indulgenceLevel > 0.7
            ? "plus gourmands et savoureux"
            : "équilibrés avec du plaisir";

    return """
Génère un plan de repas français personnalisé en JSON pour ce profil utilisateur :

PROFIL UTILISATEUR COMPLET :
- Nom : ${userProfile.name ?? 'Utilisateur'}
- Âge : ${userProfile.age} ans
- Poids : ${userProfile.weightKg} kg
- Taille : ${userProfile.heightCm} cm
- Sexe : ${userProfile.gender == Gender.male ? 'Homme' : userProfile.gender == Gender.female ? 'Femme' : 'Autre'}
- Niveau d'activité : ${_getActivityLevelText(userProfile.activityLevel)}
- Objectif : ${_getWeightGoalText(userProfile.weightGoal)}
- Objectif vitesse : ${userProfile.weightGoalKgPerWeek} kg/semaine
- IMC : ${(userProfile.weightKg / ((userProfile.heightCm / 100) * (userProfile.heightCm / 100))).toStringAsFixed(1)}

PRÉFÉRENCES ALIMENTAIRES :
- Allergies : ${userProfile.dietaryPreferences.allergies.isEmpty ? 'Aucune' : userProfile.dietaryPreferences.allergies.join(', ')}
- Restrictions : ${_getDietaryRestrictions(userProfile.dietaryPreferences)}
- Jeûne intermittent : ${_getFastingText(userProfile.fastingSchedule)}

PRÉFÉRENCES CULINAIRES :
- Niveau de cuisine : ${_getCookingLevelText(userProfile.mealPlanningPreferences.cookingLevel)}
- Temps de cuisine semaine : ${_getCookingTimeText(userProfile.mealPlanningPreferences.weekdayCookingTime)}
- Temps de cuisine weekend : ${_getCookingTimeText(userProfile.mealPlanningPreferences.weekendCookingTime)}
- Budget alimentaire : ${_getBudgetText(userProfile.mealPlanningPreferences.weeklyBudget)}

ACTIVITÉS SPORTIVES :
${_getSportActivitiesText(userProfile.sportActivities)}

CONTRAINTES :
- Calories restantes : ${remainingCalories.round()} kcal
- Repas manquants : ${missingMeals.join(', ')}
- Style souhaité : $indulgenceText

INSTRUCTIONS STRICTES :
1. UTILISE TOUTES les ${remainingCalories.round()} kcal restantes pour les repas manquants
2. Génère UNIQUEMENT les repas manquants : ${missingMeals.join(', ')}
3. Répartis intelligemment les ${remainingCalories.round()} kcal entre ces repas
4. Adapte les portions pour atteindre exactement l'objectif calorique
5. RESPECTE ABSOLUMENT le profil complet de l'utilisateur :
   - Âge ${userProfile.age} ans et sexe ${userProfile.gender == Gender.male ? 'Homme' : 'Femme'} pour les besoins nutritionnels
   - Objectif ${_getWeightGoalText(userProfile.weightGoal)} à ${userProfile.weightGoalKgPerWeek} kg/semaine
   - Niveau d'activité ${_getActivityLevelText(userProfile.activityLevel)}
   - Activités sportives pour adapter les protéines et glucides
6. ADAPTE aux préférences culinaires :
   - Niveau ${_getCookingLevelText(userProfile.mealPlanningPreferences.cookingLevel)}
   - Temps disponible : ${_getCookingTimeText(userProfile.mealPlanningPreferences.weekdayCookingTime)} en semaine
   - Budget ${_getBudgetText(userProfile.mealPlanningPreferences.weeklyBudget)}
7. RESPECTE le jeûne intermittent : ${_getFastingText(userProfile.fastingSchedule)}
8. Évite absolument : ${userProfile.dietaryPreferences.allergies.join(', ')}
9. Respecte les restrictions : ${_getDietaryRestrictions(userProfile.dietaryPreferences)}
10. Utilise des ingrédients français et de saison

EXEMPLE DE RÉPARTITION :
Si ${remainingCalories.round()} kcal pour ${missingMeals.join(' + ')}, répartis comme :
${_getCalorieDistributionExample(remainingCalories.round(), missingMeals)}

RÉPONSE ATTENDUE (JSON strict) :
[
  {
    "name": "Nom du plat",
    "mealType": "Petit-déjeuner|Déjeuner|Collation|Dîner",
    "description": "Description courte",
    "calories": 000,
    "protein": 00,
    "carbs": 00,
    "fat": 00,
    "cookingTime": 00
  }
]

Génère maintenant le plan optimal pour ce profil !
""";
  }

  List<MealSuggestion> _parseGPTResponse(
      String response, List<String> expectedMeals) {
    try {
      // Nettoyer la réponse pour extraire le JSON
      final jsonStart = response.indexOf('[');
      final jsonEnd = response.lastIndexOf(']') + 1;

      if (jsonStart == -1 || jsonEnd == 0) {
        throw Exception('Format JSON non trouvé dans la réponse');
      }

      final jsonString = response.substring(jsonStart, jsonEnd);
      final List<dynamic> mealsData = jsonDecode(jsonString);

      return mealsData.map((mealJson) {
        return MealSuggestion(
          name: mealJson['name'] ?? 'Repas personnalisé',
          mealType: mealJson['mealType'] ?? expectedMeals.first,
          description:
              mealJson['description'] ?? 'Repas équilibré et savoureux',
          calories: (mealJson['calories'] ?? 300).toInt(),
          protein: (mealJson['protein'] ?? 15).toInt(),
          carbs: (mealJson['carbs'] ?? 40).toInt(),
          fat: (mealJson['fat'] ?? 10).toInt(),
          cookingTime: (mealJson['cookingTime'] ?? 20).toInt(),
        );
      }).toList();
    } catch (e) {
      print('❌ Erreur parsing GPT: $e');
      // Fallback avec des repas par défaut
      return _generateFallbackMeals(expectedMeals);
    }
  }

  List<MealSuggestion> _generateFallbackMeals(List<String> missingMeals) {
    final fallbackMeals = <MealSuggestion>[];

    for (final mealType in missingMeals) {
      switch (mealType) {
        case 'Petit-déjeuner':
          fallbackMeals.add(MealSuggestion(
            name: 'Petit-déjeuner équilibré',
            mealType: 'Petit-déjeuner',
            description: 'Avoine complète avec fruits frais et yaourt grec',
            calories: 350,
            protein: 15,
            carbs: 45,
            fat: 12,
            cookingTime: 5,
          ));
          break;
        case 'Déjeuner':
          fallbackMeals.add(MealSuggestion(
            name: 'Déjeuner santé',
            mealType: 'Déjeuner',
            description: 'Quinoa aux légumes de saison et protéine au choix',
            calories: 500,
            protein: 30,
            carbs: 55,
            fat: 18,
            cookingTime: 25,
          ));
          break;
        case 'Collation':
          fallbackMeals.add(MealSuggestion(
            name: 'Collation énergétique',
            mealType: 'Collation',
            description: 'Mix de fruits secs et amandes',
            calories: 200,
            protein: 8,
            carbs: 25,
            fat: 8,
            cookingTime: 0,
          ));
          break;
        case 'Dîner':
          fallbackMeals.add(MealSuggestion(
            name: 'Dîner léger',
            mealType: 'Dîner',
            description: 'Poisson grillé avec légumes verts et riz complet',
            calories: 400,
            protein: 25,
            carbs: 35,
            fat: 15,
            cookingTime: 20,
          ));
          break;
      }
    }

    return fallbackMeals;
  }

  String _getDietaryRestrictions(UserDietaryPreferences preferences) {
    final restrictions = <String>[];

    if (preferences.isVegetarian) restrictions.add('Végétarien');
    if (preferences.isVegan) restrictions.add('Végan');
    if (preferences.isHalal) restrictions.add('Halal');
    if (preferences.isKosher) restrictions.add('Kasher');
    if (preferences.isGlutenFree) restrictions.add('Sans gluten');
    if (preferences.isLactoseFree) restrictions.add('Sans lactose');

    return restrictions.isEmpty ? 'Aucune' : restrictions.join(', ');
  }

  String _getCalorieDistributionExample(
      int totalCalories, List<String> missingMeals) {
    if (missingMeals.isEmpty) return '';

    // Répartition standard des calories par repas
    Map<String, double> standardRatios = {
      'Petit-déjeuner': 0.25,
      'Déjeuner': 0.35,
      'Collation': 0.15,
      'Dîner': 0.25,
    };

    double totalRatio = missingMeals
        .map((meal) => standardRatios[meal] ?? 0.25)
        .reduce((a, b) => a + b);

    return missingMeals.map((meal) {
      double ratio = (standardRatios[meal] ?? 0.25) / totalRatio;
      int calories = (totalCalories * ratio).round();
      return '- $meal: ~$calories kcal';
    }).join('\n');
  }

  String _getActivityLevelText(ActivityLevel level) {
    switch (level) {
      case ActivityLevel.sedentary:
        return 'Sédentaire (travail de bureau, peu d\'exercice)';
      case ActivityLevel.lightlyActive:
        return 'Légèrement actif (exercice léger 1-3 jours/semaine)';
      case ActivityLevel.moderatelyActive:
        return 'Modérément actif (exercice modéré 3-5 jours/semaine)';
      case ActivityLevel.veryActive:
        return 'Très actif (exercice intense 6-7 jours/semaine)';
      case ActivityLevel.extremelyActive:
        return 'Extrêmement actif (exercice très intense, athlète)';
    }
  }

  String _getWeightGoalText(WeightGoal goal) {
    switch (goal) {
      case WeightGoal.lose:
        return 'Perte de poids';
      case WeightGoal.maintain:
        return 'Maintien du poids';
      case WeightGoal.gain:
        return 'Prise de poids';
      case WeightGoal.healthyEating:
        return 'Alimentation saine';
    }
  }

  String _getFastingText(IntermittentFastingSchedule schedule) {
    switch (schedule.type) {
      case IntermittentFastingType.none:
        return 'Aucun';
      case IntermittentFastingType.fasting16_8:
        return 'Jeûne 16:8 (${schedule.fastingStartTime} - ${schedule.fastingEndTime})';
      case IntermittentFastingType.fasting18_6:
        return 'Jeûne 18:6 (${schedule.fastingStartTime} - ${schedule.fastingEndTime})';
      case IntermittentFastingType.fasting20_4:
        return 'Jeûne 20:4 (${schedule.fastingStartTime} - ${schedule.fastingEndTime})';
      case IntermittentFastingType.fasting5_2:
        return 'Jeûne 5:2 (2 jours à calories réduites)';
      case IntermittentFastingType.alternateDay:
        return 'Jeûne alterné (un jour sur deux)';
      case IntermittentFastingType.custom:
        return 'Jeûne personnalisé (${schedule.fastingHours}h jeûne/${schedule.eatingHours}h repas)';
    }
  }

  String _getCookingLevelText(CookingLevel level) {
    switch (level) {
      case CookingLevel.beginner:
        return 'Débutant (repas simples)';
      case CookingLevel.intermediate:
        return 'Intermédiaire (recettes variées)';
      case CookingLevel.advanced:
        return 'Avancé (techniques maîtrisées)';
      case CookingLevel.expert:
        return 'Expert (techniques complexes)';
    }
  }

  String _getCookingTimeText(CookingTime time) {
    switch (time) {
      case CookingTime.minimal:
        return '< 15 min';
      case CookingTime.short:
        return '15-30 min';
      case CookingTime.moderate:
        return '30-60 min';
      case CookingTime.long:
        return '> 60 min';
    }
  }

  String _getBudgetText(FoodBudget budget) {
    switch (budget) {
      case FoodBudget.tight:
        return 'Serré (< 50€/semaine)';
      case FoodBudget.moderate:
        return 'Modéré (50-100€/semaine)';
      case FoodBudget.comfortable:
        return 'Confortable (100-150€/semaine)';
      case FoodBudget.generous:
        return 'Généreux (> 150€/semaine)';
    }
  }

  String _getSportActivitiesText(List<UserSportActivity> activities) {
    if (activities.isEmpty) {
      return '- Aucune activité sportive régulière déclarée';
    }

    return activities.map((activity) {
      String intensityText;
      switch (activity.intensity) {
        case SportIntensity.low:
          intensityText = 'faible';
          break;
        case SportIntensity.medium:
          intensityText = 'modérée';
          break;
        case SportIntensity.high:
          intensityText = 'élevée';
          break;
        case SportIntensity.extreme:
          intensityText = 'extrême';
          break;
      }

      return '- ${activity.name}: ${activity.sessionsPerWeek}x/semaine, ${activity.minutesPerSession}min, intensité $intensityText';
    }).join('\n');
  }
}

enum PlanType { daily, weekly }

class MealSuggestion {
  final String mealType;
  final String name;
  final String description;
  final int calories;
  final int protein;
  final int carbs;
  final int fat;
  final int? cookingTime;
  String? recipe; // Ajout pour stocker la recette

  MealSuggestion({
    required this.mealType,
    required this.name,
    required this.description,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.cookingTime,
    this.recipe,
  });

  factory MealSuggestion.fromJson(Map<String, dynamic> json) {
    return MealSuggestion(
      mealType: json['mealType'] ?? 'Repas',
      name: json['name'] ?? 'Sans nom',
      description: json['description'] ?? '',
      calories: (json['calories'] ?? 0) is int
          ? json['calories']
          : (json['calories'] ?? 0).toInt(),
      protein: (json['protein'] ?? 0) is int
          ? json['protein']
          : (json['protein'] ?? 0).toInt(),
      carbs: (json['carbs'] ?? 0) is int
          ? json['carbs']
          : (json['carbs'] ?? 0).toInt(),
      fat: (json['fat'] ?? 0) is int ? json['fat'] : (json['fat'] ?? 0).toInt(),
      cookingTime: json['cookingTime'] != null
          ? (json['cookingTime'] is int
              ? json['cookingTime']
              : (json['cookingTime']).toInt())
          : null,
      recipe: json['recipe'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mealType': mealType,
      'name': name,
      'description': description,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'cookingTime': cookingTime,
      'recipe': recipe,
    };
  }
}

class MealTotals {
  final int calories;
  final int protein;
  final int carbs;
  final int fat;

  MealTotals({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });
}
