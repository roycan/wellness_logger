import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../domain/entities/wellness_entry.dart';
import '../../domain/repositories/wellness_repository_simple.dart';
import '../../core/utils/service_locator_simple.dart';
import '../../core/constants/app_constants.dart';

/// Analytics screen for viewing wellness insights and statistics.
/// 
/// This screen provides various charts and analytics including:
/// - Entry frequency over time
/// - Patterns and trends
/// - Health insights
/// - Export capabilities
class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  List<WellnessEntry> _entries = [];
  bool _isLoading = true;
  String _selectedTimeRange = '30 days';
  final List<String> _timeRanges = ['7 days', '30 days', '90 days', '1 year'];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final repository = serviceLocator<WellnessRepositorySimple>();
      final entries = await repository.getAllEntries();
      
      setState(() {
        _entries = _filterEntriesByTimeRange(entries);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  List<WellnessEntry> _filterEntriesByTimeRange(List<WellnessEntry> entries) {
    final now = DateTime.now();
    int days;
    
    switch (_selectedTimeRange) {
      case '7 days':
        days = 7;
        break;
      case '30 days':
        days = 30;
        break;
      case '90 days':
        days = 90;
        break;
      case '1 year':
        days = 365;
        break;
      default:
        days = 30;
    }

    final cutoffDate = now.subtract(Duration(days: days));
    return entries.where((entry) => entry.timestamp.isAfter(cutoffDate)).toList();
  }

  Map<String, int> _getEntryCounts() {
    final counts = <String, int>{};
    for (final entry in _entries) {
      counts[entry.type] = (counts[entry.type] ?? 0) + 1;
    }
    return counts;
  }

  Map<String, List<WellnessEntry>> _getEntriesByWeek() {
    final now = DateTime.now();
    final entriesByWeek = <String, List<WellnessEntry>>{};
    
    for (int i = 0; i < 4; i++) {
      final weekStart = now.subtract(Duration(days: 7 * (i + 1)));
      final weekEnd = now.subtract(Duration(days: 7 * i));
      final weekKey = 'Week ${4 - i}';
      
      entriesByWeek[weekKey] = _entries.where((entry) {
        return entry.timestamp.isAfter(weekStart) && entry.timestamp.isBefore(weekEnd);
      }).toList();
    }
    
    return entriesByWeek;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildAnalyticsContent(),
    );
  }

  Widget _buildAnalyticsContent() {
    if (_entries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.analytics_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No data to analyze',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start tracking your wellness entries to see analytics',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTimeRangeSelector(),
          const SizedBox(height: 24),
          _buildSummaryCards(),
          const SizedBox(height: 24),
          _buildEntryTypeChart(),
          const SizedBox(height: 24),
          _buildWeeklyTrendsChart(),
          const SizedBox(height: 24),
          _buildInsights(),
        ],
      ),
    );
  }

  Widget _buildTimeRangeSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Time Range',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _timeRanges.map((range) {
                final isSelected = range == _selectedTimeRange;
                return FilterChip(
                  label: Text(range),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedTimeRange = range;
                        _loadData();
                      });
                    }
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards() {
    final counts = _getEntryCounts();
    final totalEntries = _entries.length;
    final svtCount = counts[AppConstants.entryTypeSvt] ?? 0;
    final exerciseCount = counts[AppConstants.entryTypeExercise] ?? 0;
    final medicationCount = counts[AppConstants.entryTypeMedication] ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Summary',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                'Total Entries',
                totalEntries.toString(),
                Icons.assessment,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildSummaryCard(
                'SVT Episodes',
                svtCount.toString(),
                Icons.favorite,
                Colors.red,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                'Exercise Sessions',
                exerciseCount.toString(),
                Icons.fitness_center,
                Colors.green,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildSummaryCard(
                'Medications',
                medicationCount.toString(),
                Icons.medication,
                Colors.orange,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.bodyMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEntryTypeChart() {
    final counts = _getEntryCounts();
    if (counts.isEmpty) return const SizedBox.shrink();

    final pieChartSections = counts.entries.map((entry) {
      Color color;
      switch (entry.key) {
        case AppConstants.entryTypeSvt:
          color = Colors.red;
          break;
        case AppConstants.entryTypeExercise:
          color = Colors.green;
          break;
        case AppConstants.entryTypeMedication:
          color = Colors.blue;
          break;
        default:
          color = Colors.grey;
      }

      return PieChartSectionData(
        color: color,
        value: entry.value.toDouble(),
        title: '${entry.value}',
        radius: 50,
        titleStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Entry Types Distribution',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: pieChartSections,
                  centerSpaceRadius: 40,
                  sectionsSpace: 2,
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildLegend(counts),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend(Map<String, int> counts) {
    return Column(
      children: counts.entries.map((entry) {
        Color color;
        String label;
        switch (entry.key) {
          case AppConstants.entryTypeSvt:
            color = Colors.red;
            label = 'SVT Episodes';
            break;
          case AppConstants.entryTypeExercise:
            color = Colors.green;
            label = 'Exercise';
            break;
          case AppConstants.entryTypeMedication:
            color = Colors.blue;
            label = 'Medication';
            break;
          default:
            color = Colors.grey;
            label = entry.key;
        }

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2.0),
          child: Row(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text('$label (${entry.value})'),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildWeeklyTrendsChart() {
    final entriesByWeek = _getEntriesByWeek();
    if (entriesByWeek.isEmpty) return const SizedBox.shrink();

    final barGroups = entriesByWeek.entries.map((entry) {
      final index = entriesByWeek.keys.toList().indexOf(entry.key);
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: entry.value.length.toDouble(),
            color: Colors.blueAccent,
            width: 16,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    }).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Weekly Trends',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  barGroups: barGroups,
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: true),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final weeks = entriesByWeek.keys.toList();
                          if (value.toInt() >= 0 && value.toInt() < weeks.length) {
                            return Text(
                              weeks[value.toInt()],
                              style: const TextStyle(fontSize: 12),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: const FlGridData(show: true),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsights() {
    final counts = _getEntryCounts();
    final totalEntries = _entries.length;
    
    List<String> insights = [];
    
    if (totalEntries > 0) {
      insights.add('You have tracked $totalEntries entries in the selected time period.');
      
      final mostCommonType = counts.entries.isNotEmpty
          ? counts.entries.reduce((a, b) => a.value > b.value ? a : b)
          : null;
      
      if (mostCommonType != null) {
        String typeName;
        switch (mostCommonType.key) {
          case AppConstants.entryTypeSvt:
            typeName = 'SVT episodes';
            break;
          case AppConstants.entryTypeExercise:
            typeName = 'exercise sessions';
            break;
          case AppConstants.entryTypeMedication:
            typeName = 'medication entries';
            break;
          default:
            typeName = 'entries';
        }
        insights.add('Your most frequent activity is $typeName with ${mostCommonType.value} entries.');
      }
      
      if (counts[AppConstants.entryTypeExercise] != null && counts[AppConstants.entryTypeExercise]! > 0) {
        insights.add('Great job staying active with ${counts[AppConstants.entryTypeExercise]} exercise sessions!');
      }
    }

    if (insights.isEmpty) {
      insights.add('Start tracking your wellness activities to see personalized insights here.');
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Insights',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            ...insights.map((insight) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.lightbulb_outline, size: 16, color: Colors.amber),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      insight,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}
