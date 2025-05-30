// lib/presentation/widgets/food_card.dart (modifié)
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:lym_nutrition/domain/entities/food_item.dart';
import 'package:lym_nutrition/presentation/themes/premium_theme.dart';
import 'package:lym_nutrition/presentation/widgets/nutrition_score_badge.dart';

class FoodCard extends StatelessWidget {
  final FoodItem food;
  final VoidCallback onTap;
  final bool isHistoryItem;
  final bool showNutritionScore;
  final bool showCalories;
  final bool showCategory;
  final bool showBrand;

  const FoodCard({
    Key? key,
    required this.food,
    required this.onTap,
    this.isHistoryItem = false,
    this.showNutritionScore = true,
    this.showCalories = true,
    this.showCategory = true,
    this.showBrand = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    
    // Couleur de badge source pour différencier les aliments
    final Color sourceColor = food.source == 'ciqual'
        ? PremiumTheme.primaryColor
        : PremiumTheme.secondaryColor;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(PremiumTheme.borderRadiusLarge),
      ),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        splashColor: sourceColor.withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Image de l'aliment ou placeholder
              _buildFoodImage(context, sourceColor),
              
              const SizedBox(width: 12),
              
              // Informations sur l'aliment
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Nom de l'aliment
                    Text(
                      food.name,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const SizedBox(height: 4),
                    
                    // Catégorie et Marque (si disponible)
                    if (showCategory || (showBrand && food.brand != null))
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          children: [
                            if (showCategory)
                              Expanded(
                                child: Text(
                                  food.category,
                                  style: textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            if (showBrand && food.brand != null && food.brand!.isNotEmpty)
                              Expanded(
                                child: Text(
                                  food.brand!,
                                  style: textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                                    fontWeight: FontWeight.w500,
                                  ),
                                  textAlign: TextAlign.end,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                          ],
                        ),
                      ),
                    
                    // Affichage des calories (sans le badge source)
                    if (showCalories)
                      Text(
                        '${food.calories.round()} kcal',
                        style: textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: sourceColor,
                        ),
                      ),
                  ],
                ),
              ),
              
              // Score nutritionnel
              if (showNutritionScore)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: NutritionScoreBadge(
                    score: food.nutritionScore,
                    size: 35,
                    showLabel: false,
                  ),
                ),
              
              // Indicateur historique
              if (isHistoryItem)
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Icon(
                    Icons.history,
                    size: 16,
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFoodImage(BuildContext context, Color sourceColor) {
    // Si l'URL de l'image est vide, afficher une icône placeholder
    if (food.imageUrl.isEmpty) {
      return Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: sourceColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(PremiumTheme.borderRadiusMedium),
          border: Border.all(
            color: sourceColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Icon(
          food.isProcessed ? Icons.fastfood : Icons.eco,
          color: sourceColor,
          size: 28,
        ),
      );
    }
    
    // Sinon, afficher l'image mise en cache
    return ClipRRect(
      borderRadius: BorderRadius.circular(PremiumTheme.borderRadiusMedium),
      child: CachedNetworkImage(
        imageUrl: food.imageUrl,
        width: 60,
        height: 60,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: sourceColor.withOpacity(0.1),
          child: Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(sourceColor),
              ),
            ),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          color: sourceColor.withOpacity(0.1),
          child: Icon(
            food.isProcessed ? Icons.fastfood : Icons.eco,
            color: sourceColor,
            size: 28,
          ),
        ),
      ),
    );
  }
}