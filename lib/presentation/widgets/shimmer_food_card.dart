// lib/presentation/widgets/shimmer_food_card.dart
import 'package:flutter/material.dart';
import 'package:lym_nutrition/presentation/themes/premium_theme.dart';
import 'package:lym_nutrition/presentation/widgets/shimmer_loading.dart';

class ShimmerFoodCard extends StatelessWidget {
  const ShimmerFoodCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return ShimmerLoading(
      isLoading: true,
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PremiumTheme.borderRadiusLarge),
        ),
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Image placeholder
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: theme.brightness == Brightness.light
                      ? Colors.grey[300]
                      : Colors.grey[700],
                  borderRadius: BorderRadius.circular(PremiumTheme.borderRadiusMedium),
                ),
              ),
              
              const SizedBox(width: 12),
              
              // Informations placeholder
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Nom placeholder
                    Container(
                      height: 18,
                      margin: const EdgeInsets.only(bottom: 8, right: 40),
                      decoration: BoxDecoration(
                        color: theme.brightness == Brightness.light
                            ? Colors.grey[300]
                            : Colors.grey[700],
                        borderRadius: BorderRadius.circular(PremiumTheme.borderRadiusSmall),
                      ),
                    ),
                    
                    // Catégorie placeholder
                    Container(
                      height: 12,
                      width: 120,
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: theme.brightness == Brightness.light
                            ? Colors.grey[300]
                            : Colors.grey[700],
                        borderRadius: BorderRadius.circular(PremiumTheme.borderRadiusSmall),
                      ),
                    ),
                    
                    // Badge placeholder
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          height: 16,
                          width: 60,
                          decoration: BoxDecoration(
                            color: theme.brightness == Brightness.light
                                ? Colors.grey[300]
                                : Colors.grey[700],
                            borderRadius: BorderRadius.circular(PremiumTheme.borderRadiusSmall),
                          ),
                        ),
                        
                        Container(
                          height: 16,
                          width: 50,
                          decoration: BoxDecoration(
                            color: theme.brightness == Brightness.light
                                ? Colors.grey[300]
                                : Colors.grey[700],
                            borderRadius: BorderRadius.circular(PremiumTheme.borderRadiusSmall),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Score placeholder
              Container(
                width: 35,
                height: 35,
                margin: const EdgeInsets.only(left: 8),
                decoration: BoxDecoration(
                  color: theme.brightness == Brightness.light
                      ? Colors.grey[300]
                      : Colors.grey[700],
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}