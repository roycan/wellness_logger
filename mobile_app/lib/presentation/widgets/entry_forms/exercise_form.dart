import 'package:flutter/material.dart';
import '../../../core/utils/service_locator_simple.dart';
import '../../../domain/entities/exercise.dart';
import '../../../domain/repositories/wellness_repository_simple.dart';

/// Form widget for creating Exercise entries
class ExerciseForm extends StatefulWidget {
  final Exercise? initialEntry;
  
  const ExerciseForm({super.key, this.initialEntry});

  @override
  State<ExerciseForm> createState() => _ExerciseFormState();
}

class _ExerciseFormState extends State<ExerciseForm> {
  final _formKey = GlobalKey<FormState>();
  final _durationController = TextEditingController();
  final _commentsController = TextEditingController();
  
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialEntry != null) {
      _populateForm(widget.initialEntry!);
    } else {
      // Set default values for new entries
      _durationController.text = '10 minutes';
    }
  }

  void _populateForm(Exercise entry) {
    _durationController.text = entry.duration ?? '';
    _commentsController.text = entry.comments ?? '';
    _selectedDate = entry.timestamp;
    _selectedTime = TimeOfDay.fromDateTime(entry.timestamp);
  }

  @override
  void dispose() {
    _durationController.dispose();
    _commentsController.dispose();
    super.dispose();
  }

  String? _validateDuration(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter exercise duration';
    }
    
    // Use the same regex from Exercise validation
    final durationPattern = RegExp(r'^(\d+)\s*(min|minute|minutes|hr|hour|hours|sec|second|seconds)\s*(\d+\s*(min|minute|minutes|sec|second|seconds))*$', caseSensitive: false);
    
    if (!durationPattern.hasMatch(value.trim())) {
      return 'Invalid format. Use: "30 minutes", "1 hour 30 minutes", etc.';
    }
    
    return null;
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _saveEntry() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final repository = serviceLocator<WellnessRepositorySimple>();
      
      final DateTime timestamp = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      final entry = Exercise(
        id: widget.initialEntry?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        timestamp: timestamp,
        duration: _durationController.text.trim().isEmpty ? null : _durationController.text.trim(),
        comments: _commentsController.text.trim().isEmpty ? null : _commentsController.text.trim(),
      );

      if (widget.initialEntry != null) {
        await repository.updateEntry(entry);
      } else {
        await repository.createEntry(entry);
      }

      if (mounted) {
        Navigator.of(context).pop(true); // Return true to indicate success
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.initialEntry != null ? 'Exercise updated!' : 'Exercise saved!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving entry: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Date and Time Selection
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'When did you exercise?',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _selectDate,
                            icon: const Icon(Icons.calendar_today),
                            label: Text('${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _selectTime,
                            icon: const Icon(Icons.access_time),
                            label: Text(_selectedTime.format(context)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),

            // Duration Field
            TextFormField(
              controller: _durationController,
              decoration: const InputDecoration(
                labelText: 'Duration *',
                hintText: 'e.g., "30 minutes", "1 hour 15 minutes"',
                border: OutlineInputBorder(),
              ),
              validator: _validateDuration,
            ),

            const SizedBox(height: 16),

            // Comments Field
            TextFormField(
              controller: _commentsController,
              decoration: const InputDecoration(
                labelText: 'Comments (Optional)',
                hintText: 'Exercise type, intensity, how you felt...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),

            const SizedBox(height: 24),

            // Save Button
            ElevatedButton(
              onPressed: _isLoading ? null : _saveEntry,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(widget.initialEntry != null ? 'Update Exercise' : 'Save Exercise'),
            ),
          ],
        ),
      ),
    );
  }
}
