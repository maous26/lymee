import 'package:flutter/material.dart';
import 'package:lym_nutrition/presentation/themes/wellness_colors.dart';

/// Level progression widget for gamification system
/// Shows current level, progress to next level, and experience points
class LevelProgressWidget extends StatefulWidget {
  final int currentLevel;
  final int currentXP;
  final int xpToNextLevel;
  final String levelTitle;
  final Color? levelColor;
  final bool showDetails;
  final VoidCallback? onTap;

  const LevelProgressWidget({
    super.key,
    required this.currentLevel,
    required this.currentXP,
    required this.xpToNextLevel,
    this.levelTitle = 'Nutritionniste',
    this.levelColor,
    this.showDetails = true,
    this.onTap,
  });

  @override
  State<LevelProgressWidget> createState() => _LevelProgressWidgetState();
}

class _LevelProgressWidgetState extends State<LevelProgressWidget>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _glowController;
  late Animation<double> _progressAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();

    _progressController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: widget.currentXP / widget.xpToNextLevel,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ));

    _glowAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));

    // Start animations
    _progressController.forward();
    _glowController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _progressController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  Color get _levelColor {
    return widget.levelColor ?? _getLevelColor(widget.currentLevel);
  }

  Color _getLevelColor(int level) {
    if (level >= 50) return WellnessColors.sunsetOrange;
    if (level >= 30) return WellnessColors.accentPeach;
    if (level >= 15) return WellnessColors.secondaryBlue;
    if (level >= 5) return WellnessColors.primaryGreen;
    return WellnessColors.textSecondary;
  }

  String _getLevelRank(int level) {
    if (level >= 50) return 'Expert';
    if (level >= 30) return 'Avancé';
    if (level >= 15) return 'Intermédiaire';
    if (level >= 5) return 'Apprenti';
    return 'Débutant';
  }

  IconData _getLevelIcon(int level) {
    if (level >= 50) return Icons.auto_awesome_rounded;
    if (level >= 30) return Icons.workspace_premium_rounded;
    if (level >= 15) return Icons.star_rounded;
    if (level >= 5) return Icons.trending_up_rounded;
    return Icons.eco_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final progressPercent =
        (widget.currentXP / widget.xpToNextLevel).clamp(0.0, 1.0);

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        padding: const EdgeInsets.all(WellnessSpacing.lg),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              _levelColor.withOpacity(0.1),
              _levelColor.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(WellnessBorderRadius.lg),
          border: Border.all(
            color: _levelColor.withOpacity(0.3),
            width: 2,
          ),
          boxShadow: WellnessShadows.medium,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with level info
            Row(
              children: [
                // Level badge
                AnimatedBuilder(
                  animation: _glowController,
                  builder: (context, child) {
                    return Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            _levelColor,
                            _levelColor.withOpacity(0.8),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: _levelColor
                                .withOpacity(0.4 * _glowAnimation.value),
                            blurRadius: 20,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _getLevelIcon(widget.currentLevel),
                            color: Colors.white,
                            size: 20,
                          ),
                          Text(
                            '${widget.currentLevel}',
                            style: WellnessTypography.labelLarge.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),

                const SizedBox(width: WellnessSpacing.md),

                // Level details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Niveau ${widget.currentLevel}',
                        style: WellnessTypography.headlineMedium.copyWith(
                          color: WellnessColors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        '${_getLevelRank(widget.currentLevel)} ${widget.levelTitle}',
                        style: WellnessTypography.bodyMedium.copyWith(
                          color: _levelColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (widget.showDetails) ...[
                        const SizedBox(height: WellnessSpacing.xs),
                        Text(
                          '${widget.currentXP} / ${widget.xpToNextLevel} XP',
                          style: WellnessTypography.labelMedium.copyWith(
                            color: WellnessColors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Next level indicator
                if (progressPercent < 1.0)
                  Column(
                    children: [
                      Text(
                        'Prochain',
                        style: WellnessTypography.labelMedium.copyWith(
                          color: WellnessColors.textTertiary,
                        ),
                      ),
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _levelColor.withOpacity(0.3),
                            width: 2,
                          ),
                          color: WellnessColors.backgroundSecondary,
                        ),
                        child: Center(
                          child: Text(
                            '${widget.currentLevel + 1}',
                            style: WellnessTypography.labelMedium.copyWith(
                              color: _levelColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),

            if (widget.showDetails && progressPercent < 1.0) ...[
              const SizedBox(height: WellnessSpacing.lg),

              // Progress bar
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Progression vers le niveau ${widget.currentLevel + 1}',
                        style: WellnessTypography.labelMedium.copyWith(
                          color: WellnessColors.textSecondary,
                        ),
                      ),
                      Text(
                        '${(progressPercent * 100).round()}%',
                        style: WellnessTypography.labelMedium.copyWith(
                          color: _levelColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: WellnessSpacing.sm),

                  // Animated progress bar
                  Container(
                    height: 8,
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(WellnessBorderRadius.sm),
                      color: _levelColor.withOpacity(0.2),
                    ),
                    child: AnimatedBuilder(
                      animation: _progressAnimation,
                      builder: (context, child) {
                        return FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: _progressAnimation.value,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                  WellnessBorderRadius.sm),
                              gradient: LinearGradient(
                                colors: [
                                  _levelColor,
                                  _levelColor.withOpacity(0.8),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: _levelColor.withOpacity(0.4),
                                  blurRadius: 4,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: WellnessSpacing.sm),

                  Text(
                    'Encore ${widget.xpToNextLevel - widget.currentXP} XP pour le prochain niveau',
                    style: WellnessTypography.labelMedium.copyWith(
                      color: WellnessColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Compact level badge for headers and navigation
class LevelBadge extends StatelessWidget {
  final int level;
  final Color? color;
  final double size;
  final VoidCallback? onTap;

  const LevelBadge({
    super.key,
    required this.level,
    this.color,
    this.size = 40,
    this.onTap,
  });

  Color get _levelColor {
    if (color != null) return color!;
    if (level >= 50) return WellnessColors.sunsetOrange;
    if (level >= 30) return WellnessColors.accentPeach;
    if (level >= 15) return WellnessColors.secondaryBlue;
    if (level >= 5) return WellnessColors.primaryGreen;
    return WellnessColors.textSecondary;
  }

  IconData get _levelIcon {
    if (level >= 50) return Icons.auto_awesome_rounded;
    if (level >= 30) return Icons.workspace_premium_rounded;
    if (level >= 15) return Icons.star_rounded;
    if (level >= 5) return Icons.trending_up_rounded;
    return Icons.eco_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              _levelColor,
              _levelColor.withOpacity(0.8),
            ],
          ),
          boxShadow: WellnessShadows.medium,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _levelIcon,
              color: Colors.white,
              size: size * 0.35,
            ),
            Text(
              '$level',
              style: WellnessTypography.labelMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: size * 0.25,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Experience points calculator
class XPCalculator {
  static int getXPForNextLevel(int currentLevel) {
    // Exponential growth: base XP * level multiplier
    return (100 * (currentLevel * 1.5)).round();
  }

  static int getTotalXPForLevel(int level) {
    int totalXP = 0;
    for (int i = 1; i < level; i++) {
      totalXP += getXPForNextLevel(i);
    }
    return totalXP;
  }

  static int getLevelFromTotalXP(int totalXP) {
    int level = 1;
    int currentXP = 0;

    while (currentXP <= totalXP) {
      int xpForNext = getXPForNextLevel(level);
      if (currentXP + xpForNext > totalXP) break;
      currentXP += xpForNext;
      level++;
    }

    return level;
  }

  static int getCurrentLevelXP(int totalXP) {
    int level = getLevelFromTotalXP(totalXP);
    int totalXPForCurrentLevel = getTotalXPForLevel(level);
    return totalXP - totalXPForCurrentLevel;
  }
}

/// XP earning actions
enum XPAction {
  mealLogged(10, 'Repas enregistré'),
  waterGoalMet(5, 'Objectif hydratation'),
  exerciseLogged(15, 'Exercice enregistré'),
  dailyGoalMet(25, 'Objectif quotidien'),
  weeklyGoalMet(100, 'Objectif hebdomadaire'),
  achievementUnlocked(50, 'Succès débloqué'),
  streakDay(20, 'Jour de série'),
  perfectDay(75, 'Journée parfaite');

  const XPAction(this.points, this.description);
  final int points;
  final String description;
}
