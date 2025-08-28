import 'package:flutter/material.dart';
import 'package:lym_nutrition/presentation/themes/fresh_theme.dart';

// Modern, health-focused, and memorable Nutrition Score Badge
class NutritionScoreBadge extends StatefulWidget {
  final double score;
  final double size;
  final bool showLabel;
  final bool useGradient;

  const NutritionScoreBadge({
    Key? key,
    required this.score,
    this.size = 56, // Larger by default for impact
    this.showLabel = false,
    this.useGradient = true,
  }) : super(key: key);

  @override
  State<NutritionScoreBadge> createState() => _NutritionScoreBadgeState();
}

class _NutritionScoreBadgeState extends State<NutritionScoreBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnim;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = FreshTheme.getNutritionScoreColor(widget.score);
    final label = FreshTheme.getNutritionScoreLabel(widget.score);
    final scoreText = widget.score.toStringAsFixed(1);
    const badgeIcon = Icons.eco_rounded; // Health/eco icon

    return Semantics(
      label: 'Score nutritionnel: $scoreText, $label',
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedBuilder(
          animation: _pulseAnim,
          builder: (context, child) {
            final scale = _pressed ? 1.12 : _pulseAnim.value;
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedScale(
                  scale: scale,
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOut,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Animated glowing background
                      Container(
                        width: widget.size + 18,
                        height: widget.size + 18,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              color.withOpacity(0.18),
                              color.withOpacity(0.04),
                            ],
                            radius: 0.8,
                          ),
                        ),
                      ),
                      // Main badge
                      Container(
                        width: widget.size,
                        height: widget.size,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: widget.useGradient
                              ? LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    color.withOpacity(0.92),
                                    color.withOpacity(0.78),
                                    color.withOpacity(1.0),
                                  ],
                                )
                              : null,
                          color: widget.useGradient ? null : color,
                          boxShadow: [
                            BoxShadow(
                              color: color.withOpacity(0.22),
                              blurRadius: 18,
                              spreadRadius: 2,
                            ),
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              spreadRadius: 0,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Friendly health icon (subtle, background)
                            Positioned(
                              bottom: 8,
                              right: 8,
                              child: Icon(
                                badgeIcon,
                                color: Colors.white.withOpacity(0.13),
                                size: widget.size * 0.34,
                                semanticLabel: 'Symbole santé',
                              ),
                            ),
                            // Score text
                            Text(
                              scoreText,
                              style: theme.textTheme.displayMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontFamily: 'Nunito', // Rounded, friendly font
                                letterSpacing: 1.3,
                                fontSize: widget.size * 0.44,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (widget.showLabel)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          badgeIcon,
                          color: color.withOpacity(0.7),
                          size: 18,
                          semanticLabel: 'Symbole santé',
                        ),
                        const SizedBox(width: 6),
                        Text(
                          label,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: color,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Nunito',
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
