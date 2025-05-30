// lib/presentation/screens/food_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lym_nutrition/domain/entities/food_item.dart';
import 'package:lym_nutrition/presentation/bloc/food_detail/food_detail_bloc.dart';
import 'package:lym_nutrition/presentation/bloc/food_detail/food_detail_event.dart';
import 'package:lym_nutrition/presentation/bloc/food_detail/food_detail_state.dart';
import 'package:lym_nutrition/presentation/themes/app_theme.dart';
import 'package:lym_nutrition/presentation/widgets/nutrition_score_badge.dart';
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
    _tabController = TabController(length: 2, vsync: this); // Réduit de 3 à 2 onglets
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

          // État initial
          return _buildLoadingScreen();
        },
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails de l\'aliment'),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
        ),
      ),
    );
  }

  Widget _buildErrorScreen(String message) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Erreur'),
        backgroundColor: AppTheme.error,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 80, color: AppTheme.error),
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
                  backgroundColor: AppTheme.primaryColor,
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
    final sourceColor =
        food.source == 'ciqual'
            ? AppTheme.primaryColor
            : AppTheme.secondaryColor;

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
                  duration: AppTheme.animationFast,
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
                    unselectedLabelColor: theme.colorScheme.onSurface
                        .withOpacity(0.7),
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
            // Onglet Résumé
            _buildSummaryTab(food, theme, textTheme),

            // Onglet Nutriments
            _buildNutrientsTab(food, theme, textTheme),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Logique pour ajouter l'aliment à un repas
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Aliment ajouté au repas'),
              backgroundColor: AppTheme.success,
            ),
          );
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
          // Image d'arrière-plan
          CachedNetworkImage(
            imageUrl: food.imageUrl,
            fit: BoxFit.cover,
            placeholder:
                (context, url) => Container(
                  color: sourceColor,
                  child: const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                ),
            errorWidget:
                (context, url, error) => Container(
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

          // Dégradé pour assurer la lisibilité du texte
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

          // Informations principales
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
      // Pas d'image, utiliser un dégradé avec une icône
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
            // Icône centrale
            Center(
              child: Icon(
                food.isProcessed ? Icons.fastfood : Icons.eco,
                color: Colors.white.withOpacity(0.5),
                size: 80,
              ),
            ),

            // Informations principales
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
          // Informations de base
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
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
                        color: AppTheme.primaryColor,
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
                    'Catégorie',
                    food.category,
                    Icons.category,
                    theme,
                  ),
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
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    'Source',
                    food.source == 'ciqual' ? 'CIQUAL' : 'OpenFoodFacts',
                    Icons.source,
                    theme,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Score nutritionnel
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.stars, color: AppTheme.primaryColor, size: 20),
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
                              AppTheme.getNutritionScoreLabel(
                                food.nutritionScore,
                              ),
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.getNutritionScoreColor(
                                  food.nutritionScore,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Score basé sur les recommandations nutritionnelles de l\'OMS',
                              style: textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(
                                  0.7,
                                ),
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
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.pie_chart,
                        color: AppTheme.primaryColor,
                        size: 20,
                      ),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildNutrientCircle(
                        'Calories',
                        '${food.calories.round()}',
                        'kcal',
                        AppTheme.accentColor,
                        theme,
                      ),
                      _buildNutrientCircle(
                        'Protéines',
                        food.proteins.toStringAsFixed(1),
                        'g',
                        Colors.blue,
                        theme,
                      ),
                      _buildNutrientCircle(
                        'Glucides',
                        food.carbs.toStringAsFixed(1),
                        'g',
                        Colors.orange,
                        theme,
                      ),
                      _buildNutrientCircle(
                        'Lipides',
                        food.fats.toStringAsFixed(1),
                        'g',
                        Colors.red,
                        theme,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildNutrientBar(
                        'Sucres',
                        food.sugar.toStringAsFixed(1),
                        'g',
                        Colors.pink,
                        theme,
                      ),
                      const SizedBox(width: 24),
                      _buildNutrientBar(
                        'Fibres',
                        food.fiber.toStringAsFixed(1),
                        'g',
                        Colors.green,
                        theme,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Valeurs pour 100g de produit',
                    style: textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
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
    FoodItem food,
    ThemeData theme,
    TextTheme textTheme,
  ) {
    // Liste des nutriments à afficher
    final nutrientCategories = [
      {
        'title': 'Macronutriments',
        'icon': Icons.pie_chart,
        'nutrients': [
          {
            'name': 'Calories',
            'value': '${food.calories.round()}',
            'unit': 'kcal',
          },
          {
            'name': 'Protéines',
            'value': food.proteins.toStringAsFixed(1),
            'unit': 'g',
          },
          {
            'name': 'Glucides',
            'value': food.carbs.toStringAsFixed(1),
            'unit': 'g',
          },
          {
            'name': 'dont Sucres',
            'value': food.sugar.toStringAsFixed(1),
            'unit': 'g',
          },
          {
            'name': 'Lipides',
            'value': food.fats.toStringAsFixed(1),
            'unit': 'g',
          },
          {
            'name': 'Fibres',
            'value': food.fiber.toStringAsFixed(1),
            'unit': 'g',
          },
        ],
      },
    ];

    // Ajouter d'autres catégories si les nutriments sont disponibles
    if (food.nutrients.containsKey('AG saturés (g/100 g)')) {
      nutrientCategories.add({
        'title': 'Acides gras',
        'icon': Icons.oil_barrel,
        'nutrients': [
          {
            'name': 'Acides gras saturés',
            'value': _getNutrientValue(food.nutrients, 'AG saturés (g/100 g)'),
            'unit': 'g',
          },
          {
            'name': 'Acides gras monoinsaturés',
            'value': _getNutrientValue(
              food.nutrients,
              'AG monoinsaturés (g/100 g)',
            ),
            'unit': 'g',
          },
          {
            'name': 'Acides gras polyinsaturés',
            'value': _getNutrientValue(
              food.nutrients,
              'AG polyinsaturés (g/100 g)',
            ),
            'unit': 'g',
          },
        ],
      });
    }

    if (food.nutrients.containsKey('Sel chlorure de sodium (g/100 g)') ||
        food.nutrients.containsKey('Sodium (mg/100 g)')) {
      nutrientCategories.add({
        'title': 'Minéraux',
        'icon': Icons.spa,
        'nutrients': [
          {
            'name': 'Sel',
            'value': _getNutrientValue(
              food.nutrients,
              'Sel chlorure de sodium (g/100 g)',
            ),
            'unit': 'g',
          },
          {
            'name': 'Sodium',
            'value': _getNutrientValue(food.nutrients, 'Sodium (mg/100 g)'),
            'unit': 'mg',
          },
          {
            'name': 'Calcium',
            'value': _getNutrientValue(food.nutrients, 'Calcium (mg/100 g)'),
            'unit': 'mg',
          },
          {
            'name': 'Fer',
            'value': _getNutrientValue(food.nutrients, 'Fer (mg/100 g)'),
            'unit': 'mg',
          },
          {
            'name': 'Magnésium',
            'value': _getNutrientValue(food.nutrients, 'Magnésium (mg/100 g)'),
            'unit': 'mg',
          },
          {
            'name': 'Potassium',
            'value': _getNutrientValue(food.nutrients, 'Potassium (mg/100 g)'),
            'unit': 'mg',
          },
          {
            'name': 'Zinc',
            'value': _getNutrientValue(food.nutrients, 'Zinc (mg/100 g)'),
            'unit': 'mg',
          },
        ],
      });
    }

    if (food.nutrients.containsKey('Vitamine C (mg/100 g)') ||
        food.nutrients.containsKey('Vitamine B1 ou Thiamine (mg/100 g)')) {
      nutrientCategories.add({
        'title': 'Vitamines',
        'icon': Icons.opacity,
        'nutrients': [
          {
            'name': 'Vitamine A (Rétinol)',
            'value': _getNutrientValue(food.nutrients, 'Rétinol (µg/100 g)'),
            'unit': 'µg',
          },
          {
            'name': 'Vitamine C',
            'value': _getNutrientValue(food.nutrients, 'Vitamine C (mg/100 g)'),
            'unit': 'mg',
          },
          {
            'name': 'Vitamine B1 (Thiamine)',
            'value': _getNutrientValue(
              food.nutrients,
              'Vitamine B1 ou Thiamine (mg/100 g)',
            ),
            'unit': 'mg',
          },
          {
            'name': 'Vitamine B2 (Riboflavine)',
            'value': _getNutrientValue(
              food.nutrients,
              'Vitamine B2 ou Riboflavine (mg/100 g)',
            ),
            'unit': 'mg',
          },
          {
            'name': 'Vitamine B3 (Niacine)',
            'value': _getNutrientValue(
              food.nutrients,
              'Vitamine B3 ou PP ou Niacine (mg/100 g)',
            ),
            'unit': 'mg',
          },
          {
            'name': 'Vitamine B9 (Folates)',
            'value': _getNutrientValue(
              food.nutrients,
              'Vitamine B9 ou Folates totaux (µg/100 g)',
            ),
            'unit': 'µg',
          },
        ],
      });
    }

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

          // Afficher chaque catégorie de nutriments
          ...nutrientCategories.map((category) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    AppTheme.borderRadiusLarge,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            category['icon'] as IconData,
                            color: AppTheme.primaryColor,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            category['title'] as String,
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      ...((category['nutrients'] as List<Map<String, String>>)
                          .where(
                            (nutrient) =>
                                nutrient['value'] != null &&
                                nutrient['value'] != '0' &&
                                nutrient['value'] != '-',
                          )
                          .map((nutrient) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    nutrient['name']!,
                                    style: textTheme.bodyMedium,
                                  ),
                                  Text(
                                    '${nutrient['value']} ${nutrient['unit']}',
                                    style: textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          })),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }



  Widget _buildInfoRow(
    String label,
    String value,
    IconData icon,
    ThemeData theme,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: theme.colorScheme.onSurface.withOpacity(0.6),
        ),
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
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }



  Widget _buildNutrientCircle(
    String label,
    String value,
    String unit,
    Color color,
    ThemeData theme,
  ) {
    return Column(
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withOpacity(0.1),
            border: Border.all(color: color.withOpacity(0.5), width: 2),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  unit,
                  style: theme.textTheme.bodySmall?.copyWith(color: color),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: theme.textTheme.bodySmall),
      ],
    );
  }

  Widget _buildNutrientBar(
    String label,
    String value,
    String unit,
    Color color,
    ThemeData theme,
  ) {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 4),
            Container(
              width: 120,
              height: 24,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
                color: color.withOpacity(0.1),
              ),
              child: Row(
                children: [
                  Container(
                    width: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                        AppTheme.borderRadiusSmall,
                      ),
                      color: color.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(width: 8),
        Text(
          '$value $unit',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  String _getNutrientValue(Map<String, dynamic> nutrients, String key) {
    if (!nutrients.containsKey(key) ||
        nutrients[key] == null ||
        nutrients[key] == '-') {
      return '0';
    }

    var value = nutrients[key];
    if (value is String) {
      if (value.startsWith('<')) {
        return value;
      }
      return double.tryParse(value.replaceAll(',', '.'))?.toStringAsFixed(1) ??
          '0';
    }

    if (value is num) {
      return value.toStringAsFixed(1);
    }

    return '0';
  }
}
