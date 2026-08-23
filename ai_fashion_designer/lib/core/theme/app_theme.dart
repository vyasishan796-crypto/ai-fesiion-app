import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.white,
      colorScheme: const ColorScheme.light(
        primary: AppColors.accentPurple,
        onPrimary: AppColors.white,
        secondary: AppColors.accentPurple,
        surface: AppColors.white,
        error: AppColors.error,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.charcoal,
        foregroundColor: AppColors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),
      textTheme: GoogleFonts.interTextTheme().copyWith(
        headlineLarge: GoogleFonts.inter(
          fontSize: 56,
          fontWeight: FontWeight.w800,
          height: 1.07,
          letterSpacing: -1.5,
          color: AppColors.ink,
        ),
        headlineMedium: GoogleFonts.inter(
          fontSize: 40,
          fontWeight: FontWeight.w700,
          height: 1.10,
          letterSpacing: -1.0,
          color: AppColors.ink,
        ),
        headlineSmall: GoogleFonts.inter(
          fontSize: 34,
          fontWeight: FontWeight.w700,
          height: 1.2,
          letterSpacing: -0.8,
          color: AppColors.ink,
        ),
        titleLarge: GoogleFonts.inter(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          height: 1.3,
          letterSpacing: -0.5,
          color: AppColors.ink,
        ),
        titleMedium: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          height: 1.4,
          letterSpacing: -0.3,
          color: AppColors.ink,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          height: 1.5,
          color: AppColors.ink,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          height: 1.5,
          color: AppColors.inkSecondary,
        ),
        bodySmall: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          height: 1.4,
          color: AppColors.inkMuted,
        ),
        labelLarge: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          height: 1.0,
          letterSpacing: 0,
          color: AppColors.white,
        ),
        labelSmall: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          height: 1.0,
          letterSpacing: 0.2,
          color: AppColors.inkMuted,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accentPurple,
          foregroundColor: AppColors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            height: 1.0,
          ),
        ),
      ),
      cardTheme: CardTheme(
        color: AppColors.white,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          side: BorderSide(color: AppColors.border),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightGrey,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(9999)),
          borderSide: BorderSide.none,
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(9999)),
          borderSide: BorderSide.none,
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(9999)),
          borderSide: BorderSide(color: AppColors.accentPurple, width: 2),
        ),
        hintStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.inkMuted,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: 0,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.accentPurple.withOpacity(0.08),
        labelStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: AppColors.accentPurple.withOpacity(0.2)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF111114),
      colorScheme: const ColorScheme.dark(
        primary: AppColors.accentPurple,
        onPrimary: AppColors.white,
        secondary: AppColors.accentPurple,
        surface: Color(0xFF1C1C1E),
        error: AppColors.error,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF111114),
        foregroundColor: AppColors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
      cardTheme: CardTheme(
        color: const Color(0xFF1C1C1E),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: Color(0xFF2C2C2E))),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF2C2C2E),
        border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(9999)), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(9999)), borderSide: BorderSide.none),
        focusedBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(9999)), borderSide: BorderSide(color: AppColors.accentPurple, width: 2)),
        hintStyle: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF8E8E93)),
      ),
      dividerTheme: const DividerThemeData(color: Color(0xFF2C2C2E), thickness: 1, space: 0),
    );
  }
}
