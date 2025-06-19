import 'package:flutter/material.dart';
import '../../domain/entities/wellness_entry.dart';
import '../../domain/entities/svt_episode.dart';
import '../../domain/entities/exercise.dart';
import '../../domain/entities/medication.dart';
import '../../core/constants/app_constants.dart';
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
      ),
      body: _buildForm(),
    );
  }
}
