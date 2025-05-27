import 'package:flutter/material.dart';
import 'package:lym_nutrition/presentation/themes/app_theme.dart';

class AnimatedSearchBar extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onSearch;
  final VoidCallback onClear;
  final String hintText;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final bool autoFocus;
  final FocusNode? focusNode;

  const AnimatedSearchBar({
    Key? key,
    required this.controller,
    required this.onSearch,
    required this.onClear,
    this.hintText = 'Rechercher...',
    this.backgroundColor,
    this.borderRadius,
    this.autoFocus = false,
    this.focusNode,
  }) : super(key: key);

  @override
  State<AnimatedSearchBar> createState() => _AnimatedSearchBarState();
}

class _AnimatedSearchBarState extends State<AnimatedSearchBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _showClearButton = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: AppTheme.animationMedium,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    // Animer automatiquement à l'initialisation
    _animationController.forward();

    // Écouter les changements dans le champ de recherche
    widget.controller.addListener(_onTextChanged);
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

    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        decoration: BoxDecoration(
          color: widget.backgroundColor ?? theme.cardTheme.color,
          borderRadius:
              widget.borderRadius ??
              BorderRadius.circular(AppTheme.borderRadiusLarge),
          boxShadow: AppTheme.shadowSmall,
        ),
        child: TextField(
          controller: widget.controller,
          focusNode: widget.focusNode,
          autofocus: widget.autoFocus,
          textInputAction: TextInputAction.search,
          onSubmitted: (_) => widget.onSearch(),
          decoration: InputDecoration(
            hintText: widget.hintText,
            prefixIcon: const Icon(Icons.search, color: AppTheme.primaryColor),
            suffixIcon:
                _showClearButton
                    ? IconButton(
                      icon: const Icon(
                        Icons.clear,
                        color: AppTheme.primaryColor,
                      ),
                      onPressed: () {
                        widget.controller.clear();
                        widget.onClear();
                      },
                    )
                    : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          style: theme.textTheme.bodyLarge,
        ),
      ),
    );
  }
}
