import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../widgets/custom_bottom_navigation_bar.dart';
import 'home_screen.dart';
import 'calendar_screen.dart';
import 'analytics_screen.dart';
import 'settings_screen.dart';

/// Main navigation screen with bottom navigation bar.
/// 
/// This screen manages the primary navigation flow of the app and provides
/// access to the four main sections: Home, Calendar, Analytics, and Settings.
/// 
/// Features:
/// - Bottom navigation with Material Design 3 styling
/// - State preservation across navigation
/// - Smooth page transitions
/// - Accessibility support
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  late PageController _pageController;

  // Define the main screens
  final List<Widget> _screens = const [
    HomeScreen(),
    CalendarScreen(),
    AnalyticsScreen(),
    SettingsScreen(),
  ];

  // Navigation items configuration
  final List<NavigationItem> _navigationItems = const [
    NavigationItem(
      icon: Icons.home_outlined,
      selectedIcon: Icons.home,
      label: 'Home',
    ),
    NavigationItem(
      icon: Icons.calendar_today_outlined,
      selectedIcon: Icons.calendar_today,
      label: 'Calendar',
    ),
    NavigationItem(
      icon: Icons.analytics_outlined,
      selectedIcon: Icons.analytics,
      label: 'Analytics',
    ),
    NavigationItem(
      icon: Icons.settings_outlined,
      selectedIcon: Icons.settings,
      label: 'Settings',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// Handles navigation tab selection
  void _onItemTapped(int index) {
    if (_currentIndex != index) {
      setState(() {
        _currentIndex = index;
      });
      
      // Animate to the selected page
      _pageController.animateToPage(
        index,
        duration: AppConstants.shortAnimation,
        curve: Curves.easeInOut,
      );
    }
  }

  /// Handles page change from swipe gestures
  void _onPageChanged(int index) {
    if (_currentIndex != index) {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: _screens,
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex,
        items: _navigationItems,
        onTap: _onItemTapped,
      ),
    );
  }
}

/// Data class for navigation items
class NavigationItem {
  const NavigationItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
}
