import 'package:flutter/material.dart';
import 'package:lym_nutrition/presentation/themes/enhanced_theme.dart';

/// Info tooltip widget to explain app features to users
/// Provides contextual help with beautiful design and animations
class InfoTooltip extends StatefulWidget {
  final String title;
  final String message;
  final Widget child;
  final IconData icon;
  final Color? color;
  final bool showOnTap;
  final VoidCallback? onShow;
  final VoidCallback? onHide;

  const InfoTooltip({
    super.key,
    required this.title,
    required this.message,
    required this.child,
    this.icon = Icons.info_outline,
    this.color,
    this.showOnTap = true,
    this.onShow,
    this.onHide,
  });

  @override
  State<InfoTooltip> createState() => _InfoTooltipState();
}

class _InfoTooltipState extends State<InfoTooltip>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  OverlayEntry? _overlayEntry;
  bool _isShowing = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _hideTooltip();
    _controller.dispose();
    super.dispose();
  }

  void _showTooltip() {
    if (_isShowing) return;

    final overlay = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    _overlayEntry = OverlayEntry(
      builder: (context) => _TooltipOverlay(
        title: widget.title,
        message: widget.message,
        icon: widget.icon,
        color: widget.color ?? EnhancedTheme.primaryTeal,
        targetOffset: offset,
        targetSize: size,
        scaleAnimation: _scaleAnimation,
        fadeAnimation: _fadeAnimation,
        onDismiss: _hideTooltip,
      ),
    );

    overlay.insert(_overlayEntry!);
    _controller.forward();
    _isShowing = true;
    widget.onShow?.call();
  }

  void _hideTooltip() {
    if (!_isShowing) return;

    _controller.reverse().then((_) {
      _overlayEntry?.remove();
      _overlayEntry = null;
      _isShowing = false;
      widget.onHide?.call();
    });
  }

  void _toggleTooltip() {
    if (_isShowing) {
      _hideTooltip();
    } else {
      _showTooltip();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.showOnTap ? _toggleTooltip : null,
      onLongPress: !widget.showOnTap ? _showTooltip : null,
      child: widget.child,
    );
  }
}

class _TooltipOverlay extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final Color color;
  final Offset targetOffset;
  final Size targetSize;
  final Animation<double> scaleAnimation;
  final Animation<double> fadeAnimation;
  final VoidCallback onDismiss;

  const _TooltipOverlay({
    required this.title,
    required this.message,
    required this.icon,
    required this.color,
    required this.targetOffset,
    required this.targetSize,
    required this.scaleAnimation,
    required this.fadeAnimation,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final tooltipWidth = 280.0;
    final tooltipHeight = 180.0;

    // Calculate tooltip position
    double left = targetOffset.dx + targetSize.width / 2 - tooltipWidth / 2;
    double top = targetOffset.dy - tooltipHeight - 16;

    // Adjust for screen boundaries
    if (left < 16) left = 16;
    if (left + tooltipWidth > screenSize.width - 16) {
      left = screenSize.width - tooltipWidth - 16;
    }
    if (top < 60) {
      top = targetOffset.dy + targetSize.height + 16;
    }

    return Stack(
      children: [
        // Background overlay
        GestureDetector(
          onTap: onDismiss,
          child: Container(
            width: screenSize.width,
            height: screenSize.height,
            color: Colors.black.withValues(alpha: 0.3),
          ),
        ),
        // Tooltip
        Positioned(
          left: left,
          top: top,
          child: AnimatedBuilder(
            animation: scaleAnimation,
            builder: (context, child) => Transform.scale(
              scale: scaleAnimation.value,
              child: FadeTransition(
                opacity: fadeAnimation,
                child: Material(
                  elevation: 8,
                  borderRadius: BorderRadius.circular(EnhancedTheme.radiusM),
                  color: Colors.transparent,
                  child: Container(
                    width: tooltipWidth,
                    padding: const EdgeInsets.all(EnhancedTheme.spacingM),
                    decoration: BoxDecoration(
                      color: EnhancedTheme.neutralWhite,
                      borderRadius:
                          BorderRadius.circular(EnhancedTheme.radiusM),
                      border: Border.all(
                        color: color.withValues(alpha: 0.2),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(alpha: 0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                        ...EnhancedTheme.shadowMedium,
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Row(
                          children: [
                            Container(
                              padding:
                                  const EdgeInsets.all(EnhancedTheme.spacingS),
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(
                                    EnhancedTheme.radiusS),
                              ),
                              child: Icon(
                                icon,
                                color: color,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: EnhancedTheme.spacingS),
                            Expanded(
                              child: Text(
                                title,
                                style: EnhancedTheme.textTheme.titleMedium
                                    ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: EnhancedTheme.neutralGray800,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: onDismiss,
                              icon: const Icon(
                                Icons.close,
                                size: 18,
                                color: EnhancedTheme.neutralGray400,
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 32,
                                minHeight: 32,
                              ),
                              padding: EdgeInsets.zero,
                            ),
                          ],
                        ),
                        const SizedBox(height: EnhancedTheme.spacingS),
                        // Message
                        Text(
                          message,
                          style: EnhancedTheme.textTheme.bodyMedium?.copyWith(
                            color: EnhancedTheme.neutralGray600,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: EnhancedTheme.spacingM),
                        // Action button
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: onDismiss,
                            child: Text(
                              'Compris !',
                              style:
                                  EnhancedTheme.textTheme.labelMedium?.copyWith(
                                color: color,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        // Arrow pointing to target
        Positioned(
          left: targetOffset.dx + targetSize.width / 2 - 8,
          top: top < targetOffset.dy ? top + tooltipHeight : top - 16,
          child: FadeTransition(
            opacity: fadeAnimation,
            child: CustomPaint(
              painter: _ArrowPainter(
                color: EnhancedTheme.neutralWhite,
                borderColor: color.withValues(alpha: 0.2),
                pointingUp: top > targetOffset.dy,
              ),
              size: const Size(16, 8),
            ),
          ),
        ),
      ],
    );
  }
}

class _ArrowPainter extends CustomPainter {
  final Color color;
  final Color borderColor;
  final bool pointingUp;

  _ArrowPainter({
    required this.color,
    required this.borderColor,
    required this.pointingUp,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final path = Path();

    if (pointingUp) {
      path.moveTo(size.width / 2, 0);
      path.lineTo(0, size.height);
      path.lineTo(size.width, size.height);
    } else {
      path.moveTo(0, 0);
      path.lineTo(size.width, 0);
      path.lineTo(size.width / 2, size.height);
    }
    path.close();

    canvas.drawPath(path, paint);
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Pre-built info tooltips for common app features
class ProgressionInfoTooltip extends StatelessWidget {
  final Widget child;

  const ProgressionInfoTooltip({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return InfoTooltip(
      title: 'Système de Progression',
      message:
          'Gagnez des XP en atteignant vos objectifs nutritionnels quotidiens ! '
          '• 1 calorie consommée = 1 XP\n'
          '• Débloquez de nouveaux niveaux\n'
          '• Collectez des succès spéciaux\n'
          '• Suivez votre progression à long terme',
      icon: Icons.trending_up,
      color: EnhancedTheme.primaryTeal,
      child: child,
    );
  }
}

class MacroInfoTooltip extends StatelessWidget {
  final Widget child;

  const MacroInfoTooltip({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return InfoTooltip(
      title: 'Macronutriments',
      message: 'Surveillez votre équilibre nutritionnel :\n'
          '• Protéines : construction musculaire\n'
          '• Glucides : énergie et performance\n'
          '• Lipides : hormones et vitamines\n'
          'Objectif : atteindre 100% sans dépasser 150%',
      icon: Icons.pie_chart,
      color: EnhancedTheme.secondaryOrange,
      child: child,
    );
  }
}

class MealTrackingInfoTooltip extends StatelessWidget {
  final Widget child;

  const MealTrackingInfoTooltip({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return InfoTooltip(
      title: 'Suivi des Repas',
      message: 'Organisez votre alimentation par repas :\n'
          '• Petit-déjeuner, Déjeuner, Dîner, Collations\n'
          '• Calculez automatiquement les calories\n'
          '• Équilibrez vos macronutriments\n'
          '• Atteignez vos objectifs quotidiens',
      icon: Icons.restaurant_menu,
      color: EnhancedTheme.successGreen,
      child: child,
    );
  }
}
