// lib/presentation/widgets/modern_onboarding_container.dart
import 'package:flutter/material.dart';
import 'package:lym_nutrition/presentation/themes/wellness_colors.dart';

class ModernOnboardingContainer extends StatefulWidget {
  final String title;
  final String? subtitle;
  final Widget content;
  final VoidCallback onNext;
  final String nextButtonText;
  final bool isLoading;
  final IconData? titleIcon;
  final String? illustrationEmoji;
  final Color? primaryColor;
  final int currentStep;
  final int totalSteps;

  const ModernOnboardingContainer({
    Key? key,
    required this.title,
    this.subtitle,
    required this.content,
    required this.onNext,
    this.nextButtonText = 'Suivant',
    this.isLoading = false,
    this.titleIcon,
    this.illustrationEmoji,
    this.primaryColor,
    required this.currentStep,
    required this.totalSteps,
  }) : super(key: key);

  @override
  State<ModernOnboardingContainer> createState() => _ModernOnboardingContainerState();
}

class _ModernOnboardingContainerState extends State<ModernOnboardingContainer>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));

    // Start animations
    Future.delayed(const Duration(milliseconds: 100), () {
      _fadeController.forward();
      _slideController.forward();
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = widget.primaryColor ?? WellnessColors.primaryGreen;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primaryColor.withOpacity(0.05),
            WellnessColors.lightMint.withOpacity(0.1),
            Colors.white,
          ],
          stops: const [0.0, 0.3, 1.0],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Progress Header
            _buildProgressHeader(theme, primaryColor),
            
            // Content Area
            Expanded(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),
                          
                          // Illustration and Title Section
                          _buildHeaderSection(theme, primaryColor),
                          
                          const SizedBox(height: 32),
                          
                          // Content
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: primaryColor.withOpacity(0.1),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: widget.content,
                            ),
                          ),
                          
                          const SizedBox(height: 32),
                          
                          // Next Button
                          _buildNextButton(primaryColor),
                          
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressHeader(ThemeData theme, Color primaryColor) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Step indicator dots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(widget.totalSteps, (index) {
              final isActive = index == widget.currentStep;
              final isCompleted = index < widget.currentStep;
              
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: isActive ? 32 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: isCompleted || isActive 
                      ? primaryColor 
                      : primaryColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),
          
          const SizedBox(height: 12),
          
          // Step text
          Text(
            'Étape ${widget.currentStep + 1} sur ${widget.totalSteps}',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: WellnessColors.charcoalGray,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderSection(ThemeData theme, Color primaryColor) {
    return Column(
      children: [
        // Large Illustration
        if (widget.illustrationEmoji != null)
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  primaryColor.withOpacity(0.1),
                  primaryColor.withOpacity(0.05),
                ],
              ),
            ),
            child: Center(
              child: Text(
                widget.illustrationEmoji!,
                style: const TextStyle(fontSize: 64),
              ),
            ),
          ),
        
        const SizedBox(height: 24),
        
        // Title with icon
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget.titleIcon != null) ...[
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  widget.titleIcon,
                  color: primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
            ],
            Flexible(
              child: Text(
                widget.title,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: WellnessColors.charcoalGray,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
        
        // Subtitle
        if (widget.subtitle != null) ...[
          const SizedBox(height: 12),
          Text(
            widget.subtitle!,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: WellnessColors.softGray,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  Widget _buildNextButton(Color primaryColor) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryColor, primaryColor.withOpacity(0.8)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.isLoading ? null : widget.onNext,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            alignment: Alignment.center,
            child: widget.isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.nextButtonText,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
