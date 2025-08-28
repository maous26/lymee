// lib/presentation/screens/nutrition_dashboard_screen_improved_v2.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lym_nutrition/domain/entities/user_profile.dart';
import 'package:lym_nutrition/presentation/bloc/user_profile/user_profile_bloc.dart';
import 'package:lym_nutrition/presentation/bloc/user_profile/user_profile_event.dart';
import 'package:lym_nutrition/presentation/bloc/user_profile/user_profile_state.dart';
// ignore: unused_import
import 'package:lym_nutrition/presentation/screens/food_search_screen.dart';
// Removed unused import of presentation/models/gamification_models.dart
import 'package:lym_nutrition/presentation/themes/fresh_theme.dart';
import 'package:lym_nutrition/presentation/widgets/fresh_components.dart';
// Removed unused chart import
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:lym_nutrition/presentation/screens/chat/nutrition_chat_service.dart';
import 'package:lym_nutrition/core/services/gamification_service.dart';

class NutritionDashboardScreenV2 extends StatefulWidget {
  const NutritionDashboardScreenV2({Key? key}) : super(key: key);

  @override
  State<NutritionDashboardScreenV2> createState() =>
      NutritionDashboardScreenV2State();
}

class NutritionDashboardScreenV2State extends State<NutritionDashboardScreenV2>
    with
        TickerProviderStateMixin,
        WidgetsBindingObserver,
        AutomaticKeepAliveClientMixin {
  late TabController _periodTabController;
  late TabController _mealTabController;

  // Sport sessions for today
  final List<SportSession> _todaySportSessions = [];

  // Saved meal plans
  List<MealFood> _savedDailyMeals = [];
  List<MealFood> _individualMealsToday = [];



  // Gamification
  late GamificationService _gamificationService;

  // Removed deprecated mock meals store

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _periodTabController = TabController(length: 3, vsync: this);
    _mealTabController = TabController(length: 4, vsync: this);
    context.read<UserProfileBloc>().add(GetUserProfileEvent());
    _loadSavedMeals();


    _initGamification();
  }

  Future<void> _initGamification() async {
    final prefs = await SharedPreferences.getInstance();
    _gamificationService = GamificationService(prefs);
    await _gamificationService.handleDailyLogin();
    await _loadGamificationData();
  }

  Future<void> _loadGamificationData() async {
    // Gamification data loaded for future use if needed
    setState(() {});
  }

  Widget _buildShimmerLoading(BuildContext context) {
    return const SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerBox(height: 28, width: 220),
          SizedBox(height: 16),
          ShimmerBox(height: 16, width: 140),
          SizedBox(height: 24),
          // Quick stats placeholder
          ShimmerBox(height: 160, width: double.infinity, radius: 16),
          SizedBox(height: 16),
          // Macros placeholder
          ShimmerBox(height: 260, width: double.infinity, radius: 16),
          SizedBox(height: 16),
          ShimmerBox(height: 180, width: double.infinity, radius: 16),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _periodTabController.dispose();
    _mealTabController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }



  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Reload all dashboard data when app resumes
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          refreshDashboardData();
        }
      });
    }
  }

  Future<void> _loadSavedMeals() async {
    final prefs = await SharedPreferences.getInstance();

    // Clean up old date formats first
    final dailyMealsDate = prefs.getString('saved_daily_meals_date');
    if (dailyMealsDate != null && dailyMealsDate.contains('T')) {
      // Convert old timestamp format to date-only format
      final cleanDate = dailyMealsDate.split('T').first;
      await prefs.setString('saved_daily_meals_date', cleanDate);
      print('🧹 Cleaned up old date format: $dailyMealsDate -> $cleanDate');
    }

    // Load meals from Journal data source (same as Journal screen)
    final todayKey = DateTime.now().toIso8601String().split('T').first;
    final journalDataJson = prefs.getString('journal_$todayKey');
    final allMeals = <MealFood>[];

    print('📅 Dashboard - Loading from journal_$todayKey');

    // Load from journal data (includes both AI generated and manual meals)
    if (journalDataJson != null) {
      try {
        final journalData = jsonDecode(journalDataJson) as Map<String, dynamic>;
        final meals = (journalData['meals'] as List? ?? []);
        print('✅ Dashboard - Loading ${meals.length} meals from journal');
        for (final mealJson in meals) {
          allMeals
              .add(MealFood.fromSavedMeal(mealJson as Map<String, dynamic>));
        }
      } catch (e) {
        print('❌ Dashboard - Error loading journal meals: $e');
      }
    }

    // Note: Individual meals are now included in journal data, so no need for separate loading
    // Removed duplicate loading from individual_meals_$todayKey to prevent double counting

    setState(() {
      _savedDailyMeals = allMeals;
    });

    // Weekly meals not used currently; keeping daily for simplicity

    // Load sport sessions from the same journal data
    if (journalDataJson != null) {
      try {
        final journalData = jsonDecode(journalDataJson) as Map<String, dynamic>;
        final allSports = (journalData['sports'] as List? ?? [])
            .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e))
            .toList();

        // Filter out auto-generated generic sessions
        final sports = allSports.where((s) {
          final type = (s['type'] ?? '').toString();
          final text = (s['text'] ?? '').toString();
          // Remove generic "Séance" or auto-generated workout plans
          return !(type == 'Séance' ||
              type == 'Sport' ||
              text.contains('Séance du jour') ||
              text.contains('Objectif:') && text.contains('tours:'));
        }).toList();

        print(
            '✅ Dashboard - Loading ${sports.length} sport sessions from journal (${allSports.length - sports.length} auto-generated filtered out)');
        setState(() {
          _todaySportSessions
            ..clear()
            ..addAll(sports.map((s) => SportSession(
                  sportName: (s['type'] ?? 'Sport').toString(),
                  duration: (s['duration'] ?? 30) is int
                      ? s['duration']
                      : (s['duration'] ?? 30).toInt(),
                  intensity: _inferIntensity((s['type'] ?? '').toString()),
                  id: (s['id'] ?? '').toString(),
                  text: (s['text'] ?? '')?.toString(),
                )));
        });
      } catch (e) {
        print('❌ Dashboard - Error loading sport sessions: $e');
      }
    }

    // Clear individual meals since we're now loading everything from journal source
    _individualMealsToday.clear();

    print(
        '🧮 Dashboard loaded - Daily: ${_savedDailyMeals.length}, Individual: ${_individualMealsToday.length}');
  }

  Future<Map<String, dynamic>> _loadHydrationData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = DateTime.now().toIso8601String().split('T').first;

      // Load hydration data for today
      final journalKey = 'journal_$today';
      final journalRaw = prefs.getString(journalKey);

      print('🚰 Dashboard _loadHydrationData():');
      print('  - Date: $today');
      print('  - Journal key: $journalKey');
      print('  - Raw data exists: ${journalRaw != null}');
      if (journalRaw != null) {
        print('  - Raw data length: ${journalRaw.length} chars');
        print(
            '  - Raw data preview: ${journalRaw.length > 100 ? journalRaw.substring(0, 100) + "..." : journalRaw}');
      }

      int consumed = 0;
      const int target = 2000; // Default 2L target

      if (journalRaw != null) {
        try {
          final journalData = jsonDecode(journalRaw) as Map<String, dynamic>;
          consumed = (journalData['hydration'] as int?) ?? 0;
          print('  - Parsed hydration: $consumed ml');
          print('  - Journal data keys: ${journalData.keys.toList()}');
        } catch (e) {
          print('  - Error parsing journal data: $e');
        }
      } else {
        print('  - No journal data found for today');
      }

      print('  - Final hydration result: consumed=$consumed, target=$target');

      return {
        'consumed': consumed,
        'target': target,
      };
    } catch (e) {
      print('Error in _loadHydrationData: $e');
      return {'consumed': 0, 'target': 2000};
    }
  }

  // Removed duplicate dispose; unified into single dispose above

  @override
  bool get wantKeepAlive => true; // Keep alive to avoid unnecessary rebuilds

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tableau de bord nutritionnel'),
        backgroundColor: FreshTheme.primaryMint,
        automaticallyImplyLeading: false,
        actions: const [],
      ),
      body: BlocBuilder<UserProfileBloc, UserProfileState>(
        builder: (context, state) {
          if (state is UserProfileLoading) {
            return _buildShimmerLoading(context);
          } else if (state is UserProfileLoaded) {
            return _buildDashboard(context, state.userProfile);
          } else if (state is UserProfileError) {
            return _buildErrorState(context, state.message);
          }
          return _buildShimmerLoading(context);
        },
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 60, color: Colors.red),
          const SizedBox(height: 16),
          Text('Erreur: $message'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () =>
                context.read<UserProfileBloc>().add(GetUserProfileEvent()),
            child: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboard(BuildContext context, UserProfile userProfile) {
    final macros = userProfile.calculateMacroTargets();
    final dailyTotals = _calculateDailyTotals();

    return RefreshIndicator(
      onRefresh: () async {
        await _loadSavedMeals();
      },
      color: FreshTheme.primaryMint,
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildGreetingHeader(context, userProfile),
          const SizedBox(height: 24),
          _buildQuickStatsCard(context, dailyTotals, macros),
          const SizedBox(height: 24),
          _buildMacroNutrientsCard(context, dailyTotals, macros),
          const SizedBox(height: 24),
          _buildHydrationCard(context),
          const SizedBox(height: 24),
          _buildSportTrackingCard(context),
        ],
      ),
    );
  }

  Widget _buildGreetingHeader(BuildContext context, UserProfile userProfile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bonjour, ${userProfile.name ?? 'Utilisateur'}!',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          color: FreshTheme.midnightGray,
                          fontSize: 28,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Prêt à atteindre vos objectifs aujourd\'hui?',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: FreshTheme.stormGray,
                        ),
                  ),
                ],
              ),
            ),
            _buildLevelBadge(context),
          ],
        ),
      ],
    );
  }

  Widget _buildLevelBadge(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed('/challenges');
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              FreshTheme.primaryMint,
              FreshTheme.primaryMint.withOpacity(0.8)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: FreshTheme.primaryMint.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.military_tech,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 6),
            const Text(
              'Niveau 5',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // NOTE: This replaces the old TabBar and multi-period views
  // All essential info is now consolidated into a single, dynamic daily dashboard.
  // Deprecated helper views supprimés

  Widget _buildQuickStatsCard(
      BuildContext context, DailyTotals totals, Map<String, double> macros) {
    final theme = Theme.of(context);
    // Calculate calories separately
    final sportCalories = _calculateSportCalories();
    final consumedCalories = totals.calories; // Only food calories
    final netCalories =
        totals.calories - sportCalories; // Net calories (food - sport)
    final targetCalories = macros['calories'] ?? 2000;
    // Progress circle uses values directly; no besoin d'un pourcentage local

    return Card(
      elevation: 4,
      shadowColor: FreshTheme.primaryMint.withAlpha(80),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Résumé du jour',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: FreshTheme.midnightGray,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: FreshProgressCircle(
                    current: netCalories.round(),
                    target: targetCalories.round(),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildStatRow(
                        icon: Icons.local_fire_department_rounded,
                        color: FreshTheme.accentCoral,
                        label: 'Consommées',
                        value: '${consumedCalories.round()} kcal',
                      ),
                      const SizedBox(height: 12),
                      _buildStatRow(
                        icon: Icons.flag_rounded,
                        color: FreshTheme.primaryMint,
                        label: 'Objectif',
                        value: '${targetCalories.round()} kcal',
                      ),
                      const SizedBox(height: 12),
                      _buildStatRow(
                        icon: Icons.directions_run_rounded,
                        color: FreshTheme.serenityBlue,
                        label: 'Brûlées (sport)',
                        value: '${sportCalories.round()} kcal',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(
      {required IconData icon,
      required Color color,
      required String label,
      required String value}) {
    return Row(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: FreshTheme.stormGray,
                ),
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: FreshTheme.midnightGray,
              ),
        ),
      ],
    );
  }

  Widget _buildMacroNutrientsCard(
      BuildContext context, DailyTotals totals, Map<String, double> macros) {
    final theme = Theme.of(context);

    // Calculer les valeurs et pourcentages pour chaque macronutriment
    final proteinsTarget = macros['proteins'] ?? 100;
    final carbsTarget = macros['carbs'] ?? 250;
    final fatsTarget = macros['fats'] ?? 80;

    final proteinsProgress = (totals.proteins / proteinsTarget).clamp(0.0, 1.5);
    final carbsProgress = (totals.carbs / carbsTarget).clamp(0.0, 1.5);
    final fatsProgress = (totals.fats / fatsTarget).clamp(0.0, 1.5);

    return Card(
      elevation: 4,
      shadowColor: FreshTheme.primaryMint.withAlpha(80),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Macronutriments',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: FreshTheme.midnightGray,
              ),
            ),
            const SizedBox(height: 24),

            // Graphique des protéines
            _buildMacroProgressBar(
              context,
              'Protéines',
              totals.proteins.round(),
              proteinsTarget.round(),
              proteinsProgress,
              Colors.blue,
              Icons.fitness_center,
            ),
            const SizedBox(height: 20),

            // Graphique des glucides
            _buildMacroProgressBar(
              context,
              'Glucides',
              totals.carbs.round(),
              carbsTarget.round(),
              carbsProgress,
              Colors.green,
              Icons.energy_savings_leaf,
            ),
            const SizedBox(height: 20),

            // Graphique des lipides
            _buildMacroProgressBar(
              context,
              'Lipides',
              totals.fats.round(),
              fatsTarget.round(),
              fatsProgress,
              Colors.orange,
              Icons.opacity,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMacroProgressBar(
    BuildContext context,
    String label,
    int current,
    int target,
    double progress,
    Color color,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    final percentage = (progress * 100).round();
    final isOverTarget = progress > 1.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: FreshTheme.midnightGray,
              ),
            ),
            const Spacer(),
            Text(
              '${current}g / ${target}g',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isOverTarget ? Colors.orange : FreshTheme.stormGray,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Barre de progression
        Container(
          height: 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: color.withOpacity(0.1),
          ),
          child: Stack(
            children: [
              // Barre de fond
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: color.withOpacity(0.15),
                ),
              ),
              // Barre de progression
              FractionallySizedBox(
                widthFactor: progress.clamp(0.0, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: color,
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
              // Indicateur de dépassement si nécessaire
              if (isOverTarget)
                Positioned(
                  right: 0,
                  child: Container(
                    width: 3,
                    height: 8,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      color: Colors.orange,
                    ),
                  ),
                ),
            ],
          ),
        ),

        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${percentage}%',
              style: theme.textTheme.bodySmall?.copyWith(
                color: isOverTarget ? Colors.orange : color,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (isOverTarget)
              Text(
                'Objectif dépassé',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.orange,
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildHydrationCard(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _loadHydrationData(),
      builder: (context, snapshot) {
        // Show loading state while data is being fetched
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Card(
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.opacity, color: FreshTheme.primaryMint),
                      const SizedBox(width: 12),
                      Text(
                        'Hydratation',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: FreshTheme.primaryMint,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Center(child: CircularProgressIndicator()),
                ],
              ),
            ),
          );
        }

        final hydrationData = snapshot.data ?? {'consumed': 0, 'target': 2000};
        final consumed = hydrationData['consumed'] as int;
        final target = hydrationData['target'] as int;
        final percentage =
            target > 0 ? (consumed / target * 100).clamp(0, 100) : 0;

        final theme = Theme.of(context);
        return Card(
          elevation: 3,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.opacity, color: FreshTheme.primaryMint),
                    const SizedBox(width: 12),
                    Text(
                      'Hydratation',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: FreshTheme.primaryMint,
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
                const SizedBox(height: 16),

                // Progress bar
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: percentage / 100,
                    child: Container(
                      decoration: BoxDecoration(
                        color: FreshTheme.primaryMint,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Stats
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${consumed}ml',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: FreshTheme.primaryMint,
                          ),
                        ),
                        const Text(
                          'Consommé',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${target}ml',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          'Objectif',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${percentage.round()}%',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: percentage >= 100
                                ? FreshTheme.primaryMint
                                : Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                if (percentage >= 100)
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: FreshTheme.primaryMint.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      '🎉 Objectif atteint !',
                      style: TextStyle(
                        fontSize: 12,
                        color: FreshTheme.primaryMint,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                // Debug info (remove in production)
                if (consumed == 0)
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '⚠️ Aucune hydratation détectée. Ajoutez de l\'eau dans l\'onglet Journal.',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.orange[700],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSportTrackingCard(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 4,
      shadowColor: FreshTheme.serenityBlue.withAlpha(80),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Activité physique',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: FreshTheme.midnightGray,
              ),
            ),
            const SizedBox(height: 12),
            _buildSportSessionsList(context),
          ],
        ),
      ),
    );
  }

  // Removed unused _buildIndividualMealsCard

  Widget _buildSportSessionsList(BuildContext context) {
    final theme = Theme.of(context);
    final sportCalories = _calculateSportCalories();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Séances de sport du jour',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: FreshTheme.midnightGray,
          ),
        ),
        const SizedBox(height: 8),
        if (_todaySportSessions.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _todaySportSessions
                .map((s) => s.sportName)
                .toSet()
                .map((t) => Chip(
                      label: Text(t),
                      backgroundColor: FreshTheme.primaryMint.withOpacity(0.1),
                      labelStyle: const TextStyle(fontSize: 12),
                    ))
                .toList(),
          ),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _todaySportSessions.length,
          itemBuilder: (context, index) {
            final session = _todaySportSessions[index];
            return _buildSportSessionItem(context, session, index);
          },
        ),
        const SizedBox(height: 8),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            '-${sportCalories.round()} kcal',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: FreshTheme.accentCoral,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSportSessionItem(
      BuildContext context, SportSession session, int index) {
    final caloriesBurned = _calculateSessionCalories(session);

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: _getIntensityColor(session.intensity).withOpacity(0.1),
        child: Icon(
          _getSportIcon(session.sportName),
          color: _getIntensityColor(session.intensity),
        ),
      ),
      title: Text(
        session.sportName,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${session.duration} min • ${_getIntensityLabel(session.intensity)} • -${caloriesBurned.round()} kcal',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () => _openWorkoutContent(session),
              icon: const Icon(Icons.open_in_new),
              label: const Text('Visualiser la séance'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openWorkoutContent(SportSession session) async {
    String content = session.text ?? 'Contenu indisponible';
    final id = session.id;

    // Debug: Log what we have
    print('🔍 Opening workout content:');
    print('  - ID: $id');
    print('  - Session text length: ${session.text?.length ?? 0}');
    print(
        '  - Session text preview: ${session.text?.substring(0, session.text!.length > 100 ? 100 : session.text!.length)}...');

    if (id != null && id.isNotEmpty && !id.startsWith('local_')) {
      final fetched = await NutritionChatService().getWorkoutContentById(id);
      if (fetched != null && fetched.isNotEmpty) {
        content = fetched;
        print('  - Fetched content length: ${content.length}');
      }
    }

    print('  - Final content to display: ${content.length} chars');

    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Séance de sport'),
        content: SingleChildScrollView(child: SelectableText(content)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fermer'),
          )
        ],
      ),
    );
  }

  // Removed deprecated dialog stub

  // Helper methods
  DailyTotals _calculateDailyTotals() {
    double totalCalories = 0;
    double totalProteins = 0;
    double totalCarbs = 0;
    double totalFats = 0;

    // Include all meals from journal data (both AI generated and manually added)
    for (final meal in _savedDailyMeals) {
      totalCalories += meal.calories;
      totalProteins += meal.proteins;
      totalCarbs += meal.carbs;
      totalFats += meal.fats;
    }

    // Individual meals should be empty now (all data unified in journal)
    // Keeping this loop for safety but it should not execute
    for (final meal in _individualMealsToday) {
      totalCalories += meal.calories;
      totalProteins += meal.proteins;
      totalCarbs += meal.carbs;
      totalFats += meal.fats;
      print(
          '⚠️ Found meal in individual list: ${meal.name} - this should not happen');
    }

    // No fallback to mock data: keep zeros if aucun repas sélectionné

    print(
        '🧮 Dashboard totals: ${totalCalories.round()} kcal from ${_savedDailyMeals.length} daily + ${_individualMealsToday.length} individual meals');

    return DailyTotals(
      calories: totalCalories,
      proteins: totalProteins,
      carbs: totalCarbs,
      fats: totalFats,
    );
  }

  double _calculateSportCalories() {
    return _todaySportSessions.fold(
        0.0, (total, session) => total + _calculateSessionCalories(session));
  }

  double _calculateSessionCalories(SportSession session) {
    // Basic calorie calculation based on intensity and duration
    // These are rough estimates - in a real app, would use user weight and more precise formulas
    const baseCaloriesPerMinute = {
      SportIntensity.low: 3.5,
      SportIntensity.medium: 7.0,
      SportIntensity.high: 11.0,
      SportIntensity.extreme: 15.0,
    };

    return (baseCaloriesPerMinute[session.intensity] ?? 7.0) * session.duration;
  }

  SportIntensity _inferIntensity(String type) {
    final t = type.toLowerCase();
    if (t.contains('hiit') || t.contains('sprint')) return SportIntensity.high;
    if (t.contains('yoga') || t.contains('marche')) return SportIntensity.low;
    if (t.contains('musculation')) return SportIntensity.high;
    return SportIntensity.medium;
  }

  Color _getIntensityColor(SportIntensity intensity) {
    switch (intensity) {
      case SportIntensity.low:
        return Colors.green;
      case SportIntensity.medium:
        return Colors.blue;
      case SportIntensity.high:
        return Colors.orange;
      case SportIntensity.extreme:
        return Colors.red;
    }
  }

  String _getIntensityLabel(SportIntensity intensity) {
    switch (intensity) {
      case SportIntensity.low:
        return 'Faible intensité';
      case SportIntensity.medium:
        return 'Intensité modérée';
      case SportIntensity.high:
        return 'Haute intensité';
      case SportIntensity.extreme:
        return 'Intensité extrême';
    }
  }

  IconData _getSportIcon(String sportName) {
    final sportIcons = {
      'Course à pied': Icons.directions_run,
      'Natation': Icons.pool,
      'Cyclisme': Icons.directions_bike,
      'Musculation': Icons.fitness_center,
      'Football': Icons.sports_soccer,
      'Tennis': Icons.sports_tennis,
      'Basketball': Icons.sports_basketball,
      'Yoga': Icons.self_improvement,
      'Randonnée': Icons.hiking,
      'Danse': Icons.music_note,
      'Autre': Icons.sports,
    };

    return sportIcons[sportName] ?? Icons.sports;
  }

  // Removed unused _addSportSessionXP

  // Removed unused water calc

  // Removed unused mock meal deletion

  // Public method to refresh dashboard data - called when navigating to dashboard tab
  Future<void> refreshDashboardData() async {
    print('🔄 Dashboard refreshDashboardData() called');
    if (mounted) {
      await _loadSavedMeals();
      await _loadGamificationData();
      // Force rebuild of hydration and sports data by triggering a state update
      setState(() {});
      print('✅ Dashboard refresh completed');
    }
  }
}

// Data classes
class MealFood {
  final String name;
  final double calories;
  final double proteins;
  final double carbs;
  final double fats;

  MealFood(this.name, this.calories, this.proteins, this.carbs, this.fats);

  factory MealFood.fromSavedMeal(Map<String, dynamic> json) {
    return MealFood(
      json['name'] ?? json['mealType'] ?? 'Repas',
      (json['calories'] ?? 0).toDouble(),
      (json['protein'] ?? json['proteins'] ?? 0).toDouble(),
      (json['carbs'] ?? 0).toDouble(),
      (json['fat'] ?? json['fats'] ?? 0).toDouble(),
    );
  }

  factory MealFood.fromAIMeal(Map<String, dynamic> json) {
    return MealFood(
      json['name'] ?? 'Repas IA',
      (json['calories'] ?? 0).toDouble(),
      (json['protein'] ?? 0).toDouble(),
      (json['carbs'] ?? 0).toDouble(),
      (json['fat'] ?? 0).toDouble(),
    );
  }
}

class DailyTotals {
  final double calories;
  final double proteins;
  final double carbs;
  final double fats;

  DailyTotals({
    required this.calories,
    required this.proteins,
    required this.carbs,
    required this.fats,
  });
}

class WeeklyTotals {
  final double averageCaloriesPerDay;
  final int daysWithGoalMet;
  final List<double> dailyCalories;
  final double averageProteins;
  final double averageCarbs;
  final double averageFats;

  WeeklyTotals({
    required this.averageCaloriesPerDay,
    required this.daysWithGoalMet,
    required this.dailyCalories,
    required this.averageProteins,
    required this.averageCarbs,
    required this.averageFats,
  });
}

class MonthlyTotals {
  final double averageCaloriesPerDay;
  final int currentStreak;
  final int daysWithGoalMet;
  final int totalDays;
  final double averageWeight;
  final List<double> weeklyWeights;

  MonthlyTotals({
    required this.averageCaloriesPerDay,
    required this.currentStreak,
    required this.daysWithGoalMet,
    required this.totalDays,
    required this.averageWeight,
    required this.weeklyWeights,
  });
}

class SportSession {
  final String sportName;
  final int duration; // in minutes
  final SportIntensity intensity;
  final String? id;
  final String? text;

  SportSession({
    required this.sportName,
    required this.duration,
    required this.intensity,
    this.id,
    this.text,
  });
}

class _AddSportSessionDialog extends StatefulWidget {
  final Function(SportSession) onAdd;

  const _AddSportSessionDialog({
    Key? key,
    required this.onAdd,
  }) : super(key: key);

  @override
  State<_AddSportSessionDialog> createState() => _AddSportSessionDialogState();
}

class _AddSportSessionDialogState extends State<_AddSportSessionDialog> {
  String? _selectedSport;
  int _duration = 30;
  SportIntensity _intensity = SportIntensity.medium;

  final List<String> _commonSports = [
    'Course à pied',
    'Natation',
    'Cyclisme',
    'Musculation',
    'Football',
    'Tennis',
    'Basketball',
    'Yoga',
    'Randonnée',
    'Danse',
    'Autre',
  ];

  final TextEditingController _customSportController = TextEditingController();
  final TextEditingController _durationController =
      TextEditingController(text: '30');

  @override
  void dispose() {
    _customSportController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: Row(
          children: [
            Icon(Icons.fitness_center, color: FreshTheme.primaryMint),
            const SizedBox(width: 12),
            Text('Ajouter une séance de sport'),
          ],
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sport selection
            Text(
              'Choisir un sport',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _commonSports.map((sport) {
                final isSelected = _selectedSport == sport;
                return ChoiceChip(
                  label: Text(sport),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedSport = selected ? sport : null;
                      if (sport == 'Autre') {
                        _customSportController.clear();
                      }
                    });
                  },
                  selectedColor: FreshTheme.primaryMint.withOpacity(0.2),
                  checkmarkColor: FreshTheme.primaryMint,
                );
              }).toList(),
            ),

            // Custom sport input
            if (_selectedSport == 'Autre') ...[
              const SizedBox(height: 16),
              TextField(
                controller: _customSportController,
                decoration: InputDecoration(
                  labelText: 'Nom du sport',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: Icon(Icons.sports, color: FreshTheme.primaryMint),
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Duration input
            Text(
              'Durée (minutes)',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      _duration = (_duration - 5).clamp(5, 300);
                      _durationController.text = _duration.toString();
                    });
                  },
                  icon: Icon(Icons.remove_circle_outline),
                  color: FreshTheme.primaryMint,
                ),
                Expanded(
                  child: TextField(
                    controller: _durationController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    onChanged: (value) {
                      final parsed = int.tryParse(value);
                      if (parsed != null) {
                        setState(() {
                          _duration = parsed.clamp(5, 300);
                        });
                      }
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      suffixText: 'min',
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _duration = (_duration + 5).clamp(5, 300);
                      _durationController.text = _duration.toString();
                    });
                  },
                  icon: Icon(Icons.add_circle_outline),
                  color: FreshTheme.primaryMint,
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Intensity selection
            Text(
              'Intensité',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Column(
              children: SportIntensity.values.map((intensity) {
                final isSelected = _intensity == intensity;
                final color = _getIntensityColorStatic(intensity);
                final label = _getIntensityLabelStatic(intensity);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _intensity = intensity;
                      });
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? color.withOpacity(0.1)
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected ? color : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _getIntensityIconStatic(intensity),
                            color: color,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              label,
                              style: TextStyle(
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: isSelected ? color : Colors.black87,
                              ),
                            ),
                          ),
                          if (isSelected)
                            Icon(
                              Icons.check_circle,
                              color: color,
                              size: 20,
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: () {
            String sportName;
            if (_selectedSport == 'Autre') {
              sportName = _customSportController.text.trim();
              if (sportName.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Veuillez entrer le nom du sport'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
            } else if (_selectedSport != null) {
              sportName = _selectedSport!;
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Veuillez sélectionner un sport'),
                  backgroundColor: Colors.red,
                ),
              );
              return;
            }

            final session = SportSession(
              sportName: sportName,
              duration: _duration,
              intensity: _intensity,
            );

            widget.onAdd(session);
            Navigator.of(context).pop();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: FreshTheme.primaryMint,
          ),
          child: Text('Ajouter'),
        ),
      ],
    );
  }

  static Color _getIntensityColorStatic(SportIntensity intensity) {
    switch (intensity) {
      case SportIntensity.low:
        return Colors.green;
      case SportIntensity.medium:
        return Colors.blue;
      case SportIntensity.high:
        return Colors.orange;
      case SportIntensity.extreme:
        return Colors.red;
    }
  }

  static String _getIntensityLabelStatic(SportIntensity intensity) {
    switch (intensity) {
      case SportIntensity.low:
        return 'Faible (yoga, marche)';
      case SportIntensity.medium:
        return 'Modérée (jogging, vélo)';
      case SportIntensity.high:
        return 'Élevée (course rapide, musculation)';
      case SportIntensity.extreme:
        return 'Extrême (HIIT, sprint)';
    }
  }

  static IconData _getIntensityIconStatic(SportIntensity intensity) {
    switch (intensity) {
      case SportIntensity.low:
        return Icons.self_improvement;
      case SportIntensity.medium:
        return Icons.directions_run;
      case SportIntensity.high:
        return Icons.fitness_center;
      case SportIntensity.extreme:
        return Icons.local_fire_department;
    }
  }
}

// Enums
enum SportIntensity {
  low,
  medium,
  high,
  extreme,
}
