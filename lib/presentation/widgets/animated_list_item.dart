// lib/presentation/widgets/animated_list_item.dart
import 'package:flutter/material.dart';
import 'package:lym_nutrition/presentation/themes/premium_theme.dart';

class AnimatedListItem extends StatefulWidget {
  final Widget child;
  final int index;
  final Duration? duration;
  final double startOffset;
  final Curve curve;
  final bool fadeIn;

  const AnimatedListItem({
    Key? key,
    required this.child,
    required this.index,
    this.duration,
    this.startOffset = 100.0,
    this.curve = Curves.easeOutQuart,
    this.fadeIn = true,
  }) : super(key: key);

  @override
  State<AnimatedListItem> createState() => _AnimatedListItemState();
}

class _AnimatedListItemState extends State<AnimatedListItem> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _offsetAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: widget.duration ?? PremiumTheme.animationMedium,
    );

    _offsetAnimation = Tween<double>(
      begin: widget.startOffset,
      end: 0.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: widget.curve,
      ),
    );

    _opacityAnimation = Tween<double>(
      begin: widget.fadeIn ? 0.0 : 1.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: widget.curve,
      ),
    );

    // Décalage de l'animation en fonction de l'index
    Future.delayed(Duration(milliseconds: 30 * widget.index), () {
      if (mounted) {
        _animationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _offsetAnimation.value),
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}
