import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Brand & Accent — Nike style
  static const Color primary = Color(0xFF1D1D1F);
  static const Color primaryFocus = Color(0xFF000000);
  static const Color primaryOnDark = Color(0xFFFFFFFF);

  // Nike accent
  static const Color nikeRed = Color(0xFFFA5400);
  static const Color nikeOrange = Color(0xFFFF6B35);

  // Ink & Text
  static const Color ink = Color(0xFF1D1D1F);
  static const Color body = Color(0xFF1D1D1F);
  static const Color bodyOnDark = Color(0xFFFFFFFF);
  static const Color bodyMuted = Color(0xFFCCCCCC);
  static const Color inkMuted80 = Color(0xFF333333);
  static const Color inkMuted48 = Color(0xFF8E8E93);

  // Canvas & Surfaces
  static const Color canvas = Color(0xFFFFFFFF);
  static const Color canvasParchment = Color(0xFFF5F5F7);
  static const Color surfacePearl = Color(0xFFFAFAFC);
  static const Color surfaceTile1 = Color(0xFF272729);
  static const Color surfaceTile2 = Color(0xFF2A2A2C);
  static const Color surfaceTile3 = Color(0xFF252527);
  static const Color surfaceBlack = Color(0xFF000000);
  static const Color surfaceChipTranslucent = Color(0xFFD2D2D7);

  // Borders & Hairlines
  static const Color dividerSoft = Color(0xFFF0F0F0);
  static const Color hairline = Color(0xFFE0E0E0);

  // Semantic
  static const Color error = Color(0xFFEF4444);
  static const Color success = Color(0xFF34C759);
  static const Color warning = Color(0xFFF59E0B);

  // Nav bar colors
  static const Color violet = Color(0xFF1D1D1F);
  static const Color violetLight = Color(0xFFFFFFFF);
  static const Color navDark = Color(0xFF111114);
  static const Color navUnselected = Color(0xFF8E8E93);

  // Accent (Nike black)
  static const Color accentPurple = Color(0xFF1D1D1F);

  // Aliases
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color lightGrey = Color(0xFFF5F5F7);
  static const Color mediumGrey = Color(0xFF8E8E93);
  static const Color darkGrey = Color(0xFF1D1D1F);
  static const Color charcoal = Color(0xFF1D1D1F);
  static const Color accent = Color(0xFF1D1D1F);
  static const Color inkSecondary = Color(0xFF8E8E93);
  static const Color inkMuted = Color(0xFF8E8E93);
  static const Color border = Color(0xFFE0E0E0);
  static const Color divider = Color(0xFFE0E0E0);

  static const Color primaryLight = Color(0xFFFFFFFF);
  static const Color onDark = Color(0xFFFFFFFF);
  static const Color inkOnDarkMuted = Color(0xFFCCCCCC);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF1D1D1F), Color(0xFF000000)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF1D1D1F), Color(0xFF000000)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Quick action colors (Nike monochrome)
  static const Color scanBlue = Color(0xFF1D1D1F);
  static const Color generatePurple = Color(0xFF1D1D1F);
  static const Color chatGreen = Color(0xFF1D1D1F);
  static const Color browseAmber = Color(0xFF1D1D1F);
}
