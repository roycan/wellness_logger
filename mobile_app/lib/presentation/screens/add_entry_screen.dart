import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../widgets/entry_forms/svt_form.dart';
import '../widgets/entry_forms/exercise_form.dart';
import '../widgets/entry_forms/medication_form.dart';

/// Screen for adding new wellness entries with type selection and form
class AddEntryScreen extends StatefulWidget {
  final int initialTabIndex;
  
  const AddEntryScreen({
    super.key,
    this.initialTabIndex = 0,
  });

  @override
  State<AddEntryScreen> createState() => _AddEntryScreenState();
}

class _AddEntryScreenState extends State<AddEntryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedIndex = 0;

  final List<String> _entryTypes = [
    AppConstants.entryTypeSVT,
    AppConstants.entryTypeExercise,
    AppConstants.entryTypeMedication,
  ];

  final List<String> _entryLabels = [
    'SVT Episode',
    'Exercise',
    'Medication',
  ];

  final List<IconData> _entryIcons = [
    Icons.favorite,
    Icons.fitness_center,
    Icons.medication,
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialTabIndex;
    _tabController = TabController(
      length: _entryTypes.length, 
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _selectedIndex = _tabController.index;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Entry'),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        bottom: TabBar(
          controller: _tabController,
          tabs: List.generate(_entryTypes.length, (index) {
            return Tab(
              icon: Icon(_entryIcons[index]),
              text: _entryLabels[index],
            );
          }),
          labelColor: Theme.of(context).colorScheme.primary,
          unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
          indicatorColor: Theme.of(context).colorScheme.primary,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          const SvtForm(),
          const ExerciseForm(),
          const MedicationForm(),
        ],
      ),
    );
  }
}
