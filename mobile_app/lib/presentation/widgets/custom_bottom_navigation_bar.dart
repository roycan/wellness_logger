import 'package:flutter/material.dart';

import '../screens/main_navigation_screen.dart';

/// Custom bottom navigation bar with Material Design 3 styling.
/// 
/// This widget provides a clean, accessible navigation experience with
/// proper theming and smooth animations between states.
class CustomBottomNavigationBar extends StatelessWidget {
  const CustomBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.items,
    required this.onTap,
  });

  final int currentIndex;
  final List<NavigationItem> items;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: onTap,
      backgroundColor: colorScheme.surface,
      surfaceTintColor: colorScheme.surfaceTint,
      destinations: items.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;

        return NavigationDestination(
          icon: Icon(item.icon),
          selectedIcon: Icon(item.selectedIcon),
          label: item.label,
          tooltip: item.label,
        );
      }).toList(),
    );
  }
}
