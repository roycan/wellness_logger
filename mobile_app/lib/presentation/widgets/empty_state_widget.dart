import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/service_locator_simple.dart';
import '../../domain/repositories/wellness_repository_simple.dart';

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
            
            // DEBUG INFO - Always visible in empty state
            const SizedBox(height: AppConstants.largePadding),
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                border: Border.all(color: Colors.red, width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  const Text(
                    '🔍 DEBUG INFO',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildDebugInfo(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDebugInfo() {
    try {
      final repository = serviceLocator<WellnessRepositorySimple>();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final isHiveOpen = Hive.isBoxOpen('wellness_entries');
      
      return Column(
        children: [
          Text(
            'Repository ready: ${repository.isReady}',
            style: const TextStyle(color: Colors.red, fontSize: 12),
          ),
          Text(
            'Hive box open: $isHiveOpen',
            style: const TextStyle(color: Colors.red, fontSize: 12),
          ),
          Text(
            'Build: $timestamp',
            style: const TextStyle(color: Colors.red, fontSize: 12),
          ),
          Text(
            'App launch: ${DateTime.now().toString().substring(11, 19)}',
            style: const TextStyle(color: Colors.red, fontSize: 12),
          ),
        ],
      );
    } catch (e) {
      return Text(
        'Debug error: $e',
        style: const TextStyle(color: Colors.red, fontSize: 12),
      );
    }
  }
}
