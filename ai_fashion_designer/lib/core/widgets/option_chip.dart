import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';

class OptionChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;
  final bool isDark;

  const OptionChip({
    super.key,
    required this.label,
    this.isSelected = false,
    this.onTap,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isDark
              ? (isSelected ? AppColors.primary : AppColors.surfaceTile1)
              : (isSelected ? AppColors.primary : AppColors.canvas),
          borderRadius: AppRadius.pill,
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : (isDark ? AppColors.surfaceTile2 : AppColors.hairline),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected
                ? Colors.white
                : (isDark ? AppColors.bodyOnDark : AppColors.ink),
            letterSpacing: -0.224,
          ),
        ),
      ),
    );
  }
}
