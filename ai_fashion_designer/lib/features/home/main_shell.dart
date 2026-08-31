import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/premium_bottom_nav.dart';

class MainShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Stack(
        children: [
          navigationShell,
          PremiumBottomNav(
            currentIndex: navigationShell.currentIndex,
            onTabChanged: (index) {
              navigationShell.goBranch(
                index,
                initialLocation: index == navigationShell.currentIndex,
              );
            },
            items: const [
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
            ],
          ),
        ],
      ),
    );
  }
}
