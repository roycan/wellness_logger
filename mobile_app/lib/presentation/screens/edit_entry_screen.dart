import 'package:flutter/material.dart';
import '../../domain/entities/wellness_entry.dart';
import '../../domain/entities/svt_episode.dart';
import '../../domain/entities/exercise.dart';
import '../../domain/entities/medication.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/service_locator_simple.dart';
import '../../domain/repositories/wellness_repository_simple.dart';
import '../widgets/entry_forms/svt_form.dart';
import '../widgets/entry_forms/exercise_form.dart';
import '../widgets/entry_forms/medication_form.dart';

/// Screen for editing existing wellness entries
class EditEntryScreen extends StatelessWidget {
  final WellnessEntry entry;

  const EditEntryScreen({
    super.key,
    required this.entry,
  });

  String get _entryTypeName {
    switch (entry.type) {
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

  IconData get _entryTypeIcon {
    switch (entry.type) {
      case AppConstants.entryTypeSVT:
        return Icons.favorite;
      case AppConstants.entryTypeExercise:
        return Icons.fitness_center;
      case AppConstants.entryTypeMedication:
        return Icons.medication;
      default:
        return Icons.note;
    }
  }

  Widget _buildForm() {
    switch (entry.type) {
      case AppConstants.entryTypeSVT:
        return SvtForm(initialEntry: entry as SvtEpisode);
      case AppConstants.entryTypeExercise:
        return ExerciseForm(initialEntry: entry as Exercise);
      case AppConstants.entryTypeMedication:
        return MedicationForm(initialEntry: entry as Medication);
      default:
        return const SizedBox.shrink();
    }
  }

  Future<void> _showDeleteConfirmationDialog(BuildContext context) async {
    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Entry'),
          content: Text('Are you sure you want to delete this $_entryTypeName entry? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true && context.mounted) {
      await _deleteEntry(context);
    }
  }

  Future<void> _deleteEntry(BuildContext context) async {
    try {
      final repository = serviceLocator<WellnessRepositorySimple>();
      final success = await repository.deleteEntry(entry.id);
      
      if (context.mounted) {
        if (success) {
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$_entryTypeName deleted successfully'),
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
          );
          // Go back to previous screen
          Navigator.of(context).pop(true); // Return true to indicate deletion
        } else {
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Failed to delete entry. Please try again.'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting entry: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit $_entryTypeName'),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _showDeleteConfirmationDialog(context),
            tooltip: 'Delete $_entryTypeName',
          ),
        ],
      ),
      body: _buildForm(),
    );
  }
}
