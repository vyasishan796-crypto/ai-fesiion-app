import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';

class PremiumBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTabChanged;
  final List<PremiumNavItem> items;

  const PremiumBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTabChanged,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Positioned(
      left: 12,
      right: 12,
      bottom: bottomPadding + 8,
      child: Container(
        height: 72,
        decoration: BoxDecoration(
          color: AppColors.navDark,
          borderRadius: BorderRadius.circular(9999),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 24,
              spreadRadius: 0,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: AppColors.violet.withOpacity(0.06),
              blurRadius: 32,
              spreadRadius: -4,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(9999),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(items.length, (index) {
              final isActive = currentIndex == index;
              return _NavItemWidget(
                item: items[index],
                isActive: isActive,
                onTap: () {
                  HapticFeedback.selectionClick();
                  onTabChanged(index);
                },
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItemWidget extends StatelessWidget {
  final PremiumNavItem item;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItemWidget({
    required this.item,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              width: isActive ? 44 : 36,
              height: isActive ? 30 : 28,
              decoration: isActive
                  ? BoxDecoration(
                      color: AppColors.violet.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    )
                  : null,
              child: Center(
                child: AnimatedScale(
                  scale: isActive ? 1.1 : 1.0,
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutCubic,
                  child: Icon(
                    isActive ? item.activeIcon : item.outlinedIcon,
                    size: 22,
                    color: isActive
                        ? AppColors.violet
                        : AppColors.navUnselected,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive
                    ? AppColors.violet
                    : AppColors.navUnselected,
                letterSpacing: 0.1,
              ),
              child: Text(item.label),
            ),
          ],
        ),
      ),
    );
  }
}

class PremiumNavItem {
  final String label;
  final IconData outlinedIcon;
  final IconData activeIcon;

  const PremiumNavItem({
    required this.label,
    required this.outlinedIcon,
    required this.activeIcon,
  });
}
