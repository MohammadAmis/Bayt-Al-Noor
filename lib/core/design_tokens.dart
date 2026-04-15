import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Brand Colors (Exact Stitch Tokens)
  static const Color primary = Color(0xFF00342B);
  static const Color primaryContainer = Color(0xFF004D40);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryFixed = Color(0xFFAFEFDD);
  static const Color primaryFixedDim = Color(0xFF94D3C1);
  static const Color onPrimaryFixed = Color(0xFF00201A);
  static const Color onPrimaryFixedVariant = Color(0xFF065043);
  static const Color onPrimaryColorContainer = Color(0xFF7EBDAC);

  static const Color secondary = Color(0xFF775A19);
  static const Color secondaryContainer = Color(0xFFFED488);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryFixed = Color(0xFFFFDEA5);
  static const Color secondaryFixedDim = Color(0xFFE9C176);
  static const Color onSecondaryFixed = Color(0xFF261900);
  static const Color onSecondaryFixedVariant = Color(0xFF5D4201);

  static const Color tertiary = Color(0xFF3E271F);
  static const Color tertiaryContainer = Color(0xFF573D34);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color onTertiaryContainer = Color(0xFFCCA89C);
  static const Color tertiaryFixed = Color(0xFFFFDBCE);
  static const Color tertiaryFixedDim = Color(0xFFE4BEB2);
  static const Color onTertiaryFixed = Color(0xFF2B160F);
  static const Color onTertiaryFixedVariant = Color(0xFF5B4137);

  // Surface Hierarchy
  static const Color surface = Color(0xFFF8F9FA);
  static const Color surfaceDim = Color(0xFFD9DADB);
  static const Color surfaceBright = Color(0xFFF8F9FA);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF3F4F5);
  static const Color surfaceContainer = Color(0xFFEDEEEF);
  static const Color surfaceContainerHigh = Color(0xFFE7E8E9);
  static const Color surfaceContainerHighest = Color(0xFFE1E3E4);
  static const Color surfaceTint = Color(0xFF29695B);
  static const Color surfaceVariant = Color(0xFFE1E3E4);

  // Neutral & Functional
  static const Color onSurface = Color(0xFF191C1D);
  static const Color onSurfaceVariant = Color(0xFF3F4945);
  static const Color outline = Color(0xFF707975);
  static const Color outlineVariant = Color(0xFFBFC9C4);
  static const Color error = Color(0xFFBA1A1A);
  static const Color onError = Color(0xFFFFFFFF);

  // Gradients
  static const RadialGradient radialHighlight = RadialGradient(
    colors: [Color(0xFFFFDEA5), Colors.transparent],
    radius: 0.8,
  );

  static const LinearGradient bentoGradient = LinearGradient(
    colors: [primary, primaryContainer],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class AppTypography {
  // Sacred (Serif) - Ideal for Arabic and elegant titles
  static TextStyle get headline => GoogleFonts.amiri(
        fontWeight: FontWeight.bold,
        color: AppColors.primary,
      );

  static TextStyle get display => GoogleFonts.amiri(
        fontWeight: FontWeight.bold,
        color: AppColors.primary,
      );

  // Modern (Sans) - Clean and highly readable
  static TextStyle get body => GoogleFonts.inter();
  static TextStyle get label => GoogleFonts.inter();
  static TextStyle get title => GoogleFonts.inter(
        fontWeight: FontWeight.w600,
      );
}

class AppShapes {
  static const double radiusDefault = 4.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 24.0;
  static const double radiusFull = 9999.0;

  static BorderRadius get defaultRadius => BorderRadius.circular(radiusDefault);
  static BorderRadius get lgRadius => BorderRadius.circular(radiusLg);
  static BorderRadius get xlRadius => BorderRadius.circular(radiusXl);
  static BorderRadius get fullRadius => BorderRadius.circular(radiusFull);
}

class AppAnimations {
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration fast = Duration(milliseconds: 150);
}
