import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../domain/entities/wellness_entry.dart';
import '../../domain/repositories/wellness_repository_simple.dart';
import '../../core/utils/service_locator_simple.dart';
import '../../core/constants/app_constants.dart';
import '../widgets/wellness_entry_card.dart';
import 'add_entry_screen.dart';

/// Calendar screen for viewing wellness entries by date.
/// 
/// This screen provides a calendar view where users can:
/// - Navigate through months and years
/// - See entries marked on specific dates
/// - Tap dates to view entries for that day
/// - Get a visual overview of their tracking consistency
class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<WellnessEntry> _allEntries = [];
  List<WellnessEntry> _selectedDayEntries = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final repository = serviceLocator<WellnessRepositorySimple>();
      final entries = await repository.getAllEntries();
      
      setState(() {
        _allEntries = entries;
        _updateSelectedDayEntries();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading entries: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _updateSelectedDayEntries() {
    if (_selectedDay == null) {
      _selectedDayEntries = [];
      return;
    }

    _selectedDayEntries = _allEntries.where((entry) {
      return isSameDay(entry.timestamp, _selectedDay!);
    }).toList();

    // Sort by timestamp, newest first
    _selectedDayEntries.sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  List<WellnessEntry> _getEventsForDay(DateTime day) {
    return _allEntries.where((entry) {
      return isSameDay(entry.timestamp, day);
    }).toList();
  }

  Color _getEventColor(String entryType) {
    switch (entryType) {
      case AppConstants.entryTypeSvt:
        return Colors.red.withOpacity(0.7);
      case AppConstants.entryTypeExercise:
        return Colors.green.withOpacity(0.7);
      case AppConstants.entryTypeMedication:
        return Colors.blue.withOpacity(0.7);
      default:
        return Colors.grey.withOpacity(0.7);
    }
  }

  Widget _buildEventMarker(List<WellnessEntry> events) {
    if (events.isEmpty) return const SizedBox.shrink();

    return Positioned(
      bottom: 1,
      right: 1,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: events.take(3).map((entry) {
          return Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.symmetric(horizontal: 0.5),
            decoration: BoxDecoration(
              color: _getEventColor(entry.type),
              shape: BoxShape.circle,
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadEntries,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          if (_isLoading)
            const LinearProgressIndicator(),
          Expanded(
            child: Column(
              children: [
                // Calendar Widget
                TableCalendar<WellnessEntry>(
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  eventLoader: _getEventsForDay,
                  calendarFormat: CalendarFormat.month,
                  startingDayOfWeek: StartingDayOfWeek.monday,
                  calendarStyle: const CalendarStyle(
                    outsideDaysVisible: false,
                    markerDecoration: BoxDecoration(
                      color: Colors.transparent,
                    ),
                  ),
                  headerStyle: const HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                  ),
                  calendarBuilders: CalendarBuilders<WellnessEntry>(
                    markerBuilder: (context, day, events) {
                      return _buildEventMarker(events);
                    },
                  ),
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                      _updateSelectedDayEntries();
                    });
                  },
                  onPageChanged: (focusedDay) {
                    _focusedDay = focusedDay;
                  },
                ),
                const Divider(),
                // Selected Day Entries
                Expanded(
                  child: _buildSelectedDayEntries(),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const AddEntryScreen(), // Uses default tab (SVT)
            ),
          );
          if (result == true) {
            _loadEntries(); // Refresh entries after adding new one
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSelectedDayEntries() {
    if (_selectedDay == null) {
      return const Center(
        child: Text('Select a day to view entries'),
      );
    }

    final dateText = '${_selectedDay!.day}/${_selectedDay!.month}/${_selectedDay!.year}';

    if (_selectedDayEntries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No entries for $dateText',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the + button to add an entry',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Entries for $dateText (${_selectedDayEntries.length})',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            itemCount: _selectedDayEntries.length,
            itemBuilder: (context, index) {
              final entry = _selectedDayEntries[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: WellnessEntryCard(
                  entry: entry,
                  onTap: () async {
                    // Handle entry tap - could navigate to edit screen
                    final result = await Navigator.of(context).pushNamed(
                      '/edit-entry',
                      arguments: entry,
                    );
                    if (result == true) {
                      _loadEntries(); // Refresh entries after editing
                    }
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
