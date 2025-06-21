import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/debug_storage.dart';
import '../../core/utils/debug_storage.dart';
import '../../core/utils/service_locator_simple.dart';
import '../../domain/repositories/wellness_repository_simple.dart';

/// Settings screen for app configuration and user preferences.
/// 
/// This screen provides access to:
/// - Theme settings (light/dark mode)
/// - Notification preferences
/// - Data management options
/// - About and help information
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late Box _settingsBox;
  bool _isLoading = true;
  
  // Settings values
  bool _notificationsEnabled = true;
  bool _dailyReminders = true;
  bool _medicationReminders = true;
  bool _exerciseReminders = false;
  String _reminderTime = '9:00 AM';
  String _exportFormat = 'CSV';
  bool _showTimeInEntries = true;
  bool _enableBackup = false;
  String _defaultSvtDuration = '1 minute';
  String _defaultExerciseDuration = '10 minutes';
  String _defaultMedicationDosage = '1/2 tablet';

  final List<String> _exportFormats = ['CSV', 'JSON', 'PDF'];
  final List<String> _durationOptions = ['< 1 minute', '1 minute', '2 minutes', '5 minutes', '10 minutes', '15 minutes', '30 minutes'];
  final List<String> _dosageOptions = ['1/4 tablet', '1/2 tablet', '1 tablet', '2 tablets', '1 ml', '2 ml', '5 ml'];
  final List<String> _reminderTimeOptions = ['7:00 AM', '8:00 AM', '9:00 AM', '10:00 AM', '11:00 AM', '12:00 PM', '1:00 PM', '2:00 PM', '6:00 PM', '7:00 PM', '8:00 PM', '9:00 PM'];

  @override
  void initState() {
    super.initState();
    _initializeSettings();
  }

  Future<void> _initializeSettings() async {
    try {
      _settingsBox = await Hive.openBox('settings');
      _loadSettings();
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading settings: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _loadSettings() {
    setState(() {
      _notificationsEnabled = _settingsBox.get('notifications_enabled', defaultValue: true);
      _dailyReminders = _settingsBox.get('daily_reminders', defaultValue: true);
      _medicationReminders = _settingsBox.get('medication_reminders', defaultValue: true);
      _exerciseReminders = _settingsBox.get('exercise_reminders', defaultValue: false);
      _reminderTime = _settingsBox.get('reminder_time', defaultValue: '9:00 AM');
      _exportFormat = _settingsBox.get('export_format', defaultValue: 'CSV');
      _showTimeInEntries = _settingsBox.get('show_time_in_entries', defaultValue: true);
      _enableBackup = _settingsBox.get('enable_backup', defaultValue: false);
      _defaultSvtDuration = _settingsBox.get('default_svt_duration', defaultValue: '1 minute');
      _defaultExerciseDuration = _settingsBox.get('default_exercise_duration', defaultValue: '10 minutes');
      _defaultMedicationDosage = _settingsBox.get('default_medication_dosage', defaultValue: '1/2 tablet');
    });
  }

  Future<void> _saveSetting(String key, dynamic value) async {
    try {
      await _settingsBox.put(key, value);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving setting: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildSettingsContent(),
    );
  }

  Widget _buildSettingsContent() {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildSection(
          'Appearance',
          [
            _buildSwitchTile(
              'Show Time in Entries',
              'Display time alongside date',
              Icons.schedule,
              _showTimeInEntries,
              (value) {
                setState(() {
                  _showTimeInEntries = value;
                });
                _saveSetting('show_time_in_entries', value);
              },
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildSection(
          'Notifications',
          [
            _buildSwitchTile(
              'Enable Notifications',
              'Receive reminders and alerts',
              Icons.notifications,
              _notificationsEnabled,
              (value) {
                setState(() {
                  _notificationsEnabled = value;
                });
                _saveSetting('notifications_enabled', value);
              },
            ),
            if (_notificationsEnabled) ...[
              const SizedBox(height: 8),
              _buildSwitchTile(
                'Daily Reminders',
                'Daily reminder to log wellness entries',
                Icons.today,
                _dailyReminders,
                (value) {
                  setState(() {
                    _dailyReminders = value;
                  });
                  _saveSetting('daily_reminders', value);
                },
              ),
              _buildSwitchTile(
                'Medication Reminders',
                'Reminders for medication timing',
                Icons.medication,
                _medicationReminders,
                (value) {
                  setState(() {
                    _medicationReminders = value;
                  });
                  _saveSetting('medication_reminders', value);
                },
              ),
              _buildSwitchTile(
                'Exercise Reminders',
                'Reminders to stay active',
                Icons.fitness_center,
                _exerciseReminders,
                (value) {
                  setState(() {
                    _exerciseReminders = value;
                  });
                  _saveSetting('exercise_reminders', value);
                },
              ),
              _buildDropdownTile(
                'Reminder Time',
                'Time for daily reminders',
                Icons.schedule,
                _reminderTime,
                _reminderTimeOptions,
                (value) {
                  setState(() {
                    _reminderTime = value!;
                  });
                  _saveSetting('reminder_time', value);
                },
              ),
            ],
          ],
        ),
        const SizedBox(height: 24),
        _buildSection(
          'Default Values',
          [
            _buildDropdownTile(
              'SVT Episode Duration',
              'Default duration for SVT episodes',
              Icons.favorite,
              _defaultSvtDuration,
              _durationOptions,
              (value) {
                setState(() {
                  _defaultSvtDuration = value!;
                });
                _saveSetting('default_svt_duration', value);
              },
            ),
            _buildDropdownTile(
              'Exercise Duration',
              'Default duration for exercise sessions',
              Icons.fitness_center,
              _defaultExerciseDuration,
              _durationOptions,
              (value) {
                setState(() {
                  _defaultExerciseDuration = value!;
                });
                _saveSetting('default_exercise_duration', value);
              },
            ),
            _buildDropdownTile(
              'Medication Dosage',
              'Default dosage for medications',
              Icons.medication,
              _defaultMedicationDosage,
              _dosageOptions,
              (value) {
                setState(() {
                  _defaultMedicationDosage = value!;
                });
                _saveSetting('default_medication_dosage', value);
              },
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildSection(
          'Data & Export',
          [
            _buildDropdownTile(
              'Export Format',
              'Default format for data export',
              Icons.download,
              _exportFormat,
              _exportFormats,
              (value) {
                setState(() {
                  _exportFormat = value!;
                });
                _saveSetting('export_format', value);
              },
            ),
            _buildSwitchTile(
              'Enable Backup',
              'Automatically backup data',
              Icons.backup,
              _enableBackup,
              (value) {
                setState(() {
                  _enableBackup = value;
                });
                _saveSetting('enable_backup', value);
              },
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildSection(
          'Actions',
          [
            _buildActionTile(
              'Export Data',
              'Export all wellness data',
              Icons.file_download,
              _exportData,
            ),
            _buildActionTile(
              'Clear Data',
              'Remove all wellness entries',
              Icons.delete_forever,
              _clearData,
              isDestructive: true,
            ),
            _buildActionTile(
              'Reset Settings',
              'Reset all settings to default',
              Icons.restore,
              _resetSettings,
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildSection(
          '🔍 DEBUG INFO',
          [
            _buildInfoTile(
              'Hive Status',
              Hive.isBoxOpen('wellness_entries') ? 'Box Open' : 'Box Closed',
              Icons.storage,
            ),
            _buildInfoTile(
              'Hive Path',
              'Default path used',
              Icons.folder,
            ),
            _buildActionTile(
              'View Debug Log',
              'Check app debug information',
              Icons.bug_report,
              _showDebugLog,
            ),
            _buildActionTile(
              'Clear Debug Log',
              'Clear debug information',
              Icons.clear_all,
              _clearDebugLog,
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildSection(
          'About',
          [
            _buildInfoTile(
              'Version',
              '1.0.0',
              Icons.info,
            ),
            _buildInfoTile(
              'Build',
              'Phase 4 - Complete',
              Icons.build,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
      ),
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildDropdownTile(
    String title,
    String subtitle,
    IconData icon,
    String value,
    List<String> options,
    ValueChanged<String?> onChanged,
  ) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: DropdownButton<String>(
        value: value,
        items: options.map((option) {
          return DropdownMenuItem<String>(
            value: option,
            child: Text(option),
          );
        }).toList(),
        onChanged: onChanged,
      ),
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildActionTile(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? Colors.red : null,
      ),
      title: Text(
        title,
        style: isDestructive ? const TextStyle(color: Colors.red) : null,
      ),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildInfoTile(
    String title,
    String value,
    IconData icon,
  ) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: Text(
        value,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Colors.grey[600],
        ),
      ),
      contentPadding: EdgeInsets.zero,
    );
  }

  void _exportData() {
    // TODO: Implement data export functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Export functionality will be implemented'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _clearData() async {

    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text(
          'This will permanently delete all your wellness entries. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {

              Navigator.of(context).pop();
              _performClearData();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear Data'),
          ),
        ],
      ),
    );
  }

  Future<void> _performClearData() async {
    try {
      // TODO: Clear data from repository
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data clearing functionality will be implemented'),
          backgroundColor: Colors.orange,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error clearing data: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _resetSettings() async {

    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Settings'),
        content: const Text(
          'This will reset all settings to their default values.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {

              Navigator.of(context).pop();
              _performResetSettings();
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  Future<void> _performResetSettings() async {
    try {
      await _settingsBox.clear();
      _loadSettings();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Settings reset to default'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error resetting settings: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showDebugLog() async {
    try {
      final debugContent = await DebugStorage.readDebugInfo();
      if (!mounted) return;
      
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Debug Log'),
          content: SizedBox(
            width: double.maxFinite,
            height: 400,
            child: SingleChildScrollView(
              child: Text(
                debugContent.isEmpty ? 'No debug information available' : debugContent,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error reading debug log: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _clearDebugLog() async {
    try {
      await DebugStorage.clearDebugInfo();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debug log cleared'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error clearing debug log: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
