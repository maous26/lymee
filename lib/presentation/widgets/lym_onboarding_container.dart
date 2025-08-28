import 'package:flutter/material.dart';
import 'package:lym_nutrition/presentation/themes/lym_design_system.dart';
import 'package:percent_indicator/linear_percent_indicator.dart'; // Using a popular package for progress

class LymOnboardingContainer extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;
  final int currentStep;
  final int totalSteps;
  final VoidCallback? onNext;
  final VoidCallback? onBack;
  final bool showNext;
  final bool showBack;
  final String nextButtonText;
  final String backButtonText;
  final IconData? titleIcon;
  final Color? accentColor;

  const LymOnboardingContainer({
    Key? key,
    required this.title,
    this.subtitle,
    required this.child,
    required this.currentStep,
    required this.totalSteps,
    this.onNext,
    this.onBack,
    this.showNext = true,
    this.showBack = true,
    this.nextButtonText = 'Suivant',
    this.backButtonText = 'Retour',
    this.titleIcon,
    this.accentColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = LymDesignSystem.lightTheme;
    final effectiveAccentColor = accentColor ?? LymDesignSystem.mint;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              effectiveAccentColor.withValues(alpha: 0.1),
              effectiveAccentColor.withValues(alpha: 0.3),
              effectiveAccentColor.withValues(alpha: 0.5),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(context, theme, effectiveAccentColor),
              _buildProgressIndicator(theme, effectiveAccentColor),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(LymDesignSystem.spacing24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (subtitle != null) ...[
                        Text(
                          subtitle!,
                          style:
                              LymDesignSystem.textTheme.titleMedium?.copyWith(
                            color: effectiveAccentColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: LymDesignSystem.spacing8),
                      ],
                      Text(
                        title,
                        style: LymDesignSystem.textTheme.displaySmall?.copyWith(
                          color: LymDesignSystem.gray900,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: LymDesignSystem.spacing24),
                      AnimatedSwitcher(
                        duration: LymDesignSystem.durationMedium,
                        transitionBuilder:
                            (Widget child, Animation<double> animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0.0, 0.1),
                                end: Offset.zero,
                              ).animate(animation),
                              child: child,
                            ),
                          );
                        },
                        child: child,
                      ),
                    ],
                  ),
                ),
              ),
              _buildNavigationButtons(context, theme, effectiveAccentColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(
      BuildContext context, ThemeData theme, Color effectiveAccentColor) {
    return Padding(
      padding: const EdgeInsets.only(
        top: LymDesignSystem.spacing16,
        left: LymDesignSystem.spacing16,
        right: LymDesignSystem.spacing16,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (showBack && onBack != null && currentStep > 0)
            IconButton(
              icon: Icon(Icons.arrow_back_ios_new, color: effectiveAccentColor),
              onPressed: onBack,
              tooltip: backButtonText,
            )
          else
            const SizedBox(width: 48), // Placeholder for alignment
          if (titleIcon != null)
            Icon(titleIcon, color: effectiveAccentColor, size: 32),
          const SizedBox(width: 48), // Placeholder for alignment
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(ThemeData theme, Color effectiveAccentColor) {
    double percent = (currentStep + 1) / totalSteps;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: LymDesignSystem.spacing24,
        vertical: LymDesignSystem.spacing16,
      ),
      child: LinearPercentIndicator(
        percent: percent,
        lineHeight: 8.0,
        backgroundColor: LymDesignSystem.gray200.withValues(alpha: 0.5),
        progressColor: effectiveAccentColor,
        barRadius: const Radius.circular(LymDesignSystem.radiusRound),
        animation: true,
        animationDuration: LymDesignSystem.durationSlow.inMilliseconds,
      ),
    );
  }

  Widget _buildNavigationButtons(
      BuildContext context, ThemeData theme, Color effectiveAccentColor) {
    return Padding(
      padding: const EdgeInsets.all(LymDesignSystem.spacing24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (showBack && onBack != null && currentStep > 0)
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                      color: effectiveAccentColor,
                      width: LymDesignSystem.borderWidthMedium),
                  foregroundColor: effectiveAccentColor,
                  padding: const EdgeInsets.symmetric(
                      vertical: LymDesignSystem.spacing16),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(LymDesignSystem.radiusMd),
                  ),
                ),
                onPressed: onBack,
                child: Text(
                  backButtonText,
                  style: LymDesignSystem.textTheme.labelLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
            )
          else
            const Expanded(
                child: SizedBox.shrink()), // Occupy space if no back button

          if (showBack &&
              onBack != null &&
              currentStep > 0 &&
              showNext &&
              onNext != null)
            const SizedBox(width: LymDesignSystem.spacing16),

          if (showNext && onNext != null)
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: effectiveAccentColor,
                  foregroundColor: LymDesignSystem.white,
                  padding: const EdgeInsets.symmetric(
                      vertical: LymDesignSystem.spacing16),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(LymDesignSystem.radiusMd),
                  ),
                ),
                onPressed: onNext,
                child: Text(
                  nextButtonText,
                  style: LymDesignSystem.textTheme.labelLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
            )
          else
            const Expanded(
                child: SizedBox.shrink()), // Occupy space if no next button
        ],
      ),
    );
  }
}
