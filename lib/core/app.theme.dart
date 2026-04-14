import 'package:flutter/material.dart';
import 'design_tokens.dart'; // your file

class AppTheme {
  // 🌞 LIGHT THEME
  static ThemeData light = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,

    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimary,
      primaryContainer: AppColors.primaryContainer,
      onPrimaryContainer: AppColors.onPrimaryFixedVariant,

      secondary: AppColors.secondary,
      onSecondary: AppColors.onSecondary,
      secondaryContainer: AppColors.secondaryContainer,
      onSecondaryContainer: AppColors.onSecondaryFixedVariant,

      tertiary: AppColors.tertiary,
      onTertiary: AppColors.onTertiary,
      tertiaryContainer: AppColors.tertiaryContainer,
      onTertiaryContainer: AppColors.onTertiaryContainer,

      error: AppColors.error,
      onError: AppColors.onError,

      surface: AppColors.surface,
      onSurface: AppColors.onSurface,
      onSurfaceVariant: AppColors.onSurfaceVariant,

      outline: AppColors.outline,
      outlineVariant: AppColors.outlineVariant,
    ),

    scaffoldBackgroundColor: AppColors.surface,

    // 📝 Typography
    textTheme: TextTheme(
      displayLarge: AppTypography.display,
      headlineLarge: AppTypography.headline,
      titleLarge: AppTypography.title,
      bodyMedium: AppTypography.body,
      labelMedium: AppTypography.label,
    ),

    // 🧱 Card Theme
    cardTheme: CardThemeData(
      color: AppColors.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: AppShapes.lgRadius,
      ),
      elevation: 0,
    ),

    // 🔝 AppBar
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.surface,
      foregroundColor: AppColors.onSurface,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: AppTypography.title.copyWith(
        fontSize: 18,
        color: AppColors.onSurface,
      ),
    ),

    // 🔘 Buttons
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: AppShapes.fullRadius,
        ),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        textStyle: AppTypography.label,
      ),
    ),
  );

  // 🌙 DARK THEME
  static ThemeData dark = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,

    colorScheme: const ColorScheme(
      brightness: Brightness.dark,
      primary: AppColors.primaryFixedDim,
      onPrimary: AppColors.onPrimaryFixed,

      primaryContainer: AppColors.primary,
      onPrimaryContainer: AppColors.primaryFixed,

      secondary: AppColors.secondaryFixedDim,
      onSecondary: AppColors.onSecondaryFixed,

      secondaryContainer: AppColors.secondary,
      onSecondaryContainer: AppColors.secondaryFixed,

      tertiary: AppColors.tertiaryFixedDim,
      onTertiary: AppColors.onTertiaryFixed,

      tertiaryContainer: AppColors.tertiary,
      onTertiaryContainer: AppColors.tertiaryFixed,

      error: AppColors.error,
      onError: AppColors.onError,

      surface: Color(0xFF121212),
      onSurface: Colors.white,
      onSurfaceVariant: AppColors.outlineVariant,

      outline: AppColors.outlineVariant,
      outlineVariant: AppColors.outline,
    ),

    scaffoldBackgroundColor: const Color(0xFF121212),

    // 📝 Typography (same but color auto adjust hota hai)
    textTheme: TextTheme(
      displayLarge: AppTypography.display,
      headlineLarge: AppTypography.headline,
      titleLarge: AppTypography.title,
      bodyMedium: AppTypography.body,
      labelMedium: AppTypography.label,
    ),

    // 🧱 Card
    cardTheme: CardThemeData(
      color: const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(
        borderRadius: AppShapes.lgRadius,
      ),
      elevation: 0,
    ),

    // 🔝 AppBar
    appBarTheme: AppBarTheme(
      backgroundColor: const Color(0xFF121212),
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: AppTypography.title.copyWith(
        fontSize: 18,
        color: Colors.white,
      ),
    ),

    // 🔘 Buttons
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryFixedDim,
        foregroundColor: AppColors.onPrimaryFixed,
        shape: RoundedRectangleBorder(
          borderRadius: AppShapes.fullRadius,
        ),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        textStyle: AppTypography.label,
      ),
    ),
  );
}