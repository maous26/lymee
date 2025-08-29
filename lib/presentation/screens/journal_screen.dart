import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lym_nutrition/presentation/themes/fresh_theme.dart';
import 'package:lym_nutrition/core/services/gamification_service.dart';
import 'package:lym_nutrition/domain/entities/gamification_models.dart';
import 'package:lym_nutrition/presentation/screens/chat/nutrition_chat_service.dart';
import 'package:lym_nutrition/presentation/screens/food_search_screen.dart';
import 'package:lym_nutrition/presentation/screens/meal_planning_screen.dart';
import 'package:lym_nutrition/presentation/screens/recipe/create_recipe_screen.dart';
import 'package:lym_nutrition/presentation/widgets/recipe_rating_widget.dart';
import 'package:lym_nutrition/presentation/widgets/workout_rating_widget.dart';
import 'package:lym_nutrition/core/services/favorites_service.dart';
// main_app_shell import non utilisé supprimé

class JournalScreen extends StatefulWidget {
  const JournalScreen({Key? key}) : super(key: key);

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  DateTime _selected = DateTime.now();
  List<_Meal> _meals = [];
  int _calories = 0;
  int _protein = 0;
  int _carbs = 0;
  int _fat = 0;
  late GamificationService _gamificationService;

  // Only daily range is supported now
  // Reserved for future sport session integration

  // Normalize meal types coming from different sources (AI, manual, legacy)
  String _normalizeMealType(String? rawType) {
    final type = (rawType ?? '').toLowerCase().trim();
    if (type.isEmpty) return 'Autre';

    if (type.contains('petit')) return 'Petit-déjeuner';
    // Avoid matching "Petit-déjeuner"
    if (!type.contains('petit') &&
        (type.contains('dej') || type.contains('déj'))) {
      return 'Déjeuner';
    }
    if (type.contains('din') || type.contains('soir')) return 'Dîner';
    if (type.contains('coll') ||
        type.contains('en-cas') ||
        type.contains('encas') ||
        type.contains('snack')) {
      return 'En-cas';
    }
    return rawType ?? 'Autre';
  }

  @override
  void initState() {
    super.initState();
    _initializeGamification();
    _loadSportProfile();
    _loadForDate(_selected);
  }

  Future<void> _initializeGamification() async {
    final prefs = await SharedPreferences.getInstance();
    _gamificationService = GamificationService(prefs);
  }

  Future<void> _loadForDate(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    final dayKey = date.toIso8601String().split('T').first;

    print('🔍 Loading meals for date: $dayKey');

    // We now show only meals explicitly added by you. Generated plans aren't counted by défaut.
    final items = <_Meal>[];
    final seenMeals = <String>{}; // Track unique meals to avoid duplicates

    // 1. Load from unified journal source first (most reliable)
    final journalJson = prefs.getString('journal_$dayKey');

    if (journalJson != null) {
      try {
        final journalData = jsonDecode(journalJson) as Map<String, dynamic>;
        final meals = journalData['meals'] as List<dynamic>? ?? [];

        for (final mealData in meals) {
          try {
            final meal = _Meal.fromJson(mealData as Map<String, dynamic>);
            final mealId = '${meal.name}_${meal.calories}';
            if (!seenMeals.contains(mealId)) {
              items.add(meal);
              seenMeals.add(mealId);
            }
          } catch (e) {
            print('❌ Error parsing meal data: $e');
          }
        }
      } catch (e) {
        print('❌ Error parsing journal data for $dayKey: $e');
      }
    } else {}

    // 2. Load from saved daily meals if it's for today and matches the date
    final savedDailyMeals = prefs.getString('saved_daily_meals');
    final savedDailyDate = prefs.getString('saved_daily_meals_date');
    if (savedDailyMeals != null && savedDailyDate == dayKey) {
      try {
        final List<dynamic> dailyMealsData = jsonDecode(savedDailyMeals);
        print('✅ Found ${dailyMealsData.length} saved daily meals for $dayKey');
        for (final mealData in dailyMealsData) {
          try {
            final meal = _Meal.fromJson(mealData as Map<String, dynamic>);
            final mealId = '${meal.name}_${meal.calories}';
            if (!seenMeals.contains(mealId)) {
              items.add(meal);
              seenMeals.add(mealId);
              print('📝 Added unique meal from saved daily: ${meal.name}');
            } else {
              print('⚠️ Skipped duplicate meal from saved daily: ${meal.name}');
            }
          } catch (e) {
            print('❌ Error parsing saved daily meal: $e');
          }
        }
      } catch (e) {
        print('❌ Error parsing saved daily meals: $e');
      }
    }

    // 3. Individual meals saved for that day (new key), fallback to legacy today key
    final individualByDateJson = prefs.getString('individual_meals_' + dayKey);
    if (individualByDateJson != null) {
      final map = jsonDecode(individualByDateJson);
      if (map['date'] == dayKey) {
        final List data = map['meals'];
        for (final e in data) {
          final meal = _Meal.fromJson(e);
          final mealId = '${meal.name}_${meal.calories}';
          if (!seenMeals.contains(mealId)) {
            items.add(meal);
            seenMeals.add(mealId);
            print('📝 Added unique meal from individual by date: ${meal.name}');
          } else {
            print(
                '⚠️ Skipped duplicate meal from individual by date: ${meal.name}');
          }
        }
      }
    } else {
      final individualTodayJson = prefs.getString('individual_meals_today');
      if (individualTodayJson != null) {
        final map = jsonDecode(individualTodayJson);
        if (map['date'] == dayKey) {
          final List data = map['meals'];
          for (final e in data) {
            final meal = _Meal.fromJson(e);
            final mealId = '${meal.name}_${meal.calories}';
            if (!seenMeals.contains(mealId)) {
              items.add(meal);
              seenMeals.add(mealId);
              print('📝 Added unique meal from individual today: ${meal.name}');
            } else {
              print(
                  '⚠️ Skipped duplicate meal from individual today: ${meal.name}');
            }
          }
        }
      }
    }

    int c = 0, p = 0, g = 0, f = 0;
    for (final m in items) {
      c += m.calories;
      p += m.protein;
      g += m.carbs;
      f += m.fat;
    }

    setState(() {
      _selected = date;
      _meals = items;
      _calories = c;
      _protein = p;
      _carbs = g;
      _fat = f;
    });
    await _saveJournalForDate(date, items, c, p, g, f);
  }

  Future<void> _saveJournalForDate(
      DateTime date, List<_Meal> items, int c, int p, int g, int f) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'journal_${date.toIso8601String().split('T').first}';
    // Preserve existing sports if present
    List<Map<String, dynamic>> existingSports = [];
    final existingRaw = prefs.getString(key);
    if (existingRaw != null && existingRaw.isNotEmpty) {
      try {
        final parsed = jsonDecode(existingRaw) as Map<String, dynamic>;
        existingSports = ((parsed['sports'] as List?) ?? [])
            .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e))
            .toList();
      } catch (_) {}
    }
    await prefs.setString(
        key,
        jsonEncode({
          'calories': c,
          'protein': p,
          'carbs': g,
          'fat': f,
          'meals': items.map((e) => e.toJson()).toList(),
          'sports': existingSports,
        }));
    final indexRaw = prefs.getString('journal_index');
    final Set<String> index = indexRaw != null
        ? (Set<String>.from(jsonDecode(indexRaw)))
        : <String>{};
    index.add(key);
    await prefs.setString('journal_index', jsonEncode(index.toList()));
  }

  Future<void> _loadSportProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('sport_profile');
    if (raw != null) {
      // Reserved: sport profile parsed but not yet displayed in this screen
      try {
        jsonDecode(raw);
      } catch (_) {}
    }
  }

  /// Sauvegarde la recette générée dans le stockage local
  Future<void> _saveRecipeToStorage(_Meal meal) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dateKey = _selected.toIso8601String().split('T').first;
      final journalKey = 'journal_$dateKey';

      // Récupérer les données actuelles du journal
      final existingData = prefs.getString(journalKey);
      if (existingData != null) {
        final journalData = jsonDecode(existingData) as Map<String, dynamic>;
        final meals =
            List<Map<String, dynamic>>.from(journalData['meals'] ?? []);

        // Trouver et mettre à jour le repas correspondant
        for (int i = 0; i < meals.length; i++) {
          final mealData = meals[i];
          if (mealData['name'] == meal.name &&
              mealData['calories'] == meal.calories &&
              mealData['protein'] == meal.protein) {
            mealData['recipe'] = meal.recipe;
            break;
          }
        }

        // Sauvegarder les données mises à jour
        journalData['meals'] = meals;
        await prefs.setString(journalKey, jsonEncode(journalData));
      }
    } catch (e) {
      print('Erreur lors de la sauvegarde de la recette: $e');
    }
  }

  /// Vérifier si un repas est dans les favoris
  Future<bool> _isMealInFavorites(_Meal meal) async {
    try {
      final favorites = await FavoritesService.getFavorites();
      final recipeId = 'recipe_${meal.name.replaceAll(' ', '_').toLowerCase()}';
      return favorites
          .any((item) => item.id == recipeId && item.source == 'recipe');
    } catch (e) {
      return false;
    }
  }

  /// Basculer l'état favori d'un repas
  Future<void> _toggleMealFavorites(_Meal meal) async {
    final isFavorite = await _isMealInFavorites(meal);

    if (isFavorite) {
      // Retirer des favoris
      await _removeMealFromFavorites(meal);
    } else {
      // Ajouter aux favoris
      await _addMealToFavorites(meal);
    }

    // Forcer le rebuild pour mettre à jour l'icône
    setState(() {});
  }

  /// Retirer un repas des favoris
  Future<void> _removeMealFromFavorites(_Meal meal) async {
    try {
      final favorites = await FavoritesService.getFavorites();
      final recipeId = 'recipe_${meal.name.replaceAll(' ', '_').toLowerCase()}';
      final mealToRemove = favorites.firstWhere(
        (item) => item.id == recipeId && item.source == 'recipe',
        orElse: () => throw Exception('Repas non trouvé dans les favoris'),
      );

      await FavoritesService.removeFromFavorites(mealToRemove);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${meal.name} retiré des favoris'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  /// Ajouter un repas aux favoris
  Future<void> _addMealToFavorites(_Meal meal) async {
    try {
      // Générer la recette si elle n'existe pas
      String recipeContent = meal.recipe ?? '';
      if (recipeContent.isEmpty) {
        // Générer la recette en arrière-plan
        final service = NutritionChatService();
        final prompt = 'Recette détaillée en français pour ${meal.name}. '
            'Objectif ~${meal.calories} kcal, ${meal.protein}g protéines, '
            '${meal.carbs}g glucides, ${meal.fat}g lipides. '
            'Format: **Ingrédients:** (quantités précises), **Instructions:** (étapes numérotées), **Conseils:** (optionnel).';

        try {
          recipeContent = await service.getAnswer([
            {'role': 'user', 'content': prompt}
          ]);
          // Sauvegarder la recette dans le cache du meal
          meal.recipe = recipeContent;
          await _saveRecipeToStorage(meal);
        } catch (e) {
          recipeContent = 'Recette pour ${meal.name}';
        }
      }

      final success = await FavoritesService.addRecipeToFavorites(
        recipeName: meal.name,
        recipeContent: recipeContent,
        calories: meal.calories.toDouble(),
        proteins: meal.protein.toDouble(),
        carbs: meal.carbs.toDouble(),
        fats: meal.fat.toDouble(),
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${meal.name} ajouté aux favoris'),
            backgroundColor: FreshTheme.primaryMint,
            duration: const Duration(seconds: 2),
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ce repas est déjà dans vos favoris'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _viewRecipe(_Meal meal) async {
    String? recipe = meal.recipe;

    // Si la recette n'existe pas encore, la générer
    if (recipe == null || recipe.isEmpty) {
      final service = NutritionChatService();

      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Génération de la recette...'),
                ],
              ),
            ),
          ),
        ),
      );

      try {
        // Générer une nouvelle recette
        final prompt = 'Recette détaillée en français pour ${meal.name}. '
            'Objectif ~${meal.calories} kcal, ${meal.protein}g protéines, '
            '${meal.carbs}g glucides, ${meal.fat}g lipides. '
            'Format: **Ingrédients:** (quantités précises), **Instructions:** (étapes numérotées), **Conseils:** (optionnel).';
        recipe = await service.getAnswer([
          {'role': 'user', 'content': prompt}
        ]);

        // Sauvegarder la recette dans le cache du meal
        meal.recipe = recipe;
        await _saveRecipeToStorage(meal);
      } catch (e) {
        recipe = 'Erreur lors du chargement de la recette: $e';
      }

      // Close loading dialog
      if (!mounted) return;
      Navigator.of(context).pop();
    }

    // Show recipe dialog
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) {
        final maxHeight = MediaQuery.of(context).size.height * 0.9;
        return Dialog(
          child: Container(
            constraints: BoxConstraints(maxWidth: 600, maxHeight: maxHeight),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header image removed (no external images)

                // Recipe content
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          meal.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          recipe ?? 'Aucune recette disponible',
                          style: const TextStyle(fontSize: 14, height: 1.5),
                        ),

                        // Widget de notation ML
                        if (recipe != null &&
                            recipe.isNotEmpty &&
                            recipe != 'Aucune recette disponible') ...[
                          const SizedBox(height: 20),
                          RecipeRatingWidget(
                            recipeId:
                                '${meal.name}_${DateTime.now().millisecondsSinceEpoch}',
                            recipeContent: recipe,
                            onRated: () {
                              // Optionnel: Fermer automatiquement le dialog après notation
                              // Navigator.of(context).pop();
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                // Actions
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Bouton Favoris
                      ElevatedButton.icon(
                        onPressed: () async {
                          final success =
                              await FavoritesService.addRecipeToFavorites(
                            recipeName: meal.name,
                            recipeContent: recipe ?? '',
                            calories: meal.calories.toDouble(),
                            proteins: meal.protein.toDouble(),
                            carbs: meal.carbs.toDouble(),
                            fats: meal.fat.toDouble(),
                          );

                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(success
                                    ? '${meal.name} ajoutée aux favoris'
                                    : 'Déjà en favoris'),
                                backgroundColor: success
                                    ? FreshTheme.primaryMint
                                    : Colors.orange,
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.favorite_border),
                        label: const Text('Favoris'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: FreshTheme.primaryMint,
                          foregroundColor: Colors.white,
                        ),
                      ),

                      // Bouton Fermer
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Fermer'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Journal'),
        backgroundColor: FreshTheme.primaryMint,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          _buildDateNav(),
          _buildTotals(),
          const SizedBox(height: 8),
          Expanded(child: _buildMealsList()),
        ],
      ),
      // Bouton déplacé vers Coach IA
    );
  }

  Widget _buildDateNav() {
    final d = _selected;
    final label =
        '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () =>
                _loadForDate(_selected.subtract(const Duration(days: 1))),
          ),
          Column(children: [
            Text(label,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ]),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () =>
                _loadForDate(_selected.add(const Duration(days: 1))),
          ),
        ],
      ),
    );
  }

  Widget _buildTotals() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _mini('Calories', '$_calories kcal', Colors.orange),
            _mini('Protéines', '${_protein}g', Colors.blue),
            _mini('Glucides', '${_carbs}g', Colors.green),
            _mini('Lipides', '${_fat}g', Colors.red),
          ],
        ),
      ),
    );
  }

  Widget _buildMealsList() {
    // Fixed sections like the screenshot, with + buttons
    final sections = [
      'Petit-déjeuner',
      'Déjeuner',
      'Dîner',
      'En-cas',
    ];

    final byType = <String, List<_Meal>>{};
    for (final m in _meals) {
      final key = _normalizeMealType(m.mealType);
      byType.putIfAbsent(key, () => []).add(m);
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      children: [
        ...sections.map((section) {
          final items = byType[section] ?? [];
          final targetMap = {
            'Petit-déjeuner': 543,
            'Déjeuner': 724,
            'Dîner': 453,
            'En-cas': 91,
          };
          final target = targetMap[section] ?? 0;
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            section == 'Petit-déjeuner'
                                ? Icons.coffee
                                : section == 'Déjeuner'
                                    ? Icons.rice_bowl
                                    : section == 'Dîner'
                                        ? Icons.dinner_dining
                                        : Icons.apple,
                            color: FreshTheme.primaryMint,
                          ),
                          const SizedBox(width: 8),
                          Text(section,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                      Row(children: [
                        Text('${items.length} / ${target} kcal',
                            style: const TextStyle(fontSize: 12)),
                        const SizedBox(width: 8),
                        if (items.isNotEmpty)
                          IconButton(
                            icon: const Icon(Icons.clear_all,
                                color: Colors.red, size: 20),
                            tooltip: 'Supprimer tous',
                            onPressed: () {
                              print(
                                  '🎯 Button pressed for section: "$section" with ${items.length} items');
                              _confirmDeleteAllMeals(section, items);
                            },
                          ),
                        IconButton(
                          icon:
                              const Icon(Icons.add_circle, color: Colors.blue),
                          tooltip: 'Ajouter',
                          onPressed: () {
                            Navigator.of(context)
                                .push(MaterialPageRoute(
                              builder: (_) => FoodSearchScreen(
                                targetDate: _selected,
                              ),
                            ))
                                .then((result) {
                              // Only reload if an item was actually added (result is true)
                              if (result == true) {
                                _loadForDate(_selected);
                              }
                            });
                          },
                        ),
                      ])
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (items.isEmpty)
                    const Text('Aucun élément',
                        style: TextStyle(fontSize: 12, color: Colors.grey))
                  else
                    ...items.asMap().entries.map((entry) {
                      final index = entry.key;
                      final m = entry.value;
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(m.name),
                        subtitle: Text(
                            '${m.calories} kcal • P ${m.protein}g • G ${m.carbs}g • L ${m.fat}g'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextButton(
                              onPressed: () => _viewRecipe(m),
                              child: const Text('Recette',
                                  style: TextStyle(fontSize: 12)),
                            ),
                            FutureBuilder<bool>(
                                future: _isMealInFavorites(m),
                                builder: (context, snapshot) {
                                  final isFavorite = snapshot.data ?? false;
                                  return IconButton(
                                    icon: Icon(
                                      isFavorite
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      color: isFavorite
                                          ? Colors.red
                                          : FreshTheme.primaryMint,
                                      size: 20,
                                    ),
                                    onPressed: () => _toggleMealFavorites(m),
                                    tooltip: isFavorite
                                        ? 'Retirer des favoris'
                                        : 'Ajouter aux favoris',
                                  );
                                }),
                            IconButton(
                              icon: const Icon(Icons.delete_outline,
                                  color: Colors.red, size: 20),
                              onPressed: () => _deleteMeal(m, section, index),
                              tooltip: 'Supprimer',
                            ),
                          ],
                        ),
                      );
                    })
                ],
              ),
            ),
          );
        }).toList(),

        const SizedBox(height: 12),
        // Section "Générer le plan du jour"
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.auto_awesome, color: Colors.purple),
                    SizedBox(width: 8),
                    Text('Générer le plan du jour',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                    "Générer automatiquement vos repas du jour selon votre profil et vos calories restantes."),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context)
                          .push(
                            MaterialPageRoute(
                              builder: (_) => MealPlanningScreen(
                                targetDate: _selected,
                                initialPlanType: PlanType.daily,
                                aiOnlyMode: true,
                              ),
                            ),
                          )
                          .then((_) => _loadForDate(_selected));
                    },
                    icon: const Icon(Icons.auto_awesome),
                    label: const Text('Générer le plan du jour'),
                  ),
                )
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.date_range, color: Colors.teal),
                    SizedBox(width: 8),
                    Text('Planifier les repas des 7 prochains jours',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                    "Générer automatiquement vos repas de la semaine selon votre profil."),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => MealPlanningScreen(
                            targetDate: _selected,
                            initialPlanType: PlanType.weekly,
                            weeklyModeOnly: true,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.auto_awesome),
                    label: const Text('Planifier la semaine'),
                  ),
                )
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Section "Créer une recette"
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.menu_book, color: Colors.orange),
                    SizedBox(width: 8),
                    Text('Créer une recette',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                    "Partagez votre créativité culinaire avec la communauté. Utilisez la reconnaissance vocale pour décrire votre recette et générez une image appétissante."),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const CreateRecipeScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add_circle),
                    label: const Text('Créer une recette'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Section "Séances de sport" - déplacée juste avant Hydratation
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.fitness_center, color: Colors.teal),
                    SizedBox(width: 8),
                    Text('Séances de sport',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
                const SizedBox(height: 8),
                // Action: saisie manuelle uniquement
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton.icon(
                    onPressed: () => _showAddSportManualDialog(),
                    icon: const Icon(Icons.add),
                    label: const Text('Ajouter une séance'),
                  ),
                ),
                const SizedBox(height: 8),
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: _loadSportsForSelectedDay(),
                  builder: (context, snapshot) {
                    final sports = snapshot.data ?? [];
                    if (sports.isEmpty) {
                      return const Text('Aucune séance',
                          style: TextStyle(fontSize: 12, color: Colors.grey));
                    }
                    return Column(
                      children: sports.asMap().entries.map((entry) {
                        final index = entry.key;
                        final s = entry.value;
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.fitness_center, size: 20),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${s['type']} • ${s['duration']} min',
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w600),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            '${s['calories']} kcal brûlées',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Wrap(
                                    spacing: 4,
                                    runSpacing: 4,
                                    alignment: WrapAlignment.end,
                                    children: [
                                      // Bouton pour voir les détails et noter la séance
                                      TextButton.icon(
                                        onPressed: () =>
                                            _showWorkoutDetailsDialog(s),
                                        icon: const Icon(Icons.star_rate),
                                        label: const Text('Noter & Détails'),
                                      ),
                                      TextButton.icon(
                                        onPressed: () =>
                                            _askLymeeForWorkout(context, s),
                                        icon: const Icon(Icons.auto_awesome),
                                        label: const Text('Générer une séance'),
                                      ),
                                      // suppression uniquement sur la ligne de la séance, pas à côté du bouton IA
                                      IconButton(
                                        tooltip: 'Supprimer',
                                        icon: const Icon(Icons.delete_outline,
                                            color: Colors.red),
                                        onPressed: () => _deleteSportAt(index),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                )
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: const [
                  Icon(Icons.opacity, color: Colors.teal),
                  SizedBox(width: 8),
                  Text('Hydratation',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ]),
                const SizedBox(height: 8),
                _HydrationTracker(date: _selected),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<List<Map<String, dynamic>>> _loadSportsForSelectedDay() async {
    final prefs = await SharedPreferences.getInstance();
    final dayKey = _selected.toIso8601String().split('T').first;
    final raw = prefs.getString('journal_' + dayKey);
    if (raw == null) return [];
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final allSports = (map['sports'] as List? ?? [])
          .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e))
          .toList();

      // Filter out auto-generated generic sessions
      return allSports.where((s) {
        final type = (s['type'] ?? '').toString();
        final text = (s['text'] ?? '').toString();
        // Remove generic "Séance" or auto-generated workout plans
        return !(type == 'Séance' ||
            type == 'Sport' ||
            text.contains('Séance du jour') ||
            text.contains('Objectif:') && text.contains('tours:'));
      }).toList();
    } catch (_) {
      return [];
    }
  }

  void _showWorkoutDetailsDialog(Map<String, dynamic> workout) {
    final content = workout['content']?.toString() ?? '';
    final hasDetailedContent = content.isNotEmpty;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.fitness_center, color: Colors.blue),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${workout['type']} • ${workout['duration']} min',
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
        content: Container(
          width: double.maxFinite,
          constraints: const BoxConstraints(maxHeight: 500),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Informations de la séance
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.local_fire_department,
                          color: Colors.orange, size: 16),
                      const SizedBox(width: 4),
                      Text('${workout['calories']} kcal brûlées'),
                      const Spacer(),
                      const Icon(Icons.timer, color: Colors.blue, size: 16),
                      const SizedBox(width: 4),
                      Text('${workout['duration']} minutes'),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Contenu de la séance (si disponible)
                if (hasDetailedContent) ...[
                  Text(
                    content,
                    style: const TextStyle(fontSize: 14, height: 1.5),
                  ),
                  const SizedBox(height: 20),
                ] else ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.fitness_center,
                            size: 48, color: Colors.grey),
                        const SizedBox(height: 8),
                        Text(
                          'Séance de ${workout['type']}',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const Text(
                          'Séance manuelle ajoutée',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // Widget de notation ML pour TOUTES les séances
                WorkoutRatingWidget(
                  workoutId:
                      '${workout['type']}_${workout['duration']}_${DateTime.now().millisecondsSinceEpoch}',
                  workoutContent: hasDetailedContent
                      ? content
                      : 'Séance de ${workout['type']} - ${workout['duration']} minutes',
                  workoutType: workout['type']?.toString() ?? 'Sport',
                  duration: workout['duration'] ?? 30,
                  intensity: workout['intensity'] ?? 1,
                  onRated: () {
                    // Optionnel: Fermer automatiquement le dialog après notation
                    // Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        ),

        // Actions
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteMeal(_Meal meal, String mealType, int index) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le repas'),
        content: Text('Êtes-vous sûr de vouloir supprimer "${meal.name}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _performMealDeletion(meal);
    }
  }

  Future<void> _confirmDeleteAllMeals(
      String mealType, List<_Meal> meals) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer tous les repas'),
        content: Text(
            'Êtes-vous sûr de vouloir supprimer tous les ${meals.length} repas de "$mealType" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer tout'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _performDeleteAllMeals(mealType, meals);
    }
  }

  Future<void> _performDeleteAllMeals(
      String mealType, List<_Meal> visibleMeals) async {
    final prefs = await SharedPreferences.getInstance();
    final dayKey = _selected.toIso8601String().split('T').first;

    print(
        '🗑️ FORCE DELETING ALL ${visibleMeals.length} meals of type "$mealType" for date $dayKey');
    print('📋 Meals to delete:');
    for (final meal in visibleMeals) {
      print('  - ${meal.name} (${meal.mealType})');
    }

    // NUCLEAR OPTION: Clear EVERYTHING for this meal type on this date
    int deletedCount = visibleMeals.length;

    // Build a fast set of identifiers based on the visible list
    final toDeleteIds =
        visibleMeals.map((m) => '${m.name}_${m.calories}').toSet();
    final normalizedTarget = _normalizeMealType(mealType);

    print('🧹 Clearing from all possible sources for mealType: "$mealType"');

    // 1. Force clear from saved daily meals
    final savedDailyJson = prefs.getString('saved_daily_meals');
    final savedDailyDate = prefs.getString('saved_daily_meals_date');

    if (savedDailyJson != null && savedDailyDate != null) {
      final savedDateKey = savedDailyDate.contains('T')
          ? savedDailyDate.split('T').first
          : savedDailyDate;

      if (savedDateKey == dayKey) {
        try {
          final List<dynamic> savedMeals = jsonDecode(savedDailyJson);
          final originalCount = savedMeals.length;

          // Remove meals matching either normalized type or identifier in visible list
          savedMeals.removeWhere((m) {
            final mType = _normalizeMealType(m['mealType']?.toString());
            final id = '${m['name'] ?? ''}_${m['calories'] ?? 0}';
            return mType == normalizedTarget || toDeleteIds.contains(id);
          });

          final removedFromSaved = originalCount - savedMeals.length;

          // Save updated list
          await prefs.setString('saved_daily_meals', jsonEncode(savedMeals));
          print('🗑️ Removed $removedFromSaved meals from saved daily meals');
        } catch (e) {
          print('❌ Error updating saved daily meals: $e');
        }
      }
    }

    // 2. Remove from individual meals if present (today key)
    final individualJson = prefs.getString('individual_meals_today');
    if (individualJson != null) {
      try {
        final map = jsonDecode(individualJson);
        if (map['date'] == dayKey) {
          final List<dynamic> individualMeals = map['meals'];
          final originalCount = individualMeals.length;

          // Remove by normalized type or identifier
          individualMeals.removeWhere((m) {
            final mType = _normalizeMealType(m['mealType']?.toString());
            final id = '${m['name'] ?? ''}_${m['calories'] ?? 0}';
            return mType == normalizedTarget || toDeleteIds.contains(id);
          });

          final removedFromIndividual = originalCount - individualMeals.length;

          // Save updated list
          await prefs.setString(
              'individual_meals_today',
              jsonEncode({
                'date': dayKey,
                'meals': individualMeals,
              }));
          print(
              '🗑️ Removed $removedFromIndividual meals from individual meals');
        }
      } catch (e) {
        print('❌ Error updating individual meals: $e');
      }
    }

    // 2b. Remove from individual meals by-date key
    final individualByDateKey = 'individual_meals_' + dayKey;
    final individualByDateJson = prefs.getString(individualByDateKey);
    if (individualByDateJson != null) {
      try {
        final map = jsonDecode(individualByDateJson);
        if (map['date'] == dayKey) {
          final List<dynamic> individualMeals = map['meals'];
          final originalCount = individualMeals.length;

          individualMeals.removeWhere((m) {
            final mType = _normalizeMealType(m['mealType']?.toString());
            final id = '${m['name'] ?? ''}_${m['calories'] ?? 0}';
            return mType == normalizedTarget || toDeleteIds.contains(id);
          });

          final removedFromIndividual = originalCount - individualMeals.length;
          await prefs.setString(individualByDateKey,
              jsonEncode({'date': dayKey, 'meals': individualMeals}));
          print(
              '🗑️ Removed $removedFromIndividual meals from $individualByDateKey');
        }
      } catch (e) {
        print('❌ Error updating $individualByDateKey: $e');
      }
    }

    // 3. Remove from journal (main source)
    final journalKey = 'journal_$dayKey';
    final journalJson = prefs.getString(journalKey);
    if (journalJson != null) {
      try {
        final journalData = jsonDecode(journalJson) as Map<String, dynamic>;
        final journalMeals =
            List<Map<String, dynamic>>.from(journalData['meals'] ?? []);
        final originalCount = journalMeals.length;

        print('📊 Journal before deletion: $originalCount meals');
        for (final meal in journalMeals) {
          final mealId = '${meal['name'] ?? ''}_${meal['calories'] ?? 0}';
          final actualType = meal['mealType'] ?? 'null';
          print('  - Journal meal: $mealId (type: "$actualType")');
          print(
              '    🔍 Target type: "$mealType" | Match: ${actualType == mealType}');
        }

        // Remove by normalized type or identifier
        journalMeals.removeWhere((m) {
          final mType = _normalizeMealType((m['mealType'] ?? '').toString());
          final id = '${m['name'] ?? ''}_${m['calories'] ?? 0}';
          final willDelete =
              mType == normalizedTarget || toDeleteIds.contains(id);
          print(
              '🔍 Checking meal: ${m['name']} (type: $mType, id: $id) -> ${willDelete ? "DELETE" : "KEEP"}');
          return willDelete;
        });

        deletedCount = originalCount - journalMeals.length;
        print(
            '📊 Journal after deletion: ${journalMeals.length} meals (deleted: $deletedCount)');

        // Recalculate totals
        double totalCalories = 0;
        double totalProtein = 0;
        double totalCarbs = 0;
        double totalFat = 0;

        for (final m in journalMeals) {
          totalCalories += (m['calories'] ?? 0).toDouble();
          totalProtein += (m['protein'] ?? 0).toDouble();
          totalCarbs += (m['carbs'] ?? 0).toDouble();
          totalFat += (m['fat'] ?? 0).toDouble();
        }

        // Update journal data
        journalData['calories'] = totalCalories.round();
        journalData['protein'] = totalProtein.round();
        journalData['carbs'] = totalCarbs.round();
        journalData['fat'] = totalFat.round();
        journalData['meals'] = journalMeals;

        // Save updated journal
        await prefs.setString(journalKey, jsonEncode(journalData));
        print('🗑️ Removed $deletedCount meals from journal');
      } catch (e) {
        print('❌ Error updating journal: $e');
      }
    }

    // Reload the screen to reflect changes
    print('🔄 Reloading meals after deletion...');
    await _loadForDate(_selected);
    print('🔄 After reload: ${_meals.length} meals loaded');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$deletedCount repas de "$mealType" supprimés'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );

    print('✅ Successfully deleted $deletedCount meals of type "$mealType"');
  }

  Future<void> _performMealDeletion(_Meal meal) async {
    final prefs = await SharedPreferences.getInstance();
    final dayKey = _selected.toIso8601String().split('T').first;

    // Remove from saved daily meals if present
    final savedDailyJson = prefs.getString('saved_daily_meals');
    final savedDailyDate = prefs.getString('saved_daily_meals_date');

    if (savedDailyJson != null && savedDailyDate != null) {
      final savedDateKey = savedDailyDate.contains('T')
          ? savedDailyDate.split('T').first
          : savedDailyDate;

      if (savedDateKey == dayKey) {
        final List<dynamic> meals = jsonDecode(savedDailyJson);
        // Remove the meal that matches name and calories
        meals.removeWhere((m) =>
            m['name'] == meal.name &&
            (m['calories'] ?? 0).toInt() == meal.calories);

        // Save updated list
        await prefs.setString('saved_daily_meals', jsonEncode(meals));
        print('🗑️ Removed meal from saved daily meals');
      }
    }

    // Remove from individual meals if present
    final individualJson = prefs.getString('individual_meals_today');
    if (individualJson != null) {
      final map = jsonDecode(individualJson);
      if (map['date'] == dayKey) {
        final List<dynamic> meals = map['meals'];
        // Remove the meal that matches name and calories
        meals.removeWhere((m) =>
            m['name'] == meal.name &&
            (m['calories'] ?? 0).toInt() == meal.calories);

        // Save updated list
        await prefs.setString(
            'individual_meals_today',
            jsonEncode({
              'date': dayKey,
              'meals': meals,
            }));
        print('🗑️ Removed meal from individual meals');
      }
    }

    // Remove from individual meals by specific date key
    final individualByDateKey = 'individual_meals_' + dayKey;
    final individualByDateJson = prefs.getString(individualByDateKey);
    if (individualByDateJson != null) {
      try {
        final map = jsonDecode(individualByDateJson);
        if (map['date'] == dayKey) {
          final List<dynamic> meals = map['meals'];
          meals.removeWhere((m) =>
              m['name'] == meal.name &&
              (m['calories'] ?? 0).toInt() == meal.calories);
          await prefs.setString(individualByDateKey,
              jsonEncode({'date': dayKey, 'meals': meals}));
          print('🗑️ Removed meal from $individualByDateKey');
        }
      } catch (e) {
        print('❌ Error updating $individualByDateKey: $e');
      }
    }

    // Remove from unified journal for that date
    final journalKey = 'journal_' + dayKey;
    final journalJson = prefs.getString(journalKey);
    if (journalJson != null) {
      try {
        final journalData = jsonDecode(journalJson) as Map<String, dynamic>;
        final journalMeals =
            List<Map<String, dynamic>>.from(journalData['meals'] ?? []);
        // Remove by name + calories (and type if present)
        journalMeals.removeWhere((m) =>
            (m['name'] == meal.name) &&
            ((m['calories'] ?? 0).toInt() == meal.calories));

        // Recalculate totals
        double totalCalories = 0;
        double totalProtein = 0;
        double totalCarbs = 0;
        double totalFat = 0;
        for (final m in journalMeals) {
          totalCalories += (m['calories'] ?? 0).toDouble();
          totalProtein += (m['protein'] ?? 0).toDouble();
          totalCarbs += (m['carbs'] ?? 0).toDouble();
          totalFat += (m['fat'] ?? 0).toDouble();
        }

        journalData['calories'] = totalCalories.round();
        journalData['protein'] = totalProtein.round();
        journalData['carbs'] = totalCarbs.round();
        journalData['fat'] = totalFat.round();
        journalData['meals'] = journalMeals;

        await prefs.setString(journalKey, jsonEncode(journalData));
        print('🗑️ Removed meal from journal');
      } catch (e) {
        print('❌ Error updating journal for deletion: $e');
      }
    }

    // Reload the screen to reflect changes
    await _loadForDate(_selected);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${meal.name} supprimé'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Widget _mini(String label, String value, Color color) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  // Note: UI for adding sport sessions is now handled via the Coach IA or future dedicated screen.

  Future<void> _showAddSportManualDialog() async {
    String? sport;
    int duration = 30;
    int intensity = 1; // 0..3
    final TextEditingController customCtrl = TextEditingController();
    // plus de case à cocher; IA via bouton séparé

    final added = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: const Text('Ajouter une séance de sport'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Type de sport'),
                const SizedBox(height: 8),
                Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      'Course à pied',
                      'Natation',
                      'Cyclisme',
                      'Musculation',
                      'Yoga',
                      'HIIT',
                      'Autre',
                    ].map((name) {
                      final selected = sport == name;
                      return ChoiceChip(
                        label: Text(name),
                        selected: selected,
                        onSelected: (v) {
                          setStateDialog(() => sport = name);
                        },
                      );
                    }).toList()),
                const SizedBox(height: 10),
                if (sport == 'Autre')
                  TextField(
                    controller: customCtrl,
                    decoration: const InputDecoration(
                      isDense: true,
                      border: OutlineInputBorder(),
                      hintText: 'Renseigner le sport',
                    ),
                  ),
                const SizedBox(height: 12),
                const Text('Durée (min)'),
                Slider(
                  value: duration.toDouble(),
                  min: 10,
                  max: 180,
                  divisions: 34,
                  label: '$duration',
                  onChanged: (v) => setStateDialog(() => duration = v.toInt()),
                ),
                const SizedBox(height: 8),
                const Text('Intensité'),
                Slider(
                  value: intensity.toDouble(),
                  min: 0,
                  max: 3,
                  divisions: 3,
                  label: ['Faible', 'Modérée', 'Élevée', 'Extrême'][intensity],
                  onChanged: (v) => setStateDialog(() => intensity = v.toInt()),
                ),
                const SizedBox(height: 4),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () async {
                String? type = sport;
                if (type == 'Autre') {
                  type = customCtrl.text.trim().isEmpty
                      ? null
                      : customCtrl.text.trim();
                }
                if (type == null || type.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Veuillez sélectionner un sport'),
                    ),
                  );
                  return;
                }

                final content = '**$type – $duration min**\nIntensité: ${[
                  'Faible',
                  'Modérée',
                  'Élevée',
                  'Extrême'
                ][intensity]}';
                print('📝 Manual workout saved: $content');
                await NutritionChatService()
                    .saveWorkoutContent(content, day: _selected);

                // Récompense Lyms pour la séance de sport
                try {
                  final lymsEarned =
                      await _gamificationService.awardWorkoutLyms(duration);
                  if (mounted && lymsEarned > 0) {
                    _showLymsReward(
                        '+${lymsEarned} 💎', 'Séance de sport ajoutée !');
                  }
                } catch (e) {
                  print(
                      'Erreur lors de l\'attribution des Lyms pour le sport: $e');
                }

                if (mounted) Navigator.of(context).pop(true);
                await _loadForDate(_selected);
              },
              child: const Text('Ajouter'),
            ),
          ],
        ),
      ),
    );

    if (added == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Séance ajoutée')),
      );
    }
  }

  Future<void> _askLymeeForWorkout(
      BuildContext context, Map<String, dynamic> seed) async {
    String type = (seed['type'] ?? 'Musculation').toString();
    int duration = (seed['duration'] ?? 30) is int ? seed['duration'] : 30;
    int intensity = 1;
    int level =
        1; // Niveau utilisateur (0=Débutant, 1=Intermédiaire, 2=Avancé, 3=Expert)

    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: const Text('Générer une séance'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sport: $type',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              Row(children: [
                const Text('Intensité'),
                Expanded(
                  child: Slider(
                    value: intensity.toDouble(),
                    min: 0,
                    max: 3,
                    divisions: 3,
                    label: [
                      'Faible',
                      'Modérée',
                      'Élevée',
                      'Extrême'
                    ][intensity],
                    onChanged: (v) =>
                        setStateDialog(() => intensity = v.toInt()),
                  ),
                )
              ]),
              const SizedBox(height: 16),
              Row(children: [
                const Text('Niveau'),
                Expanded(
                  child: Slider(
                    value: level.toDouble(),
                    min: 0,
                    max: 3,
                    divisions: 3,
                    label: [
                      'Débutant',
                      'Intermédiaire',
                      'Avancé',
                      'Expert'
                    ][level],
                    onChanged: (v) => setStateDialog(() => level = v.toInt()),
                  ),
                )
              ]),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Annuler')),
            ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Générer')),
          ],
        ),
      ),
    );

    if (ok == true) {
      print('🔥 USER CLICKED GENERATE - Starting AI workout generation');
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Génération de votre séance...'),
                ],
              ),
            ),
          ),
        ),
      );

      try {
        final svc = NutritionChatService();

        print(
            '🔥 GENERATING WORKOUT: $type, ${duration}min, intensity $intensity, level $level');
        final content =
            await svc.generateWorkoutSession(type, duration, intensity, level);

        print('🤖 AI Response length: ${content.length} chars');
        print(
            '🤖 AI Response preview: ${content.length > 100 ? content.substring(0, 100) + "..." : content}');

        if (content.isNotEmpty) {
          await svc.saveWorkoutContent(content,
              day: _selected, type: type, duration: duration);
          await _loadForDate(_selected);

          // Close loading dialog
          if (mounted) Navigator.of(context).pop();

          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Séance de $type générée avec succès!'),
              backgroundColor: Colors.green,
              action: SnackBarAction(
                label: 'Voir Dashboard',
                onPressed: () => Navigator.of(context).pushNamed('/dashboard'),
              ),
            ),
          );
        } else {
          throw Exception('Contenu vide généré par l\'IA');
        }
      } catch (e) {
        // Close loading dialog
        if (mounted) Navigator.of(context).pop();

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la génération: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteSportAt(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final dayKey = _selected.toIso8601String().split('T').first;
    final key = 'journal_' + dayKey;
    final raw = prefs.getString(key);
    if (raw == null) return;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final sports = List<Map<String, dynamic>>.from(map['sports'] ?? []);
      if (index >= 0 && index < sports.length) {
        sports.removeAt(index);
        map['sports'] = sports;
        await prefs.setString(key, jsonEncode(map));
        await _loadForDate(_selected);
      }
    } catch (_) {}
  }

  void _showLymsReward(String title, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Text('🎉', style: TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
        backgroundColor: FreshTheme.primaryMint,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}

class _Meal {
  final String name;
  final String? mealType;
  final int calories;
  final int protein;
  final int carbs;
  final int fat;
  String? recipe; // Cache pour la recette générée
  _Meal(this.name, this.mealType, this.calories, this.protein, this.carbs,
      this.fat,
      {this.recipe});
  factory _Meal.fromJson(Map<String, dynamic> json) => _Meal(
        json['name'] ?? json['mealType'] ?? 'Repas',
        json['mealType'],
        (json['calories'] ?? 0).toInt(),
        (json['protein'] ?? 0).toInt(),
        (json['carbs'] ?? 0).toInt(),
        (json['fat'] ?? 0).toInt(),
        recipe: json['recipe'],
      );
  Map<String, dynamic> toJson() => {
        'name': name,
        'mealType': mealType,
        'calories': calories,
        'protein': protein,
        'carbs': carbs,
        'fat': fat,
        'recipe': recipe,
      };
}

class _HydrationTracker extends StatefulWidget {
  final DateTime date;
  const _HydrationTracker({required this.date});

  @override
  State<_HydrationTracker> createState() => _HydrationTrackerState();
}

class _HydrationTrackerState extends State<_HydrationTracker> {
  int _ml = 0;

  late GamificationService _gamificationService;

  @override
  void initState() {
    super.initState();
    _initializeGamification();
    _load();
  }

  Future<void> _initializeGamification() async {
    final prefs = await SharedPreferences.getInstance();
    _gamificationService = GamificationService(prefs);
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final dateKey = widget.date.toIso8601String().split('T').first;
    final journalKey = 'journal_$dateKey';
    final waterKey = 'water_$dateKey';

    // Try to load from journal data first (new system)
    final journalData = prefs.getString(journalKey);
    if (journalData != null) {
      try {
        final data = jsonDecode(journalData) as Map<String, dynamic>;
        final hydration = data['hydration'] as int?;
        if (hydration != null && hydration > 0) {
          setState(() => _ml = hydration);
          print('🚰 Loaded hydration from journal: $_ml ml');
          return;
        }
      } catch (e) {
        print('❌ Error loading hydration from journal: $e');
      }
    }

    // Fallback to old water_ key if journal doesn't have hydration data
    final waterValue = prefs.getInt(waterKey) ?? 0;
    setState(() => _ml = waterValue);
    print('🚰 Loaded hydration from legacy key: $_ml ml');

    // If we loaded from legacy key but journal exists, sync it
    if (waterValue > 0 && journalData != null) {
      try {
        final data = jsonDecode(journalData) as Map<String, dynamic>;
        data['hydration'] = waterValue;
        await prefs.setString(journalKey, jsonEncode(data));
        print('🚰 Synced hydration from legacy to journal');
      } catch (e) {
        print('❌ Error syncing hydration to journal: $e');
      }
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final dateKey = widget.date.toIso8601String().split('T').first;
    final waterKey = 'water_$dateKey';
    final today = DateTime.now().toIso8601String().split('T').first;

    // Check if this is the first hydration for today
    final previousHydration = prefs.getInt(waterKey) ?? 0;
    final isFirstHydration =
        previousHydration == 0 && _ml > 0 && dateKey == today;

    // Save to legacy water_ key for backward compatibility
    await prefs.setInt(waterKey, _ml);

    // Also save to journal data for dashboard synchronization
    await _saveToJournal();

    // Award Lyms for first hydration of the day
    if (isFirstHydration) {
      try {
        final lymsEarned =
            await _gamificationService.awardLyms(LymAction.hydration);
        if (lymsEarned > 0) {
          _showLymsReward(
              '+${lymsEarned} 💎', 'Première hydratation de la journée !');
        }
      } catch (e) {
        print(
            'Erreur lors de l\'attribution des Lyms pour la première hydratation: $e');
      }
    }
  }

  Future<void> _saveToJournal() async {
    final prefs = await SharedPreferences.getInstance();
    final dateKey = widget.date.toIso8601String().split('T').first;
    final journalKey = 'journal_$dateKey';

    print('🚰 Journal _saveToJournal():');
    print('  - Date: $dateKey');
    print('  - Journal key: $journalKey');
    print('  - Hydration value: $_ml ml');

    // Load existing journal data
    Map<String, dynamic> journalData;
    final existingData = prefs.getString(journalKey);
    if (existingData != null) {
      try {
        journalData = jsonDecode(existingData) as Map<String, dynamic>;
        print(
            '  - Loaded existing journal data with keys: ${journalData.keys.toList()}');
      } catch (e) {
        print('  - Error parsing existing data: $e, creating new');
        journalData = {
          'calories': 0,
          'protein': 0,
          'carbs': 0,
          'fat': 0,
          'meals': [],
          'sports': [],
        };
      }
    } else {
      print('  - No existing journal data, creating new');
      journalData = {
        'calories': 0,
        'protein': 0,
        'carbs': 0,
        'fat': 0,
        'meals': [],
        'sports': [],
      };
    }

    // Update hydration data
    journalData['hydration'] = _ml;
    print('  - Updated hydration in journal data: ${journalData['hydration']}');

    // Save back to SharedPreferences
    final encodedData = jsonEncode(journalData);
    await prefs.setString(journalKey, encodedData);
    print('  - Saved journal data (${encodedData.length} chars)');
    print(
        '  - Verification - keys in saved data: ${journalData.keys.toList()}');
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Aujourd\'hui: ${_ml} ml',
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  Row(
                    children: [
                      IconButton(
                        onPressed: _ml > 0
                            ? () async {
                                setState(
                                    () => _ml = (_ml - 250).clamp(0, 5000));
                                await _save();
                              }
                            : null,
                        icon: const Icon(Icons.remove_circle_outline),
                        color: FreshTheme.primaryMint,
                      ),
                      IconButton(
                        onPressed: () async {
                          setState(() => _ml = 0);
                          await _save();
                        },
                        icon: const Icon(Icons.refresh),
                        color: FreshTheme.primaryMint,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Curseur pour ajuster la quantité d'eau
              Column(
                children: [
                  Slider(
                    value: _ml.toDouble(),
                    min: 0,
                    max: 5000,
                    divisions: 20,
                    label: '${_ml} ml',
                    activeColor: FreshTheme.primaryMint,
                    inactiveColor: FreshTheme.primaryMint.withOpacity(0.3),
                    onChanged: (double value) {
                      setState(() {
                        _ml = value.round();
                      });
                    },
                    onChangeEnd: (double value) async {
                      await _save();
                      // Removed automatic Lyms reward for slider changes to avoid spam
                    },
                  ),
                  const SizedBox(height: 8),
                  // Boutons rapides pour des valeurs prédéfinies
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _quickSetButton(250),
                      _quickSetButton(500),
                      _quickSetButton(1000),
                      _quickSetButton(1500),
                      _quickSetButton(2000),
                      _quickSetButton(3000),
                    ],
                  ),
                ],
              )
            ],
          ),
        ),
        // Refresh button removed per request
      ],
    );
  }

  void _showLymsReward(String title, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Text('🎉', style: TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
        backgroundColor: FreshTheme.primaryMint,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _quickSetButton(int amount) {
    return OutlinedButton(
      onPressed: () async {
        final previousAmount = _ml;
        setState(() => _ml = amount);
        await _save();

        // Récompense Lyms seulement si c'est aujourd'hui et qu'on ajoute de l'hydratation
        final today = DateTime.now().toIso8601String().split('T').first;
        final selectedDate = widget.date.toIso8601String().split('T').first;

        if (today == selectedDate && amount > previousAmount) {
          try {
            final lymsEarned =
                await _gamificationService.awardLyms(LymAction.hydration);
            if (lymsEarned > 0) {
              _showLymsReward('+${lymsEarned} 💎', 'Hydratation augmentée !');
            }
          } catch (e) {
            print(
                'Erreur lors de l\'attribution des Lyms pour l\'hydratation: $e');
          }
        }
      },
      style: OutlinedButton.styleFrom(
        foregroundColor: FreshTheme.primaryMint,
        side: BorderSide(color: FreshTheme.primaryMint),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      child: Text('${amount} ml'),
    );
  }
}
