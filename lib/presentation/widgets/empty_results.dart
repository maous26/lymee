// lib/presentation/widgets/empty_results.dart
import 'package:flutter/material.dart';
import 'package:lym_nutrition/presentation/themes/fresh_theme.dart';

class EmptyResults extends StatelessWidget {
  final String message;
  final String? submessage;
  final IconData icon;
  final Color color;
  final String? actionLabel;
  final VoidCallback? onActionPressed;

  const EmptyResults({
    Key? key,
    required this.message,
    this.submessage,
    this.icon = Icons.search_off,
    this.color = FreshTheme.primaryMint,
    this.actionLabel,
    this.onActionPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 36,
              backgroundColor: color.withOpacity(0.1),
              child: Icon(icon, color: color, size: 36),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: FreshTheme.midnightGray,
              ),
            ),
            if (submessage != null) ...[
              const SizedBox(height: 8),
              Text(
                submessage!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: FreshTheme.stormGray,
                ),
              ),
            ],
            if (actionLabel != null && onActionPressed != null) ...[
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: onActionPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                ),
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
