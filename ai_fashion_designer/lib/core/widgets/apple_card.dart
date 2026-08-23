import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';

class AppleCard extends StatelessWidget {
  final Widget child;
  final AppleCardType type;
  final EdgeInsets? padding;
  final VoidCallback? onTap;

  const AppleCard({
    super.key,
    required this.child,
    this.type = AppleCardType.light,
    this.padding,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: padding ?? AppSpacing.paddingLg,
        decoration: BoxDecoration(
          color: _bgColor,
          borderRadius: _borderRadius,
          border: _border,
        ),
        child: DefaultTextStyle(
          style: TextStyle(color: _textColor),
          child: child,
        ),
      ),
    );
  }

  Color get _bgColor {
    switch (type) {
      case AppleCardType.light:
        return AppColors.canvas;
      case AppleCardType.parchment:
        return AppColors.canvasParchment;
      case AppleCardType.dark:
        return AppColors.surfaceTile1;
      case AppleCardType.dark2:
        return AppColors.surfaceTile2;
      case AppleCardType.dark3:
        return AppColors.surfaceTile3;
      case AppleCardType.utility:
        return AppColors.canvas;
    }
  }

  Color get _textColor {
    switch (type) {
      case AppleCardType.light:
      case AppleCardType.parchment:
      case AppleCardType.utility:
        return AppColors.ink;
      case AppleCardType.dark:
      case AppleCardType.dark2:
      case AppleCardType.dark3:
        return AppColors.bodyOnDark;
    }
  }

  BorderRadius get _borderRadius {
    switch (type) {
      case AppleCardType.utility:
        return AppRadius.lg;
      default:
        return AppRadius.none;
    }
  }

  Border? get _border {
    if (type == AppleCardType.utility) {
      return Border.all(color: AppColors.hairline);
    }
    return null;
  }
}

enum AppleCardType {
  light,
  parchment,
  dark,
  dark2,
  dark3,
  utility,
}
