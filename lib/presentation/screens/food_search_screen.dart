// lib/presentation/screens/food_search_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lym_nutrition/domain/entities/food_item.dart';
import 'package:lym_nutrition/presentation/bloc/food_search/food_search_bloc.dart';
import 'package:lym_nutrition/presentation/bloc/food_search/food_search_event.dart';
import 'package:lym_nutrition/presentation/bloc/food_search/food_search_state.dart';
import 'package:lym_nutrition/presentation/screens/food_detail_screen.dart';
import 'package:lym_nutrition/presentation/themes/app_theme.dart';
import 'package:lym_nutrition/presentation/widgets/animated_list_item.dart';
import 'package:lym_nutrition/presentation/widgets/animated_search_bar.dart';
import 'package:lym_nutrition/presentation/widgets/empty_results.dart';
import 'package:lym_nutrition/presentation/widgets/food_card.dart';
import 'package:lym_nutrition/presentation/widgets/shimmer_food_card.dart';
import 'package:lym_nutrition/core/util/ciqual_cache_manager.dart';

class FoodSearchScreen extends StatefulWidget {
  const FoodSearchScreen({Key? key}) : super(key: key);

  @override
  State<FoodSearchScreen> createState() => _FoodSearchScreenState();
}

class _FoodSearchScreenState extends State<FoodSearchScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  late TabController _tabController;
  bool _searchBarVisible = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabChange);
    
    // Charger l'historique au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FoodSearchBloc>().add(GetFoodHistoryEvent());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    // Si on change d'onglet, exécuter la recherche avec le filtre approprié
    if (_tabController.indexIsChanging || _tabController.index != _tabController.previousIndex) {
      _performSearch(_searchController.text);
    }
  }

  void _performSearch(String query) {
    if (query.isEmpty) {
      context.read<FoodSearchBloc>().add(GetFoodHistoryEvent());
      return;
    }

    switch (_tabController.index) {
      case 0: // Tous
        context.read<FoodSearchBloc>().add(SearchAllFoodsEvent(query: query));
        break;
      case 1: // Frais
        context.read<FoodSearchBloc>().add(SearchFreshFoodsEvent(query: query));
        break;
      case 2: // Transformés
        context.read<FoodSearchBloc>().add(SearchProcessedFoodsEvent(query: query));
        break;
    }
  }

  void _clearSearch() {
    context.read<FoodSearchBloc>().add(GetFoodHistoryEvent());
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
              backgroundColor: AppTheme.primaryColor,
              actions: [
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
                  duration: AppTheme.animationFast,
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
                        AppTheme.primaryDarkColor,
                        AppTheme.primaryColor,
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
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(48),
                child: ColoredBox(
                  color: theme.scaffoldBackgroundColor,
                  child: TabBar(
                    controller: _tabController,
                    indicatorColor: AppTheme.primaryColor,
                    labelColor: AppTheme.primaryColor,
                    unselectedLabelColor: theme.colorScheme.onSurface.withOpacity(0.7),
                    tabs: const [
                      Tab(text: 'Tous'),
                      Tab(text: 'Frais'),
                      Tab(text: 'Transformés'),
                    ],
                  ),
                ),
              ),
            ),
          ];
        },
        body: Column(
          children: [
            // Barre de recherche
            AnimatedContainer(
              duration: AppTheme.animationMedium,
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
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
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
                        submessage: 'Essayez avec d\'autres termes de recherche',
                        icon: Icons.search_off,
                        color: AppTheme.primaryColor,
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
                        color: AppTheme.primaryColor,
                      );
                    }
                    
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 16, top: 16, bottom: 8),
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
                      color: AppTheme.error,
                      actionLabel: 'Réessayer',
                      onActionPressed: () => _performSearch(_searchController.text),
                    );
                  }
                  
                  // État initial, afficher une invitation à rechercher
                  return EmptyResults(
                    message: 'Recherchez un aliment',
                    submessage: 'Saisissez un nom d\'aliment dans la barre de recherche',
                    icon: Icons.search,
                    color: AppTheme.primaryColor,
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
