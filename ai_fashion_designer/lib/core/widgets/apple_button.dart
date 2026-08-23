import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';

class AppleButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppleButtonType type;
  final bool isSmall;
  final IconData? icon;

  const AppleButton({
    super.key,
    required this.label,
    this.onPressed,
    this.type = AppleButtonType.primary,
    this.isSmall = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      onTapDown: (_) {},
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        padding: EdgeInsets.symmetric(
          horizontal: isSmall ? 15 : 22,
          vertical: isSmall ? 8 : 11,
        ),
        decoration: BoxDecoration(
          color: _bgColor,
          borderRadius: _borderRadius,
          border: _border,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: _textColor),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: isSmall ? 14 : 17,
                fontWeight: _fontWeight,
                color: _textColor,
                letterSpacing: isSmall ? -0.224 : -0.374,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color get _bgColor {
    switch (type) {
      case AppleButtonType.primary:
        return AppColors.primary;
      case AppleButtonType.secondary:
        return Colors.transparent;
      case AppleButtonType.darkUtility:
        return AppColors.ink;
      case AppleButtonType.pearl:
        return AppColors.surfacePearl;
      case AppleButtonType.iconCircular:
        return AppColors.surfaceChipTranslucent;
    }
  }

  Color get _textColor {
    switch (type) {
      case AppleButtonType.primary:
        return Colors.white;
      case AppleButtonType.secondary:
        return AppColors.primary;
      case AppleButtonType.darkUtility:
        return AppColors.bodyOnDark;
      case AppleButtonType.pearl:
        return AppColors.inkMuted80;
      case AppleButtonType.iconCircular:
        return AppColors.ink;
    }
  }

  FontWeight get _fontWeight {
    switch (type) {
      case AppleButtonType.primary:
        return FontWeight.w400;
      case AppleButtonType.secondary:
        return FontWeight.w400;
      case AppleButtonType.darkUtility:
        return FontWeight.w400;
      case AppleButtonType.pearl:
        return FontWeight.w400;
      case AppleButtonType.iconCircular:
        return FontWeight.w400;
    }
  }

  BorderRadius get _borderRadius {
    switch (type) {
      case AppleButtonType.darkUtility:
        return AppRadius.sm;
      case AppleButtonType.pearl:
        return AppRadius.md;
      case AppleButtonType.iconCircular:
        return AppRadius.full;
      default:
        return AppRadius.pill;
    }
  }

  Border? get _border {
    if (type == AppleButtonType.secondary) {
      return Border.all(color: AppColors.primary);
    }
    if (type == AppleButtonType.pearl) {
      return Border.all(color: AppColors.dividerSoft, width: 3);
    }
    return null;
  }
}

enum AppleButtonType {
  primary,
  secondary,
  darkUtility,
  pearl,
  iconCircular,
}
