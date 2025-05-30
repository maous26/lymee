// lib/presentation/screens/food_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lym_nutrition/domain/entities/food_item.dart';
import 'package:lym_nutrition/presentation/bloc/food_detail/food_detail_bloc.dart';
import 'package:lym_nutrition/presentation/bloc/food_detail/food_detail_event.dart';
import 'package:lym_nutrition/presentation/bloc/food_detail/food_detail_state.dart';
import 'package:lym_nutrition/presentation/themes/premium_theme.dart';
import 'package:lym_nutrition/presentation/widgets/nutrition_score_badge.dart';
import 'package:lym_nutrition/presentation/widgets/meal_selection_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';

class FoodDetailScreen extends StatefulWidget {
  final String foodId;
  final String foodSource;

  const FoodDetailScreen({
    super.key,
    required this.foodId,
    required this.foodSource,
  });

  @override
  State<FoodDetailScreen> createState() => _FoodDetailScreenState();
}

class _FoodDetailScreenState extends State<FoodDetailScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  bool _showTitle = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _scrollController.addListener(_onScroll);

    // Charger les détails de l'aliment
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FoodDetailBloc>().add(
            GetFoodDetailEvent(id: widget.foodId, source: widget.foodSource),
          );
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.offset > 150 && !_showTitle) {
      setState(() {
        _showTitle = true;
      });
    } else if (_scrollController.offset <= 150 && _showTitle) {
      setState(() {
        _showTitle = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<FoodDetailBloc, FoodDetailState>(
        builder: (context, state) {
          if (state is FoodDetailLoading) {
            return _buildLoadingScreen();
          } else if (state is FoodDetailError) {
            return _buildErrorScreen(state.message);
          } else if (state is FoodDetailLoaded) {
            return _buildDetailScreen(state.food);
          }

          return _buildLoadingScreen();
        },
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails de l\'aliment'),
        backgroundColor: PremiumTheme.primaryColor,
      ),
      body: const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(PremiumTheme.primaryColor),
        ),
      ),
    );
  }

  Widget _buildErrorScreen(String message) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Erreur'),
        backgroundColor: PremiumTheme.error,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline,
                  size: 80, color: PremiumTheme.error),
              const SizedBox(height: 24),
              Text(
                'Une erreur est survenue',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                message,
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  context.read<FoodDetailBloc>().add(
                        GetFoodDetailEvent(
                          id: widget.foodId,
                          source: widget.foodSource,
                        ),
                      );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: PremiumTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailScreen(FoodItem food) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final sourceColor = food.source == 'ciqual'
        ? PremiumTheme.primaryColor
        : PremiumTheme.secondaryColor;

    return Scaffold(
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 180,
              floating: false,
              pinned: true,
              backgroundColor: sourceColor,
              flexibleSpace: FlexibleSpaceBar(
                title: AnimatedOpacity(
                  opacity: _showTitle ? 1.0 : 0.0,
                  duration: PremiumTheme.animationFast,
                  child: Text(
                    food.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                background: _buildFoodHeader(food, sourceColor),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(48),
                child: ColoredBox(
                  color: theme.scaffoldBackgroundColor,
                  child: TabBar(
                    controller: _tabController,
                    indicatorColor: sourceColor,
                    labelColor: sourceColor,
                    unselectedLabelColor:
                        theme.colorScheme.onSurface.withOpacity(0.7),
                    tabs: const [
                      Tab(text: 'Résumé'),
                      Tab(text: 'Nutriments'),
                    ],
                  ),
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildSummaryTab(food, theme, textTheme),
            _buildNutrientsTab(food, theme, textTheme),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await showDialog<Map<String, dynamic>>(
            context: context,
            builder: (context) => MealSelectionDialog(food: food),
          );

          if (result != null) {
            String meal = result['meal'];
            double quantity = result['quantity'];
            String unit = result['unit'];

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '${food.name} ajouté à $meal (${quantity.toStringAsFixed(0)} $unit)',
                  ),
                  backgroundColor: PremiumTheme.success,
                  duration: const Duration(seconds: 3),
                  action: SnackBarAction(
                    label: 'D\'accord',
                    textColor: Colors.white,
                    onPressed: () {},
                  ),
                ),
              );
            }
          }
        },
        backgroundColor: sourceColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildFoodHeader(FoodItem food, Color sourceColor) {
    if (food.imageUrl.isNotEmpty) {
      return Stack(
        fit: StackFit.expand,
        children: [
          CachedNetworkImage(
            imageUrl: food.imageUrl,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              color: sourceColor,
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
            errorWidget: (context, url, error) => Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [sourceColor.withOpacity(0.8), sourceColor],
                ),
              ),
              child: Center(
                child: Icon(
                  food.isProcessed ? Icons.fastfood : Icons.eco,
                  color: Colors.white.withOpacity(0.7),
                  size: 60,
                ),
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                stops: const [0.5, 1.0],
              ),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  food.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (food.brand != null && food.brand!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      food.brand!,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      );
    } else {
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [sourceColor.withOpacity(0.8), sourceColor],
          ),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Center(
              child: Icon(
                food.isProcessed ? Icons.fastfood : Icons.eco,
                color: Colors.white.withOpacity(0.5),
                size: 80,
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    food.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (food.brand != null && food.brand!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        food.brand!,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildSummaryTab(FoodItem food, ThemeData theme, TextTheme textTheme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(PremiumTheme.borderRadiusLarge),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: PremiumTheme.primaryColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Informations de base',
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  _buildInfoRow(
                      'Catégorie', food.category, Icons.category, theme),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    'Type',
                    food.isProcessed ? 'Transformé' : 'Frais',
                    food.isProcessed ? Icons.fastfood : Icons.eco,
                    theme,
                  ),
                  if (food.brand != null && food.brand!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _buildInfoRow('Marque', food.brand!, Icons.business, theme),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(PremiumTheme.borderRadiusLarge),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.stars,
                          color: PremiumTheme.primaryColor, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Score nutritionnel',
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    children: [
                      NutritionScoreBadge(
                        score: food.nutritionScore,
                        size: 60,
                        showLabel: false,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              PremiumTheme.getNutritionScoreLabel(
                                  food.nutritionScore),
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: PremiumTheme.getNutritionScoreColor(
                                    food.nutritionScore),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Score basé sur les recommandations nutritionnelles',
                              style: textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface
                                    .withOpacity(0.7),
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
        ],
      ),
    );
  }

  Widget _buildNutrientsTab(
      FoodItem food, ThemeData theme, TextTheme textTheme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Valeurs nutritionnelles pour 100g',
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'Source: ${food.source == 'ciqual' ? 'CIQUAL' : 'OpenFoodFacts'}',
            style: textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(PremiumTheme.borderRadiusLarge),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.pie_chart,
                          color: PremiumTheme.primaryColor, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Macronutriments',
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  _buildNutrientRow(
                      'Calories', '${food.calories.round()}', 'kcal', theme),
                  _buildNutrientRow('Protéines',
                      food.proteins.toStringAsFixed(1), 'g', theme),
                  _buildNutrientRow(
                      'Glucides', food.carbs.toStringAsFixed(1), 'g', theme),
                  _buildNutrientRow(
                      'Lipides', food.fats.toStringAsFixed(1), 'g', theme),
                  _buildNutrientRow(
                      'Fibres', food.fiber.toStringAsFixed(1), 'g', theme),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
      String label, String value, IconData icon, ThemeData theme) {
    return Row(
      children: [
        Icon(icon,
            size: 18, color: theme.colorScheme.onSurface.withOpacity(0.6)),
        const SizedBox(width: 8),
        Text(
          '$label:',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodyMedium
                ?.copyWith(fontWeight: FontWeight.w600),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _buildNutrientRow(
      String name, String value, String unit, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(name, style: theme.textTheme.bodyMedium),
          Text(
            '$value $unit',
            style: theme.textTheme.bodyMedium
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
