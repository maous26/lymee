import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lym_nutrition/presentation/bloc/user_profile/user_profile_bloc.dart';
import 'package:lym_nutrition/presentation/bloc/user_profile/user_profile_state.dart';
import 'package:lym_nutrition/presentation/themes/enhanced_theme.dart';
import 'package:lym_nutrition/presentation/widgets/info_tooltip.dart';
import 'package:lym_nutrition/domain/entities/user_profile.dart' as entities;

class NutritionalGoalsScreen extends StatefulWidget {
  const NutritionalGoalsScreen({super.key});

  @override
  State<NutritionalGoalsScreen> createState() => _NutritionalGoalsScreenState();
}

class _NutritionalGoalsScreenState extends State<NutritionalGoalsScreen> {
  double _calorieGoal = 2000;
  double _proteinGoal = 150;
  double _carbsGoal = 250;
  double _fatsGoal = 67;
  entities.WeightGoal _weightGoal = entities.WeightGoal.maintain;
  // In read-only mode, we compute values from the profile when available

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Widget _buildReadonlyMacroRow(
      String label, double value, String unit, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: EnhancedTheme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(EnhancedTheme.radiusS),
          ),
          child: Text(
            '${value.round()} $unit',
            style: EnhancedTheme.textTheme.labelLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  void _loadUserProfile() {
    final profileState = context.read<UserProfileBloc>().state;
    if (profileState is UserProfileLoaded) {
      final profile = profileState.userProfile;
      // Load computed goals from profile
      final targets = profile.calculateMacroTargets();
      _calorieGoal = (targets['calories'] ?? 2000).toDouble();
      _proteinGoal = (targets['protein'] ?? 150).toDouble();
      _carbsGoal = (targets['carbs'] ?? 250).toDouble();
      _fatsGoal = (targets['fat'] ?? 67).toDouble();
      _weightGoal = profile.weightGoal;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EnhancedTheme.neutralGray50,
      appBar: AppBar(
        title: const Text('Objectifs nutritionnels'),
        backgroundColor: EnhancedTheme.primaryTeal,
        foregroundColor: EnhancedTheme.neutralWhite,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(EnhancedTheme.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(EnhancedTheme.spacingL),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    EnhancedTheme.secondaryOrange,
                    EnhancedTheme.secondaryOrangeLight,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(EnhancedTheme.radiusM),
                boxShadow: EnhancedTheme.glowOrange,
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(EnhancedTheme.spacingM),
                    decoration: BoxDecoration(
                      color: EnhancedTheme.neutralWhite.withValues(alpha: 0.2),
                      borderRadius:
                          BorderRadius.circular(EnhancedTheme.radiusXL),
                    ),
                    child: Icon(
                      Icons.track_changes,
                      size: 40,
                      color: EnhancedTheme.neutralWhite,
                    ),
                  ),
                  const SizedBox(height: EnhancedTheme.spacingM),
                  Text(
                    'Vos objectifs',
                    style: EnhancedTheme.textTheme.headlineMedium?.copyWith(
                      color: EnhancedTheme.neutralWhite,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: EnhancedTheme.spacingS),
                  Text(
                    'Vos objectifs sont définis automatiquement par l\'application à partir de vos données. Vous pouvez les revoir ici.',
                    textAlign: TextAlign.center,
                    style: EnhancedTheme.textTheme.bodyMedium?.copyWith(
                      color: EnhancedTheme.neutralWhite.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: EnhancedTheme.spacingL),

            // Weight Goal Section (read-only)
            _buildGoalCard(
              title: 'Objectif de poids',
              icon: Icons.trending_up,
              color: EnhancedTheme.primaryTeal,
              children: [
                Text(
                  _weightGoal == entities.WeightGoal.lose
                      ? 'Perdre du poids'
                      : _weightGoal == entities.WeightGoal.gain
                          ? 'Prendre du poids'
                          : 'Maintenir le poids',
                  style: EnhancedTheme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: EnhancedTheme.neutralGray900,
                  ),
                ),
                const SizedBox(height: EnhancedTheme.spacingXS),
                Text(
                  'Défini automatiquement d\'après vos informations',
                  style: EnhancedTheme.textTheme.bodySmall?.copyWith(
                    color: EnhancedTheme.neutralGray600,
                  ),
                ),
              ],
            ),

            const SizedBox(height: EnhancedTheme.spacingM),

            // Calorie Goal Section (read-only)
            MacroInfoTooltip(
              child: _buildGoalCard(
                title: 'Objectif calorique quotidien',
                icon: Icons.local_fire_department,
                color: EnhancedTheme.errorRed,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Calories par jour',
                        style: EnhancedTheme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: EnhancedTheme.errorRed.withValues(alpha: 0.1),
                          borderRadius:
                              BorderRadius.circular(EnhancedTheme.radiusS),
                        ),
                        child: Text(
                          '${_calorieGoal.round()} kcal',
                          style: EnhancedTheme.textTheme.labelLarge?.copyWith(
                            color: EnhancedTheme.errorRed,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: EnhancedTheme.spacingS),
                  Text(
                    'Calculé automatiquement selon votre profil et votre objectif.',
                    style: EnhancedTheme.textTheme.bodySmall?.copyWith(
                      color: EnhancedTheme.neutralGray600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: EnhancedTheme.spacingM),

            // Macronutrients Section (read-only)
            _buildGoalCard(
              title: 'Répartition des macronutriments',
              icon: Icons.pie_chart,
              color: EnhancedTheme.secondaryOrange,
              children: [
                _buildReadonlyMacroRow(
                    'Protéines', _proteinGoal, 'g', EnhancedTheme.successGreen),
                const SizedBox(height: EnhancedTheme.spacingS),
                _buildReadonlyMacroRow(
                    'Glucides', _carbsGoal, 'g', EnhancedTheme.infoBlue),
                const SizedBox(height: EnhancedTheme.spacingS),
                _buildReadonlyMacroRow(
                    'Lipides', _fatsGoal, 'g', EnhancedTheme.warningYellow),
              ],
            ),

            const SizedBox(height: EnhancedTheme.spacingXL),

            // CTA to revisit onboarding
            Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    EnhancedTheme.primaryTeal,
                    EnhancedTheme.primaryTealLight,
                  ],
                ),
                borderRadius: BorderRadius.circular(EnhancedTheme.radiusM),
                boxShadow: EnhancedTheme.glowTeal,
              ),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/onboarding');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(EnhancedTheme.radiusM),
                  ),
                ),
                child: Text(
                  'Mettre à jour mes informations (Onboarding)',
                  style: EnhancedTheme.textTheme.labelLarge?.copyWith(
                    color: EnhancedTheme.neutralWhite,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalCard({
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(EnhancedTheme.spacingL),
      decoration: BoxDecoration(
        color: EnhancedTheme.neutralWhite,
        borderRadius: BorderRadius.circular(EnhancedTheme.radiusM),
        boxShadow: EnhancedTheme.shadowLight,
        border: Border.all(
          color: EnhancedTheme.neutralGray200,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(EnhancedTheme.spacingS),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(EnhancedTheme.radiusS),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: EnhancedTheme.spacingS),
              Expanded(
                child: Text(
                  title,
                  style: EnhancedTheme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: EnhancedTheme.neutralGray800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: EnhancedTheme.spacingM),
          ...children,
        ],
      ),
    );
  }

  // Old interactive slider removed in read-only mode
  // ignore: unused_element
  Widget _buildSlider({
    required double value,
    required double min,
    required double max,
    required int divisions,
    required String label,
    required ValueChanged<double> onChanged,
    required Color color,
  }) =>
      const SizedBox.shrink();

  // ignore: unused_element
  Widget _buildMacroSlider(
    String label,
    double value,
    String unit,
    double min,
    double max,
    Color color,
    ValueChanged<double> onChanged,
  ) {
    // Deprecated interactive macro slider; kept for reference but not used.
    return const SizedBox.shrink();
  }

  // ignore: unused_element
  Widget _buildMacroPercentage(String label, double percentage, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: EnhancedTheme.textTheme.labelSmall?.copyWith(
            color: EnhancedTheme.neutralGray600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${percentage.round()}%',
          style: EnhancedTheme.textTheme.labelMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // ignore: unused_element
  Widget _buildGoalChip(String label, entities.WeightGoal goal) {
    // Deprecated interactive chips; return a static chip appearance
    final isSelected = _weightGoal == goal;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: EnhancedTheme.spacingM,
        vertical: EnhancedTheme.spacingS,
      ),
      decoration: BoxDecoration(
        color: isSelected
            ? EnhancedTheme.primaryTeal
            : EnhancedTheme.neutralGray100,
        borderRadius: BorderRadius.circular(EnhancedTheme.radiusL),
        border: Border.all(
          color: isSelected
              ? EnhancedTheme.primaryTeal
              : EnhancedTheme.neutralGray300,
        ),
        boxShadow: isSelected ? EnhancedTheme.shadowLight : null,
      ),
      child: Text(
        label,
        style: EnhancedTheme.textTheme.labelMedium?.copyWith(
          color: isSelected
              ? EnhancedTheme.neutralWhite
              : EnhancedTheme.neutralGray700,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // Save removed; goals are computed by the app.
}
