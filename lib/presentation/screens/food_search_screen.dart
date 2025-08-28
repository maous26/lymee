// lib/presentation/screens/food_search_screen.dart (modifié)
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lym_nutrition/domain/entities/food_item.dart';
import 'package:lym_nutrition/presentation/bloc/food_search/food_search_bloc.dart';
import 'package:lym_nutrition/presentation/bloc/food_search/food_search_event.dart';
import 'package:lym_nutrition/presentation/bloc/food_search/food_search_state.dart';
import 'package:lym_nutrition/presentation/screens/food_detail_screen.dart';
import 'package:lym_nutrition/presentation/themes/fresh_theme.dart';
import 'package:lym_nutrition/core/services/gamification_service.dart';
import 'package:lym_nutrition/presentation/models/gamification_models.dart';

import 'package:lym_nutrition/presentation/widgets/animated_list_item.dart';
import 'package:lym_nutrition/presentation/widgets/animated_search_bar.dart';
import 'package:lym_nutrition/presentation/widgets/brand_filter_bar.dart';
import 'package:lym_nutrition/presentation/widgets/empty_results.dart';
import 'package:lym_nutrition/presentation/widgets/food_card.dart';
import 'package:lym_nutrition/presentation/widgets/shimmer_food_card.dart';
import 'package:lym_nutrition/core/util/ciqual_cache_manager.dart';

class FoodSearchScreen extends StatefulWidget {
  final DateTime? targetDate;
  const FoodSearchScreen({Key? key, this.targetDate}) : super(key: key);

  @override
  State<FoodSearchScreen> createState() => _FoodSearchScreenState();
}

class _FoodSearchScreenState extends State<FoodSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _brandController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final FocusNode _brandFocusNode = FocusNode();
  final bool _searchBarVisible = true;
  bool _brandFilterVisible = false;
  String _currentQuery = '';
  String _currentBrand = '';
  late GamificationService _gamificationService;

  @override
  void initState() {
    super.initState();
    _initGamification();
    // Charger l'historique au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FoodSearchBloc>().add(GetFoodHistoryEvent());
    });
  }

  Future<void> _initGamification() async {
    final prefs = await SharedPreferences.getInstance();
    _gamificationService = GamificationService(prefs);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _brandController.dispose();
    _brandFocusNode.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    setState(() {
      _currentQuery = query;
    });

    if (query.isEmpty && _currentBrand.isEmpty) {
      context.read<FoodSearchBloc>().add(GetFoodHistoryEvent());
      return;
    }

    // Use unified search with brand filter
    context.read<FoodSearchBloc>().add(
          SearchAllFoodsEvent(
            query: query,
            brand: _currentBrand.isEmpty ? null : _currentBrand,
          ),
        );
  }

  void _applyBrandFilter(String brand) {
    setState(() {
      _currentBrand = brand;
    });

    // Perform search with the current query and the new brand filter
    context.read<FoodSearchBloc>().add(
          SearchAllFoodsEvent(
            query: _currentQuery,
            brand: brand.isEmpty ? null : brand,
          ),
        );
  }

  void _clearSearch() {
    setState(() {
      _currentQuery = '';
      _currentBrand = '';
      _brandController.clear();
    });
    context.read<FoodSearchBloc>().add(GetFoodHistoryEvent());
  }

  void _toggleBrandFilter() {
    setState(() {
      _brandFilterVisible = !_brandFilterVisible;
    });
  }

  Future<void> _navigateToFoodDetail(FoodItem food) async {
    debugPrint('[NAV] Open detail for id=${food.id} source=${food.source}');
    final result = await Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (context) => FoodDetailScreen(
          foodId: food.id,
          foodSource: food.source,
        ),
      ),
    );

    if (result is Map) {
      final String mealType = (result['meal'] ?? 'Déjeuner') as String;
      final double quantity = (result['quantity'] as num?)?.toDouble() ?? 100.0;

      await _saveFoodToSelectedDate(food, mealType, quantity);

      if (mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${food.name} ajouté au journal'),
            backgroundColor: FreshTheme.primaryMint,
            duration: const Duration(seconds: 2),
          ),
        );

        // Return to Journal screen and trigger reload there
        Navigator.of(context).pop(true);
      }
    } else {
      // Still return to journal but without triggering reload
      if (mounted) {
        Navigator.of(context).pop(false);
      }
    }
  }

  Future<void> _saveFoodToSelectedDate(
      FoodItem food, String mealType, double quantity) async {
    final prefs = await SharedPreferences.getInstance();
    final dateKey = (widget.targetDate ?? DateTime.now())
        .toIso8601String()
        .split('T')
        .first;

    final int calories = (food.calories * (quantity / 100)).round();
    final int protein = (food.proteins * (quantity / 100)).round();
    final int carbs = (food.carbs * (quantity / 100)).round();
    final int fat = (food.fats * (quantity / 100)).round();

    final Map<String, dynamic> mealJson = {
      'name': food.name,
      'mealType': mealType,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
    };

    // 1) Save under individual_meals_<date>
    final keyByDate = 'individual_meals_' + dateKey;
    List<Map<String, dynamic>> mealsByDate = [];
    final existingByDate = prefs.getString(keyByDate);
    if (existingByDate != null) {
      final decoded = jsonDecode(existingByDate);
      if (decoded is Map && decoded['date'] == dateKey) {
        mealsByDate = List<Map<String, dynamic>>.from(decoded['meals'] ?? []);
      }
    }
    mealsByDate.add(mealJson);
    await prefs.setString(
      keyByDate,
      jsonEncode({'date': dateKey, 'meals': mealsByDate}),
    );

    // Maintain today legacy key
    final todayKey = DateTime.now().toIso8601String().split('T').first;
    if (dateKey == todayKey) {
      await prefs.setString(
        'individual_meals_today',
        jsonEncode({'date': todayKey, 'meals': mealsByDate}),
      );
    }

    // 2) Save into unified journal_<date>
    final journalKey = 'journal_' + dateKey;
    Map<String, dynamic> journalData = {};
    final existingJournal = prefs.getString(journalKey);
    if (existingJournal != null) {
      try {
        journalData = jsonDecode(existingJournal) as Map<String, dynamic>;
      } catch (_) {}
    }
    final journalMeals =
        List<Map<String, dynamic>>.from(journalData['meals'] ?? []);
    journalMeals.add(mealJson);

    // Recompute totals
    double totalCalories = 0, totalProtein = 0, totalCarbs = 0, totalFat = 0;
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
    journalData['sports'] = journalData['sports'] ?? [];
    await prefs.setString(journalKey, jsonEncode(journalData));

    // Award gamification points for logging a meal
    await _gamificationService.awardLyms(LymAction.mealLogged);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FreshTheme.cloudWhite,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 160,
              floating: true,
              pinned: true,
              snap: true,
              backgroundColor: FreshTheme.primaryMint,
              automaticallyImplyLeading: false,
              actions: [
                // Back button
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  tooltip: 'Retour',
                  onPressed: () => Navigator.of(context).pop(),
                ),
                // Brand filter toggle button
                IconButton(
                  icon: Icon(
                    Icons.business,
                    color: _brandFilterVisible
                        ? Colors.white
                        : Colors.white.withOpacity(0.7),
                  ),
                  tooltip: 'Filtrer par marque',
                  onPressed: _toggleBrandFilter,
                ),
                // Debug button to refresh CIQUAL cache
                IconButton(
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Actualiser les données CIQUAL',
                  onPressed: () => CiqualCacheManager.refreshCache(context),
                ),
              ],
              flexibleSpace: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      FreshTheme.primaryMint,
                      FreshTheme.primaryMintDark,
                    ],
                  ),
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final double topInset = MediaQuery.of(context).padding.top;
                    final bool isCollapsed = constraints.maxHeight < 120;
                    final double titleSize = isCollapsed ? 18 : 24;
                    return Padding(
                      padding: EdgeInsets.only(
                        left: 16,
                        right: 16,
                        bottom: 8,
                        top: topInset + 12,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Rechercher un aliment',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                    .textTheme
                                    .displayLarge
                                    ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: titleSize,
                                    ) ??
                                TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: titleSize,
                                ),
                          ),
                          if (!isCollapsed) ...[
                            const SizedBox(height: 8),
                            Text(
                              'Trouvez des informations nutritionnelles détaillées',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.copyWith(
                                        color: Colors.white.withOpacity(0.9),
                                      ) ??
                                  TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 16,
                                  ),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ];
        },
        body: Column(
          children: [
            // Barre de recherche principale
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: _searchBarVisible ? 70 : 0,
              padding: const EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: 8,
              ),
              child: AnimatedSearchBar(
                controller: _searchController,
                focusNode: _searchFocusNode,
                hintText: 'Rechercher un aliment...',
                onSearch: () => _performSearch(_searchController.text),
                onClear: _clearSearch,
                borderRadius: BorderRadius.circular(14),
              ),
            ),

            // Filtre par marque
            BrandFilterBar(
              controller: _brandController,
              focusNode: _brandFocusNode,
              onBrandFilter: _applyBrandFilter,
              onClear: () {
                _brandController.clear();
                _applyBrandFilter('');
              },
              isVisible: _brandFilterVisible,
            ),

            // Chips de filtres actifs
            if (_currentBrand.isNotEmpty)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Chip(
                      label: Text('Marque: $_currentBrand'),
                      deleteIcon: const Icon(Icons.close, size: 18),
                      onDeleted: () {
                        _brandController.clear();
                        _applyBrandFilter('');
                      },
                      backgroundColor: FreshTheme.accentCoral.withOpacity(0.1),
                      side: BorderSide(
                          color: FreshTheme.accentCoral.withOpacity(0.3)),
                    ),
                  ],
                ),
              ),

            // Contenu principal
            Expanded(
              child: BlocBuilder<FoodSearchBloc, FoodSearchState>(
                builder: (context, state) {
                  if (state is FoodSearchLoading) {
                    return ListView.builder(
                      primary: false,
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.only(
                        top: 16,
                        bottom: 24,
                        left: 16,
                        right: 16,
                      ),
                      itemCount: 5,
                      itemBuilder: (context, index) => const Padding(
                        padding: EdgeInsets.only(bottom: 8),
                        child: ShimmerFoodCard(),
                      ),
                    );
                  } else if (state is FoodSearchSuccess) {
                    if (state.foods.isEmpty) {
                      return const EmptyResults(
                        message: 'Aucun résultat trouvé',
                        submessage:
                            'Essayez avec d\'autres termes de recherche',
                        icon: Icons.search_off,
                        color: FreshTheme.primaryMint,
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.only(
                        top: 16,
                        bottom: 24,
                        left: 16,
                        right: 16,
                      ),
                      itemCount: state.foods.length,
                      itemBuilder: (context, index) {
                        final food = state.foods[index];
                        return AnimatedListItem(
                          index: index,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Material(
                              color: Colors.transparent,
                              child: FoodCard(
                                food: food,
                                onTap: () => _navigateToFoodDetail(food),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  } else if (state is FoodHistoryLoaded) {
                    if (state.historyItems.isEmpty) {
                      return const EmptyResults(
                        message: 'Aucun historique',
                        submessage: 'Les aliments consultés apparaîtront ici',
                        icon: Icons.history,
                        color: FreshTheme.primaryMint,
                      );
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 16,
                            top: 16,
                            bottom: 8,
                          ),
                          child: Text(
                            'Historique récent',
                            style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: FreshTheme.midnightGray,
                                    ) ??
                                TextStyle(
                                  // Ajout d'un fallback
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: FreshTheme.midnightGray,
                                ),
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            primary: false,
                            keyboardDismissBehavior:
                                ScrollViewKeyboardDismissBehavior.onDrag,
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.only(
                              bottom: 24,
                              left: 16,
                              right: 16,
                            ),
                            itemCount: state.historyItems.length,
                            itemBuilder: (context, index) {
                              final food = state.historyItems[index];
                              return AnimatedListItem(
                                index: index,
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: FoodCard(
                                      food: food,
                                      onTap: () => _navigateToFoodDetail(food),
                                      isHistoryItem: true,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  } else if (state is FoodSearchError) {
                    return EmptyResults(
                      message: 'Une erreur est survenue',
                      submessage: state.message,
                      icon: Icons.error_outline,
                      color: FreshTheme.accentCoral,
                      actionLabel: 'Réessayer',
                      onActionPressed: () =>
                          _performSearch(_searchController.text),
                    );
                  }

                  // État initial, afficher une invitation à rechercher
                  return const EmptyResults(
                    message: 'Recherchez un aliment',
                    submessage:
                        'Saisissez un nom d\'aliment dans la barre de recherche',
                    icon: Icons.search,
                    color: FreshTheme.primaryMint,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
