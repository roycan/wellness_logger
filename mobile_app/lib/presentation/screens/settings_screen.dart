import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/debug_storage.dart';
import '../../core/utils/service_locator_simple.dart';
import '../../domain/repositories/wellness_repository_simple.dart';
import '../../data/services/settings_service.dart';

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
  late SettingsService _settingsService;
  late WellnessRepositorySimple _repository;
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
      _settingsService = serviceLocator<SettingsService>();
      _repository = serviceLocator<WellnessRepositorySimple>();
      await _loadSettings();
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

  Future<void> _loadSettings() async {
    _notificationsEnabled = await _settingsService.getBool('notifications_enabled', defaultValue: true);
    _dailyReminders = await _settingsService.getBool('daily_reminders', defaultValue: true);
    _medicationReminders = await _settingsService.getBool('medication_reminders', defaultValue: true);
    _exerciseReminders = await _settingsService.getBool('exercise_reminders', defaultValue: false);
    _reminderTime = await _settingsService.getString('reminder_time', defaultValue: '9:00 AM');
    _exportFormat = await _settingsService.getString('export_format', defaultValue: 'CSV');
    _showTimeInEntries = await _settingsService.getBool('show_time_in_entries', defaultValue: true);
    _enableBackup = await _settingsService.getBool('enable_backup', defaultValue: false);
    _defaultSvtDuration = await _settingsService.getString('default_svt_duration', defaultValue: '1 minute');
    _defaultExerciseDuration = await _settingsService.getString('default_exercise_duration', defaultValue: '10 minutes');
    _defaultMedicationDosage = await _settingsService.getString('default_medication_dosage', defaultValue: '1/2 tablet');
    
    setState(() {});
  }

  Future<void> _saveSetting(String key, dynamic value) async {
    try {
      if (value is bool) {
        await _settingsService.setBool(key, value);
      } else {
        await _settingsService.setString(key, value.toString());
      }
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
              'Import Data',
              'Import wellness data from file',
              Icons.file_upload,
              _importData,
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
              'Database Status',
              'SQLite Database Active',
              Icons.storage,
            ),
            _buildInfoTile(
              'Storage Type',
              'SQLite with Settings Service',
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

  void _exportData() async {
    try {
      // Show export options dialog
      final selectedFormat = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Export Data'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Choose export format:'),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.table_chart),
                title: const Text('CSV (for doctors)'),
                subtitle: const Text('Medical-friendly format'),
                onTap: () => Navigator.of(context).pop('CSV'),
              ),
              ListTile(
                leading: const Icon(Icons.code),
                title: const Text('JSON (for backup)'),
                subtitle: const Text('Complete data backup'),
                onTap: () => Navigator.of(context).pop('JSON'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        ),
      );

      if (selectedFormat == null) return;

      // Show loading indicator
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                height: 16,
                width: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 16),
              Text('Exporting data...'),
            ],
          ),
          duration: Duration(seconds: 2),
        ),
      );

      String data;
      String filename;
      String mimeType;

      if (selectedFormat == 'CSV') {
        data = await _repository.exportToCsv();
        filename = 'wellness_data_${DateTime.now().toIso8601String().split('T')[0]}.csv';
        mimeType = 'text/csv';
      } else {
        final jsonData = await _repository.exportToJson();
        data = const JsonEncoder.withIndent('  ').convert(jsonData);
        filename = 'wellness_backup_${DateTime.now().toIso8601String().split('T')[0]}.json';
        mimeType = 'application/json';
      }

      if (data.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No data to export'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // Save to temporary file and share
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/$filename');
      await file.writeAsString(data);

      // Share the file
      await Share.shareXFiles(
        [XFile(file.path, mimeType: mimeType)],
        subject: selectedFormat == 'CSV' 
          ? 'Wellness Data for Medical Review' 
          : 'Wellness Data Backup',
        text: selectedFormat == 'CSV'
          ? 'Please find my wellness tracking data attached. This includes my SVT episodes, exercise sessions, and medication records.'
          : 'Backup of wellness tracking data from ${DateTime.now().toLocal().toString().split(' ')[0]}',
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Data exported successfully as $selectedFormat'),
          backgroundColor: Colors.green,
          action: SnackBarAction(
            label: 'Share Again',
            onPressed: () async {
              await Share.shareXFiles([XFile(file.path, mimeType: mimeType)]);
            },
          ),
        ),
      );

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Export failed: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _importData() async {
    // Show information dialog about import process
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Import Data'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'To import your backup data:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Text('1. Open your backup JSON file'),
            Text('2. Copy all the JSON content'),
            Text('3. Tap "Paste & Import" below'),
            Text('4. Paste the JSON data when prompted'),
            SizedBox(height: 12),
            Text(
              'Note: This will merge with existing data. Duplicate entries will be updated.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showImportDialog();
            },
            child: const Text('Paste & Import'),
          ),
        ],
      ),
    );
  }

  void _showImportDialog() async {
    final TextEditingController controller = TextEditingController();
    
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Paste JSON Data'),
        content: SizedBox(
          width: double.maxFinite,
          height: 200,
          child: TextField(
            controller: controller,
            maxLines: null,
            expands: true,
            decoration: const InputDecoration(
              hintText: 'Paste your backup JSON data here...',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: const Text('Import'),
          ),
        ],
      ),
    );

    if (result == null || result.trim().isEmpty) return;

    try {
      // Show loading indicator
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                height: 16,
                width: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 16),
              Text('Importing data...'),
            ],
          ),
          duration: Duration(seconds: 3),
        ),
      );

      final jsonData = jsonDecode(result) as Map<String, dynamic>;
      await _repository.importFromJson(jsonData);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data imported successfully!'),
          backgroundColor: Colors.green,
        ),
      );

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Import failed: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
      // Show loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                height: 16,
                width: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 16),
              Text('Clearing all data...'),
            ],
          ),
          duration: Duration(seconds: 3),
        ),
      );

      // Clear data from repository
      await _repository.clearAllEntries();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All wellness data has been cleared'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
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
      await _settingsService.clearAll();
      await _loadSettings();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Settings reset to default'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error resetting settings: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
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
