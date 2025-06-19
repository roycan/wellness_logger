import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../screens/add_entry_screen.dart';

/// Floating action button for quick entry creation.
/// 
/// This widget provides a quick way to add new wellness entries
/// with a submenu for different entry types.
class QuickAddFAB extends StatefulWidget {
  const QuickAddFAB({super.key});

  @override
  State<QuickAddFAB> createState() => _QuickAddFABState();
}

class _QuickAddFABState extends State<QuickAddFAB>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AppConstants.shortAnimation,
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    if (_isExpanded) {
      _animationController.reverse();
    } else {
      _animationController.forward();
    }
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  void _onEntryTypeSelected(String entryType) {
    _toggleExpanded();
    
    // Determine which tab index to open based on entry type
    int initialTabIndex = 0; // Default to SVT
    switch (entryType) {
      case 'SVT Episode':
        initialTabIndex = 0;
        break;
      case 'Exercise':
        initialTabIndex = 1;
        break;
      case 'Medication':
        initialTabIndex = 2;
        break;
    }
    
    // Navigate to the add entry screen with the correct tab
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddEntryScreen(initialTabIndex: initialTabIndex),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Expanded FAB options
        AnimatedBuilder(
          animation: _expandAnimation,
          builder: (context, child) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // SVT Episode FAB
                if (_expandAnimation.value > 0.0)
                  Transform.scale(
                    scale: _expandAnimation.value,
                    child: Opacity(
                      opacity: _expandAnimation.value,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: AppConstants.smallPadding),
                        child: _buildOptionFAB(
                          label: 'SVT Episode',
                          icon: Icons.favorite,
                          color: colorScheme.error,
                          onPressed: () => _onEntryTypeSelected('SVT Episode'),
                        ),
                      ),
                    ),
                  ),
                
                // Exercise FAB
                if (_expandAnimation.value > 0.3)
                  Transform.scale(
                    scale: (_expandAnimation.value - 0.3) / 0.7,
                    child: Opacity(
                      opacity: (_expandAnimation.value - 0.3) / 0.7,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: AppConstants.smallPadding),
                        child: _buildOptionFAB(
                          label: 'Exercise',
                          icon: Icons.fitness_center,
                          color: Colors.green,
                          onPressed: () => _onEntryTypeSelected('Exercise'),
                        ),
                      ),
                    ),
                  ),
                
                // Medication FAB
                if (_expandAnimation.value > 0.6)
                  Transform.scale(
                    scale: (_expandAnimation.value - 0.6) / 0.4,
                    child: Opacity(
                      opacity: (_expandAnimation.value - 0.6) / 0.4,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: AppConstants.smallPadding),
                        child: _buildOptionFAB(
                          label: 'Medication',
                          icon: Icons.medication,
                          color: Colors.blue,
                          onPressed: () => _onEntryTypeSelected('Medication'),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
        
        // Main FAB
        FloatingActionButton(
          onPressed: _toggleExpanded,
          child: AnimatedRotation(
            turns: _isExpanded ? 0.125 : 0.0, // 45 degrees
            duration: AppConstants.shortAnimation,
            child: Icon(_isExpanded ? Icons.close : Icons.add),
          ),
        ),
      ],
    );
  }

  Widget _buildOptionFAB({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Label
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.defaultPadding,
            vertical: AppConstants.smallPadding,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        
        const SizedBox(width: AppConstants.smallPadding),
        
        // Mini FAB
        FloatingActionButton.small(
          onPressed: onPressed,
          backgroundColor: color,
          foregroundColor: Colors.white,
          child: Icon(icon),
        ),
      ],
    );
  }
}
