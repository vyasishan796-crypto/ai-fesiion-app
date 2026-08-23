import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';

class FloatingGlassBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTabChanged;
  final List<FloatingNavItem> items;

  const FloatingGlassBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTabChanged,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        height: 44 + bottomPadding,
        padding: EdgeInsets.only(bottom: bottomPadding),
        color: AppColors.surfaceBlack,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(items.length, (index) {
            final isActive = currentIndex == index;
            return GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                onTabChanged(index);
              },
              behavior: HitTestBehavior.opaque,
              child: SizedBox(
                width: 64,
                child: Center(
                  child: Icon(
                    isActive ? items[index].activeIcon : items[index].outlinedIcon,
                    size: 20,
                    color: isActive
                        ? AppColors.bodyOnDark
                        : AppColors.inkMuted48,
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class FloatingNavItem {
  final String label;
  final IconData outlinedIcon;
  final IconData activeIcon;

  const FloatingNavItem({
    required this.label,
    required this.outlinedIcon,
    required this.activeIcon,
  });
}
