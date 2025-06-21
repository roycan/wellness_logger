import 'package:flutter/material.dart';
import '../../../core/utils/service_locator_simple.dart';
import '../../../domain/entities/medication.dart';
import '../../../domain/repositories/wellness_repository_simple.dart';

/// Form widget for creating Medication entries
class MedicationForm extends StatefulWidget {
  final Medication? initialEntry;
  
  const MedicationForm({super.key, this.initialEntry});

  @override
  State<MedicationForm> createState() => _MedicationFormState();
}

class _MedicationFormState extends State<MedicationForm> {
  final _formKey = GlobalKey<FormState>();
  final _dosageController = TextEditingController();
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
      _dosageController.text = '1/2 tablet';
    }
  }

  void _populateForm(Medication entry) {
    _dosageController.text = entry.dosage ?? '';
    _commentsController.text = entry.comments ?? '';
    _selectedDate = entry.timestamp;
    _selectedTime = TimeOfDay.fromDateTime(entry.timestamp);
  }

  @override
  void dispose() {
    _dosageController.dispose();
    _commentsController.dispose();
    super.dispose();
  }

  String? _validateDosage(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter dosage';
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

      final entry = Medication(
        id: widget.initialEntry?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        timestamp: timestamp,
        dosage: _dosageController.text.trim().isEmpty ? null : _dosageController.text.trim(),
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
            content: Text(widget.initialEntry != null ? 'Medication updated!' : 'Medication saved!'),
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
            // Important medication notice
            Card(
              color: Theme.of(context).colorScheme.secondaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'This is for tracking purposes only. Always consult your healthcare provider for medical advice.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSecondaryContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Date and Time Selection
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'When did you take the medication?',
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

            // Dosage Field
            TextFormField(
              controller: _dosageController,
              decoration: const InputDecoration(
                labelText: 'Dosage *',
                hintText: 'e.g., 25 mg, 1 tablet, 5 ml',
                border: OutlineInputBorder(),
              ),
              validator: _validateDosage,
            ),

            const SizedBox(height: 16),

            // Comments Field
            TextFormField(
              controller: _commentsController,
              decoration: const InputDecoration(
                labelText: 'Comments (Optional)',
                hintText: 'Medication name, reason taken, side effects, etc...',
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
                  : Text(widget.initialEntry != null ? 'Update Medication' : 'Save Medication'),
            ),
          ],
        ),
      ),
    );
  }
}
