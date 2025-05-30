// lib/presentation/widgets/brand_filter_bar.dart
import 'package:flutter/material.dart';
import 'package:lym_nutrition/presentation/themes/premium_theme.dart';

class BrandFilterBar extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final Function(String) onBrandFilter;
  final VoidCallback onClear;
  final bool isVisible;

  const BrandFilterBar({
    Key? key,
    required this.controller,
    required this.focusNode,
    required this.onBrandFilter,
    required this.onClear,
    this.isVisible = true,
  }) : super(key: key);

  @override
  State<BrandFilterBar> createState() => _BrandFilterBarState();
}

class _BrandFilterBarState extends State<BrandFilterBar> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _heightAnimation;
  bool _showClearButton = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: PremiumTheme.animationMedium,
    );
    _heightAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    if (widget.isVisible) {
      _animationController.forward();
    }

    widget.controller.addListener(_onTextChanged);
  }

  @override
  void didUpdateWidget(BrandFilterBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isVisible != oldWidget.isVisible) {
      if (widget.isVisible) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = widget.controller.text.isNotEmpty;
    if (_showClearButton != hasText) {
      setState(() {
        _showClearButton = hasText;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizeTransition(
      sizeFactor: _heightAnimation,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(PremiumTheme.borderRadiusMedium),
          border: Border.all(
            color: PremiumTheme.secondaryColor.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: PremiumTheme.shadowSmall,
        ),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Icon(
                Icons.business,
                color: PremiumTheme.secondaryColor,
                size: 20,
              ),
            ),
            Expanded(
              child: TextField(
                controller: widget.controller,
                focusNode: widget.focusNode,
                textInputAction: TextInputAction.search,
                onSubmitted: widget.onBrandFilter,
                decoration: InputDecoration(
                  hintText: 'Filtrer par marque...',
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  isDense: true,
                ),
                style: theme.textTheme.bodyMedium,
              ),
            ),
            if (_showClearButton)
              IconButton(
                icon: const Icon(
                  Icons.clear,
                  color: PremiumTheme.secondaryColor,
                  size: 20,
                ),
                onPressed: () {
                  widget.controller.clear();
                  widget.onClear();
                },
              ),
          ],
        ),
      ),
    );
  }
}