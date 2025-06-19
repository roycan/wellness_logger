import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';

/// Widget for displaying empty states with consistent styling.
/// 
/// This widget provides a reusable empty state component with
/// icon, title, message, and optional action button.
class EmptyStateWidget extends StatelessWidget {
  const EmptyStateWidget({
    super.key,
    required this.icon,
    this.title,
    this.message,
    this.actionText,
    this.onActionPressed,
  });

  final IconData icon;
  final String? title;
  final String? message;
  final String? actionText;
  final VoidCallback? onActionPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.largePadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon
            Icon(
              icon,
              size: 64,
              color: colorScheme.onSurface.withOpacity(0.3),
            ),
            
            const SizedBox(height: AppConstants.defaultPadding),
            
            // Title
            if (title != null) ...[
              Text(
                title!,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppConstants.smallPadding),
            ],
            
            // Message
            if (message != null) ...[
              Text(
                message!,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.6),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppConstants.defaultPadding),
            ],
            
            // Action Button
            if (actionText != null && onActionPressed != null)
              FilledButton(
                onPressed: onActionPressed,
                child: Text(actionText!),
              ),
          ],
        ),
      ),
    );
  }
}
