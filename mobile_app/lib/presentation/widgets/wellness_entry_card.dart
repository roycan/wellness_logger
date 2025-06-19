import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/wellness_entry.dart';

/// Card widget for displaying wellness entry information.
/// 
/// This widget provides a consistent card layout for showing wellness
/// entries with appropriate styling based on the entry type.
class WellnessEntryCard extends StatelessWidget {
  const WellnessEntryCard({
    super.key,
    required this.entry,
    this.onTap,
  });

  final WellnessEntry entry;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Entry Header
              Row(
                children: [
                  // Entry Type Icon
                  Container(
                    padding: const EdgeInsets.all(AppConstants.smallPadding),
                    decoration: BoxDecoration(
                      color: colorScheme.getEntryTypeColor(entry.type).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                    ),
                    child: Icon(
                      _getEntryTypeIcon(entry.type),
                      color: colorScheme.getEntryTypeColor(entry.type),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: AppConstants.smallPadding),
                  
                  // Entry Type Label
                  Expanded(
                    child: Text(                        _getEntryTypeLabel(entry.type),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  
                  // Timestamp
                  Text(
                    _formatTime(entry.timestamp),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: AppConstants.smallPadding),
              
              // Entry Content
              if (entry.comments != null && entry.comments!.isNotEmpty) ...[
                Text(
                  entry.comments!,
                  style: theme.textTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppConstants.smallPadding),
              ],
              
              // Date
              Text(
                _formatDate(entry.timestamp),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getEntryTypeIcon(String entryType) {
    switch (entryType) {
      case AppConstants.entryTypeSVT:
        return Icons.favorite;
      case AppConstants.entryTypeExercise:
        return Icons.fitness_center;
      case AppConstants.entryTypeMedication:
        return Icons.medication;
      default:
        return Icons.circle;
    }
  }

  String _getEntryTypeLabel(String entryType) {
    switch (entryType) {
      case AppConstants.entryTypeSVT:
        return 'SVT Episode';
      case AppConstants.entryTypeExercise:
        return 'Exercise';
      case AppConstants.entryTypeMedication:
        return 'Medication';
      default:
        return 'Entry';
    }
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    
    return '$displayHour:$minute $period';
  }

  String _formatDate(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final entryDate = DateTime(dateTime.year, dateTime.month, dateTime.day);
    
    if (entryDate == today) {
      return 'Today';
    } else if (entryDate == yesterday) {
      return 'Yesterday';
    } else {
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${months[dateTime.month - 1]} ${dateTime.day}';
    }
  }
}
