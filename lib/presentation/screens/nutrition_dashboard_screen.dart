// lib/presentation/screens/nutrition_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lym_nutrition/domain/entities/user_profile.dart';
import 'package:lym_nutrition/presentation/bloc/user_profile/user_profile_bloc.dart';
import 'package:lym_nutrition/presentation/bloc/user_profile/user_profile_event.dart';
import 'package:lym_nutrition/presentation/bloc/user_profile/user_profile_state.dart';
import 'package:lym_nutrition/presentation/screens/food_search_screen.dart';
import 'package:lym_nutrition/presentation/themes/premium_theme.dart';
import 'package:lym_nutrition/presentation/themes/wellness_colors.dart';
import 'package:lym_nutrition/presentation/widgets/macro_nutrients_chart.dart';
import 'package:lym_nutrition/presentation/widgets/nutrition_target_card.dart';
import 'package:lym_nutrition/presentation/widgets/wellness_dashboard_header.dart';
import 'package:lym_nutrition/presentation/widgets/achievement_badge.dart';
import 'package:lym_nutrition/presentation/widgets/level_progression.dart';
import 'package:lym_nutrition/presentation/widgets/progress_charts.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:percent_indicator/percent_indicator.dart';

class NutritionDashboardScreen extends StatefulWidget {
  const NutritionDashboardScreen({Key? key}) : super(key: key);

  @override
  State<NutritionDashboardScreen> createState() =>
      _NutritionDashboardScreenState();
}

class _NutritionDashboardScreenState extends State<NutritionDashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Charger le profil utilisateur
    context.read<UserProfileBloc>().add(GetUserProfileEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<UserProfileBloc, UserProfileState>(
        builder: (context, state) {
          if (state is UserProfileLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (state is UserProfileLoaded) {
            return _buildDashboard(context, state.userProfile);
          } else if (state is UserProfileError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 60,
                    color: PremiumTheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Erreur lors du chargement du profil',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context
                          .read<UserProfileBloc>()
                          .add(GetUserProfileEvent());
                    },
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }

          // État initial ou autre
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Naviguer vers l'écran de recherche d'aliments
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const FoodSearchScreen(),
            ),
          );
        },
        backgroundColor: PremiumTheme.primaryColor,
        child: const Icon(Icons.search, color: Colors.white),
      ),
    );
  }

  Widget _buildDashboard(BuildContext context, UserProfile userProfile) {
    final theme = Theme.of(context);
    final macros = userProfile.calculateMacroTargets();

    // Simuler des données d'aujourd'hui (à remplacer par les vraies données)
    final dailyCaloriesConsumed = 800.0;
    final dailyProteinConsumed = 30.0;
    final dailyCarbsConsumed = 75.0;
    final dailyFatConsumed = 35.0;
    final dailyWaterConsumed = 1200.0; // ml

    // Calculer les pourcentages de progression
    final caloriesPercent =
        (dailyCaloriesConsumed / macros['calories']!).clamp(0.0, 1.0);
    final waterPercent =
        (dailyWaterConsumed / 2500.0).clamp(0.0, 1.0); // Objectif de 2500 ml

    // Vérifier si l'utilisateur devrait jeûner maintenant
    final now = DateTime.now();
    final isFasting = userProfile.shouldBeFasting(now);
    final hoursUntilFastingEnds = userProfile.hoursUntilFastingEnds(now);
    final hoursUntilFastingStarts = userProfile.hoursUntilFastingStarts(now);

    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          SliverToBoxAdapter(
            child: WellnessDashboardHeader(
              userName: userProfile.name ?? 'Utilisateur',
              dailyProgress: caloriesPercent,
              caloriesConsumed: dailyCaloriesConsumed.round(),
              caloriesGoal: macros['calories']?.round() ?? 2000,
              streakDays: _calculateDailyStreak(),
              onAiAssistantTap: () {
                _showAIAssistant(context);
              },
            ),
          ),
        ];
      },
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Level Progression & Achievements Section
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.military_tech,
                          color: WellnessColors.primaryGreen,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Progression & Achievements',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: WellnessColors.primaryGreen,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Level Progression
                    LevelProgressWidget(
                      currentLevel: _calculateCurrentLevel(
                          dailyCaloriesConsumed, macros['calories'] ?? 2000),
                      currentXP: _calculateCurrentXP(dailyCaloriesConsumed),
                      xpToNextLevel: _calculateNextLevelXP(
                          _calculateCurrentLevel(dailyCaloriesConsumed,
                              macros['calories'] ?? 2000)),
                    ),

                    const SizedBox(height: 20),

                    // Recent Achievements
                    Text(
                      'Achievements récents',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _getRecentAchievements(dailyCaloriesConsumed,
                                macros, dailyWaterConsumed)
                            .map((achievement) => Padding(
                                  padding: const EdgeInsets.only(right: 12),
                                  child: AchievementBadge(
                                    title: achievement.title,
                                    description: achievement.description,
                                    icon: achievement.icon,
                                    color: achievement.color,
                                    isEarned: true,
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Modern Progress Charts Section
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.analytics,
                          color: WellnessColors.secondaryBlue,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Analyses nutritionnelles',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: WellnessColors.secondaryBlue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Nutrition Progress Charts
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: NutritionProgressChart(
                            label: 'Protéines',
                            value: dailyProteinConsumed,
                            target: macros['protein'] ?? 150,
                            unit: 'g',
                            color: WellnessColors.primaryGreen,
                            icon: Icons.fitness_center,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: NutritionProgressChart(
                            label: 'Glucides',
                            value: dailyCarbsConsumed,
                            target: macros['carbs'] ?? 250,
                            unit: 'g',
                            color: WellnessColors.sunsetOrange,
                            icon: Icons.grain,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: NutritionProgressChart(
                            label: 'Lipides',
                            value: dailyFatConsumed,
                            target: macros['fat'] ?? 75,
                            unit: 'g',
                            color: WellnessColors.errorCoral,
                            icon: Icons.opacity,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Hydration Progress with animated wave
                    Row(
                      children: [
                        Icon(
                          Icons.water_drop,
                          color: WellnessColors.secondaryBlue,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Hydratation',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: WellnessColors.secondaryBlue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    SizedBox(
                      height: 120,
                      child: HydrationWaveProgress(
                        currentAmount: dailyWaterConsumed,
                        targetAmount: 2500,
                        unit: 'ml',
                        height: 120,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Affichage du jeûne intermittent (si activé)
            if (userProfile.fastingSchedule.type !=
                IntermittentFastingType.none)
              Card(
                color: isFasting
                    ? PremiumTheme.primaryColor.withOpacity(0.1)
                    : Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.schedule,
                            color: isFasting
                                ? PremiumTheme.primaryColor
                                : PremiumTheme.secondaryColor,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Jeûne intermittent',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isFasting
                                  ? PremiumTheme.primaryColor
                                  : PremiumTheme.secondaryColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      isFasting
                          ? Text(
                              'Vous êtes en période de jeûne',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : Text(
                              'Vous êtes en période d\'alimentation',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                      const SizedBox(height: 4),
                      isFasting
                          ? Text(
                              'Fin du jeûne dans ${hoursUntilFastingEnds.toStringAsFixed(1)} heures',
                            )
                          : Text(
                              'Début du jeûne dans ${hoursUntilFastingStarts.toStringAsFixed(1)} heures',
                            ),
                      const SizedBox(height: 8),
                      LinearPercentIndicator(
                        lineHeight: 8,
                        percent: (isFasting
                                ? 1 -
                                    (hoursUntilFastingEnds /
                                        userProfile
                                            .fastingSchedule.fastingHours)
                                : 1 -
                                    (hoursUntilFastingStarts /
                                        userProfile
                                            .fastingSchedule.eatingHours))
                            .clamp(0.0, 1.0),
                        backgroundColor: Colors.grey.withOpacity(0.2),
                        progressColor: isFasting
                            ? PremiumTheme.primaryColor
                            : PremiumTheme.secondaryColor,
                        barRadius: const Radius.circular(4),
                        padding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                ),
              ),

            if (userProfile.fastingSchedule.type !=
                IntermittentFastingType.none)
              const SizedBox(height: 16),

            // Résumé des calories
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Calories aujourd\'hui',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${dailyCaloriesConsumed.round()} / ${macros['calories']?.round()} kcal',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: PremiumTheme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularPercentIndicator(
                          radius: 80,
                          lineWidth: 12,
                          percent: caloriesPercent,
                          center: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${(caloriesPercent * 100).round()}%',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: PremiumTheme.primaryColor,
                                ),
                              ),
                              Text(
                                'Consommé',
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          ),
                          backgroundColor: Colors.grey.withOpacity(0.2),
                          progressColor: PremiumTheme.primaryColor,
                          circularStrokeCap: CircularStrokeCap.round,
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Restant : ${(macros['calories']! - dailyCaloriesConsumed).round()} kcal',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Objectif basé sur votre profil ${_getWeightGoalText(userProfile.weightGoal)}',
                                style: theme.textTheme.bodySmall,
                              ),
                              const SizedBox(height: 8),
                              ElevatedButton.icon(
                                onPressed: () {
                                  // Naviguer vers l'écran de journal alimentaire
                                },
                                icon: const Icon(Icons.add),
                                label: const Text('Ajouter un repas'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: PremiumTheme.primaryColor,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Macronutriments
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.pie_chart,
                          color: PremiumTheme.primaryColor,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Macronutriments',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Graphique des macros (à implémenter)
                    MacroNutrientsChart(
                      proteins: dailyProteinConsumed,
                      carbs: dailyCarbsConsumed,
                      fats: dailyFatConsumed,
                      proteinTarget: macros['protein']!,
                      carbsTarget: macros['carbs']!,
                      fatTarget: macros['fat']!,
                    ),

                    const SizedBox(height: 16),

                    // Barres de progression des macros
                    Row(
                      children: [
                        Expanded(
                          child: NutritionTargetCard(
                            label: 'Protéines',
                            consumed: dailyProteinConsumed,
                            target: macros['protein']!,
                            unit: 'g',
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: NutritionTargetCard(
                            label: 'Glucides',
                            consumed: dailyCarbsConsumed,
                            target: macros['carbs']!,
                            unit: 'g',
                            color: Colors.orange,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: NutritionTargetCard(
                            label: 'Lipides',
                            consumed: dailyFatConsumed,
                            target: macros['fat']!,
                            unit: 'g',
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Hydratation
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.water_drop,
                          color: Colors.blue,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Hydratation',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        CircularPercentIndicator(
                          radius: 40,
                          lineWidth: 8,
                          percent: waterPercent,
                          center: Icon(
                            Icons.water_drop,
                            color: Colors.blue,
                            size: 24,
                          ),
                          backgroundColor: Colors.grey.withOpacity(0.2),
                          progressColor: Colors.blue,
                          circularStrokeCap: CircularStrokeCap.round,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${dailyWaterConsumed.round()} / 2500 ml',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                              const SizedBox(height: 4),
                              LinearPercentIndicator(
                                lineHeight: 8,
                                percent: waterPercent,
                                backgroundColor: Colors.grey.withOpacity(0.2),
                                progressColor: Colors.blue,
                                barRadius: const Radius.circular(4),
                                padding: EdgeInsets.zero,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Il vous reste ${(2500 - dailyWaterConsumed).round()} ml à boire',
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Boutons pour ajouter de l'eau
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildWaterButton(100, Colors.blue.shade100),
                        _buildWaterButton(200, Colors.blue.shade300),
                        _buildWaterButton(300, Colors.blue.shade500),
                        _buildWaterButton(500, Colors.blue.shade700),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Compléments alimentaires (si l'utilisateur en a)
            if (userProfile.supplements.isNotEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.medical_services,
                                color: PremiumTheme.primaryColor,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Compléments alimentaires',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '0/${userProfile.supplements.length} pris',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ...userProfile.supplements.map((supplement) {
                        return CheckboxListTile(
                          title: Text(
                            supplement.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            '${supplement.dosage} ${supplement.unit} - ${supplement.timing}',
                          ),
                          value: false, // À remplacer par l'état réel
                          onChanged: (value) {
                            // Mettre à jour l'état de prise du complément
                          },
                          activeColor: PremiumTheme.primaryColor,
                          contentPadding: EdgeInsets.zero,
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),

            if (userProfile.supplements.isNotEmpty) const SizedBox(height: 16),

            // Conseils nutritionnels personnalisés
            Card(
              color: PremiumTheme.secondaryColor.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.tips_and_updates,
                          color: PremiumTheme.secondaryColor,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Conseil nutritionnel',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: PremiumTheme.secondaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Selon votre profil et vos objectifs, essayez d\'augmenter votre consommation de protéines pour favoriser la récupération musculaire et la satiété.',
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Votre consommation de protéines est actuellement inférieure à l\'objectif recommandé pour votre profil.',
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWaterButton(int amount, Color color) {
    return GestureDetector(
      onTap: () {
        // Ajouter la quantité d'eau
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$amount ml d\'eau ajoutés'),
            backgroundColor: Colors.blue,
          ),
        );
      },
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(PremiumTheme.borderRadiusMedium),
          border: Border.all(color: color),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$amount',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              'ml',
              style: TextStyle(
                fontSize: 12,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getWeightGoalText(WeightGoal goal) {
    switch (goal) {
      case WeightGoal.lose:
        return 'pour perdre du poids';
      case WeightGoal.maintain:
        return 'pour maintenir votre poids';
      case WeightGoal.gain:
        return 'pour prendre du poids';
    }
  }

  // Gamification helper methods
  int _calculateDailyStreak() {
    // TODO: Calculate actual daily streak based on user activity
    // For now, return a placeholder value
    return 5; // 5-day streak
  }

  int _calculateCurrentLevel(double caloriesConsumed, double caloriesGoal) {
    // Calculate level based on daily goal achievement
    final progressPercent = (caloriesConsumed / caloriesGoal).clamp(0.0, 1.0);
    return (progressPercent * 10).floor() + 1; // Levels 1-10
  }

  int _calculateCurrentXP(double caloriesConsumed) {
    // Convert calories to XP (1 calorie = 1 XP)
    return caloriesConsumed.round();
  }

  int _calculateNextLevelXP(int currentLevel) {
    // XP needed for next level (exponential growth)
    return currentLevel * 500; // 500, 1000, 1500, etc.
  }

  List<Achievement> _getRecentAchievements(double caloriesConsumed,
      Map<String, double> macros, double waterConsumed) {
    List<Achievement> achievements = [];

    // Check for calorie achievement
    if (caloriesConsumed >= (macros['calories'] ?? 2000) * 0.8) {
      achievements
          .add(AchievementDefinitions.achievements[0]); // First meal logged
    }

    // Check for hydration achievement
    if (waterConsumed >= 2000) {
      achievements
          .add(AchievementDefinitions.achievements[2]); // Hydration Hero
    }

    // Add weekly streak if applicable
    if (_calculateDailyStreak() >= 7) {
      achievements.add(AchievementDefinitions.achievements[1]); // Healthy week
    }

    // Limit to 3 recent achievements
    return achievements.take(3).toList();
  }

  void _showAIAssistant(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.psychology,
                    color: WellnessColors.primaryGreen,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Assistant IA Nutritionnel',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: WellnessColors.primaryGreen,
                        ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.smart_toy,
                      size: 80,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Assistant IA bientôt disponible',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Votre coach personnel pour des conseils nutritionnels personnalisés',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
