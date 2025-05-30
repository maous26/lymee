// lib/presentation/screens/food_search_screen.dart (modifié)
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lym_nutrition/domain/entities/food_item.dart';
import 'package:lym_nutrition/presentation/bloc/food_search/food_search_bloc.dart';
import 'package:lym_nutrition/presentation/bloc/food_search/food_search_event.dart';
import 'package:lym_nutrition/presentation/bloc/food_search/food_search_state.dart';
import 'package:lym_nutrition/presentation/screens/food_detail_screen.dart';
import 'package:lym_nutrition/presentation/themes/premium_theme.dart';
import 'package:lym_nutrition/presentation/widgets/animated_list_item.dart';
import 'package:lym_nutrition/presentation/widgets/animated_search_bar.dart';
import 'package:lym_nutrition/presentation/widgets/brand_filter_bar.dart';
import 'package:lym_nutrition/presentation/widgets/empty_results.dart';
import 'package:lym_nutrition/presentation/widgets/food_card.dart';
import 'package:lym_nutrition/presentation/widgets/shimmer_food_card.dart';
import 'package:lym_nutrition/core/util/ciqual_cache_manager.dart';

class FoodSearchScreen extends StatefulWidget {
  const FoodSearchScreen({Key? key}) : super(key: key);

  @override
  State<FoodSearchScreen> createState() => _FoodSearchScreenState();
}

class _FoodSearchScreenState extends State<FoodSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _brandController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final FocusNode _brandFocusNode = FocusNode();
  bool _searchBarVisible = true;
  bool _brandFilterVisible = false;
  String _currentQuery = '';
  String _currentBrand = '';

  @override
  void initState() {
    super.initState();

    // Charger l'historique au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FoodSearchBloc>().add(GetFoodHistoryEvent());
    });
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

  void _navigateToFoodDetail(FoodItem food) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FoodDetailScreen(
          foodId: food.id,
          foodSource: food.source,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 120,
              floating: true,
              pinned: true,
              snap: true,
              backgroundColor: PremiumTheme.primaryColor,
              actions: [
                // Brand filter toggle button
                IconButton(
                  icon: Icon(
                    Icons.business,
                    color: _brandFilterVisible ? Colors.white : Colors.white70,
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
              flexibleSpace: FlexibleSpaceBar(
                title: AnimatedOpacity(
                  opacity: innerBoxIsScrolled ? 1.0 : 0.0,
                  duration: PremiumTheme.animationFast,
                  child: const Text(
                    'Rechercher un aliment',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        PremiumTheme.primaryDarkColor,
                        PremiumTheme.primaryColor,
                      ],
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 16,
                      right: 16,
                      top: 60,
                      bottom: 8,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Rechercher un aliment',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Trouvez des informations nutritionnelles détaillées',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ];
        },
        body: Column(
          children: [
            // Barre de recherche principale
            AnimatedContainer(
              duration: PremiumTheme.animationMedium,
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
                borderRadius: BorderRadius.circular(PremiumTheme.borderRadiusLarge),
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
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Chip(
                      label: Text('Marque: $_currentBrand'),
                      deleteIcon: const Icon(Icons.close, size: 18),
                      onDeleted: () {
                        _brandController.clear();
                        _applyBrandFilter('');
                      },
                      backgroundColor: PremiumTheme.secondaryColor.withOpacity(0.1),
                      side: BorderSide(color: PremiumTheme.secondaryColor.withOpacity(0.3)),
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
                      padding: const EdgeInsets.only(top: 8, bottom: 16),
                      itemCount: 5,
                      itemBuilder: (context, index) => const ShimmerFoodCard(),
                    );
                  } else if (state is FoodSearchSuccess) {
                    if (state.foods.isEmpty) {
                      return EmptyResults(
                        message: 'Aucun résultat trouvé',
                        submessage:
                            'Essayez avec d\'autres termes de recherche',
                        icon: Icons.search_off,
                        color: PremiumTheme.primaryColor,
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.only(top: 8, bottom: 16),
                      itemCount: state.foods.length,
                      itemBuilder: (context, index) {
                        final food = state.foods[index];
                        return AnimatedListItem(
                          index: index,
                          child: FoodCard(
                            food: food,
                            onTap: () => _navigateToFoodDetail(food),
                          ),
                        );
                      },
                    );
                  } else if (state is FoodHistoryLoaded) {
                    if (state.historyItems.isEmpty) {
                      return EmptyResults(
                        message: 'Aucun historique',
                        submessage: 'Les aliments consultés apparaîtront ici',
                        icon: Icons.history,
                        color: PremiumTheme.primaryColor,
                      );
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 16, top: 16, bottom: 8),
                          child: Text(
                            'Historique récent',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.only(bottom: 16),
                            itemCount: state.historyItems.length,
                            itemBuilder: (context, index) {
                              final food = state.historyItems[index];
                              return AnimatedListItem(
                                index: index,
                                child: FoodCard(
                                  food: food,
                                  onTap: () => _navigateToFoodDetail(food),
                                  isHistoryItem: true,
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
                      color: PremiumTheme.error,
                      actionLabel: 'Réessayer',
                      onActionPressed: () =>
                          _performSearch(_searchController.text),
                    );
                  }

                  // État initial, afficher une invitation à rechercher
                  return EmptyResults(
                    message: 'Recherchez un aliment',
                    submessage:
                        'Saisissez un nom d\'aliment dans la barre de recherche',
                    icon: Icons.search,
                    color: PremiumTheme.primaryColor,
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