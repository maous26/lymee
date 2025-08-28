// lib/presentation/widgets/fresh_components.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lym_nutrition/presentation/themes/fresh_theme.dart';

class FreshProgressCircle extends StatelessWidget {
  final int current;
  final int target;
  final double size;
  const FreshProgressCircle({
    super.key,
    required this.current,
    required this.target,
    this.size = 120,
  });

  @override
  Widget build(BuildContext context) {
    final percent = (current / (target == 0 ? 1 : target)).clamp(0.0, 1.0);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: percent),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutBack,
      builder: (_, value, __) => Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: value,
              strokeWidth: 10,
              backgroundColor: Colors.black12,
              color: FreshTheme.primaryMint,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${(value * target).round()}/$target',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: FreshTheme.midnightGray,
                ),
              ),
              Text(
                'kcal',
                style: GoogleFonts.inter(color: Colors.black54),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ShimmerBox extends StatelessWidget {
  final double height;
  final double width;
  final double radius;
  const ShimmerBox({
    super.key,
    this.height = 16,
    this.width = 120,
    this.radius = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.06),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

class BounceTap extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  const BounceTap({super.key, required this.child, required this.onTap});

  @override
  State<BounceTap> createState() => _BounceTapState();
}

class _BounceTapState extends State<BounceTap>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      reverseDuration: const Duration(milliseconds: 120),
      lowerBound: 0.0,
      upperBound: 0.08,
    );
    _scale = Tween<double>(begin: 1.0, end: 0.92).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) async {
        await _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) => Transform.scale(
          scale: _scale.value,
          child: child,
        ),
        child: widget.child,
      ),
    );
  }
}

