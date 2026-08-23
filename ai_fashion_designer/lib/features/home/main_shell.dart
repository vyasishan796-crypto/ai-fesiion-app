import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/premium_bottom_nav.dart';
import 'home_screen.dart';
import '../marketplace/marketplace_screen.dart';
import '../profile/profile_screen.dart';
import '../tailors/tailors_screen.dart';
import '../my_orders/my_orders_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  static const _navItems = [
    PremiumNavItem(
      label: 'Home',
      outlinedIcon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
    ),
    PremiumNavItem(
      label: 'Tailors',
      outlinedIcon: Icons.content_cut_outlined,
      activeIcon: Icons.content_cut_rounded,
    ),
    PremiumNavItem(
      label: 'Market',
      outlinedIcon: Icons.shopping_bag_outlined,
      activeIcon: Icons.shopping_bag_rounded,
    ),
    PremiumNavItem(
      label: 'Orders',
      outlinedIcon: Icons.receipt_long_outlined,
      activeIcon: Icons.receipt_long_rounded,
    ),
    PremiumNavItem(
      label: 'Profile',
      outlinedIcon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
    ),
  ];

  final _screens = const [
    HomeScreen(),
    TailorsScreen(),
    MarketplaceScreen(),
    MyOrdersScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Stack(
        children: [
          IndexedStack(
            index: _currentIndex,
            children: _screens,
          ),
          PremiumBottomNav(
            currentIndex: _currentIndex,
            onTabChanged: (index) => setState(() => _currentIndex = index),
            items: _navItems,
          ),
        ],
      ),
    );
  }
}
