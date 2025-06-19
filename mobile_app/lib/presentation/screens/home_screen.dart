import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../domain/repositories/wellness_repository_simple.dart';
import '../../core/utils/service_locator_simple.dart';
import '../../domain/entities/wellness_entry.dart';
import '../widgets/wellness_entry_card.dart';
import '../widgets/quick_add_fab.dart';
import '../widgets/empty_state_widget.dart';
import 'edit_entry_screen.dart';

/// Home screen displaying recent wellness entries and quick actions.
/// 
/// This screen serves as the main dashboard where users can:
/// - View their most recent wellness entries
/// - Quickly add new entries via FAB
/// - See overview statistics
/// - Access primary app features
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final WellnessRepositorySimple _repository = serviceLocator<WellnessRepositorySimple>();
  List<WellnessEntry> _recentEntries = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadRecentEntries();
  }

  /// Loads the most recent wellness entries
  Future<void> _loadRecentEntries() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final entries = await _repository.getAllEntries();
      
      // Sort by date (most recent first) and take the first 10
      final sortedEntries = List<WellnessEntry>.from(entries)
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
      
      setState(() {
        _recentEntries = sortedEntries.take(10).toList();
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _errorMessage = error.toString();
        _isLoading = false;
      });
    }
  }

  /// Handles refresh action
  Future<void> _onRefresh() async {
    await _loadRecentEntries();
  }

  /// Navigates to edit entry screen
  Future<void> _editEntry(WellnessEntry entry) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditEntryScreen(entry: entry),
      ),
    );
    
    // If entry was updated, refresh the list
    if (result == true) {
      _loadRecentEntries();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wellness Logger'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadRecentEntries,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: const QuickAddFAB(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    if (_recentEntries.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.favorite_outline,
        title: 'Welcome to Wellness Logger',
        message: 'Start tracking your health journey by adding your first entry.',
        actionText: 'Add Entry',
      );
    }

    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: CustomScrollView(
        slivers: [
          // Overview Statistics
          SliverToBoxAdapter(
            child: _buildOverviewSection(),
          ),
          
          // Recent Entries Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: Text(
                'Recent Entries',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ),
          
          // Recent Entries List
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final entry = _recentEntries[index];
                return Padding(
                  padding: EdgeInsets.only(
                    left: AppConstants.defaultPadding,
                    right: AppConstants.defaultPadding,
                    bottom: index == _recentEntries.length - 1 
                        ? AppConstants.largePadding * 2 // Extra space for FAB
                        : AppConstants.smallPadding,
                  ),
                  child: WellnessEntryCard(
                    entry: entry,
                    onTap: () => _editEntry(entry),
                  ),
                );
              },
              childCount: _recentEntries.length,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewSection() {
    final totalEntries = _recentEntries.length;
    final todayEntries = _recentEntries.where((entry) {
      final today = DateTime.now();
      final entryDate = entry.timestamp;
      return entryDate.year == today.year &&
             entryDate.month == today.month &&
             entryDate.day == today.day;
    }).length;

    return Container(
      margin: const EdgeInsets.all(AppConstants.defaultPadding),
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Today',
              todayEntries.toString(),
              Icons.today,
            ),
          ),
          const SizedBox(width: AppConstants.defaultPadding),
          Expanded(
            child: _buildStatCard(
              'Total',
              totalEntries.toString(),
              Icons.bar_chart,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          size: 32,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: AppConstants.smallPadding),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          title,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            Text(
              'Error Loading Data',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppConstants.smallPadding),
            Text(
              _errorMessage ?? 'Unknown error occurred',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            FilledButton(
              onPressed: _loadRecentEntries,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
