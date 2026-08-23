import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTypography {
  AppTypography._();

  // Display
  static TextStyle get heroDisplay => GoogleFonts.inter(
        fontSize: 56,
        fontWeight: FontWeight.w600,
        height: 1.07,
        letterSpacing: -0.28,
        color: AppColors.ink,
      );

  static TextStyle get displayLg => GoogleFonts.inter(
        fontSize: 40,
        fontWeight: FontWeight.w600,
        height: 1.10,
        letterSpacing: 0,
        color: AppColors.ink,
      );

  static TextStyle get displayMd => GoogleFonts.inter(
        fontSize: 34,
        fontWeight: FontWeight.w600,
        height: 1.47,
        letterSpacing: -0.374,
        color: AppColors.ink,
      );

  // Lead
  static TextStyle get lead => GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.w400,
        height: 1.14,
        letterSpacing: 0.196,
        color: AppColors.ink,
      );

  static TextStyle get leadAiry => GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w300,
        height: 1.5,
        letterSpacing: 0,
        color: AppColors.ink,
      );

  // Tagline
  static TextStyle get tagline => GoogleFonts.inter(
        fontSize: 21,
        fontWeight: FontWeight.w600,
        height: 1.19,
        letterSpacing: 0.231,
        color: AppColors.ink,
      );

  // Body
  static TextStyle get bodyStrong => GoogleFonts.inter(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        height: 1.24,
        letterSpacing: -0.374,
        color: AppColors.ink,
      );

  static TextStyle get body => GoogleFonts.inter(
        fontSize: 17,
        fontWeight: FontWeight.w400,
        height: 1.47,
        letterSpacing: -0.374,
        color: AppColors.ink,
      );

  static TextStyle get denseLink => GoogleFonts.inter(
        fontSize: 17,
        fontWeight: FontWeight.w400,
        height: 2.41,
        letterSpacing: 0,
        color: AppColors.ink,
      );

  // Caption
  static TextStyle get caption => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.43,
        letterSpacing: -0.224,
        color: AppColors.ink,
      );

  static TextStyle get captionStrong => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.29,
        letterSpacing: -0.224,
        color: AppColors.ink,
      );

  // Button
  static TextStyle get buttonLarge => GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w300,
        height: 1.0,
        letterSpacing: 0,
        color: Colors.white,
      );

  static TextStyle get buttonUtility => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.29,
        letterSpacing: -0.224,
        color: AppColors.ink,
      );

  // Fine Print
  static TextStyle get finePrint => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.0,
        letterSpacing: -0.12,
        color: AppColors.inkMuted48,
      );

  static TextStyle get microLegal => GoogleFonts.inter(
        fontSize: 10,
        fontWeight: FontWeight.w400,
        height: 1.3,
        letterSpacing: -0.08,
        color: AppColors.inkMuted48,
      );

  // Nav
  static TextStyle get navLink => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.0,
        letterSpacing: -0.12,
        color: AppColors.bodyOnDark,
      );

  // Dark variants
  static TextStyle get heroDisplayDark => heroDisplay.copyWith(color: AppColors.bodyOnDark);
  static TextStyle get displayLgDark => displayLg.copyWith(color: AppColors.bodyOnDark);
  static TextStyle get displayMdDark => displayMd.copyWith(color: AppColors.bodyOnDark);
  static TextStyle get leadDark => lead.copyWith(color: AppColors.bodyOnDark);
  static TextStyle get taglineDark => tagline.copyWith(color: AppColors.bodyOnDark);
  static TextStyle get bodyDark => body.copyWith(color: AppColors.bodyOnDark);
  static TextStyle get bodyStrongDark => bodyStrong.copyWith(color: AppColors.bodyOnDark);
  static TextStyle get captionDark => caption.copyWith(color: AppColors.bodyOnDark);
}
