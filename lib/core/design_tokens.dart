import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // 🎨 Core Palette (Your Muted Gold System)
  static const Color cream = Color(0xFFEBE1CA);
  static const Color sage = Color(0xFF979D8B);
  static const Color mutedGold = Color(0xFFAA9A81);
  static const Color grayGreen = Color(0xFF969B92);
  static const Color sand = Color(0xFFB99A81);
  static const Color taupe = Color(0xFF9B8972);

  // 🌑 Dark Theme
  static const Color bgDark = Color(0xFF12110F);
  static const Color surfaceDark = Color(0xFF1E1C19);

  // ☀️ Light Theme
  static const Color bgLight = cream;
  static const Color surfaceLight = Color(0xFFF5EFE3);

  // 📝 Text
  static const Color textPrimaryDark = cream;
  static const Color textSecondaryDark = Color(0xFFB0A999);

  static const Color textPrimaryLight = Color(0xFF2A2622);
  static const Color textSecondaryLight = Color(0xFF6B635A);

  // ⚠️ States
  static const Color error = Color(0xFFBA1A1A);
  static const Color onError = Colors.white;
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onErrorContainer = Color(0xFF410002);

  // 🔗 Semantic Aliases (Fixes UI Crash)
  static const Color primary = mutedGold;
  static const Color onPrimary = Colors.white;
  static const Color primaryContainer = taupe;
  static const Color onPrimaryContainer = Colors.white;
  static const Color onPrimaryColorContainer = Colors.white;
  static const Color onPrimaryFixedVariant = sand;

  static const Color secondary = sage;
  static const Color onSecondary = Colors.white;
  static const Color secondaryContainer = grayGreen;
  static const Color onSecondaryFixedVariant = sage;

  static const Color tertiary = grayGreen;
  static const Color onTertiary = Colors.white;
  static const Color tertiaryContainer = sage;
  static const Color onTertiaryContainer = Colors.white;

  static const Color surface = surfaceLight;
  static const Color onSurface = textPrimaryLight;
  static const Color onSurfaceVariant = textSecondaryLight;

  static const Color outline = taupe;
  static const Color outlineVariant = sage;

  static const Color surfaceContainerLowest = cream;
  static const Color surfaceContainerLow = surfaceLight;
  static const Color surfaceContainer = surfaceLight;
  static const Color surfaceContainerHigh = surfaceLight;
  static const Color surfaceContainerHighest = cream;

  static const Color surfaceTint = mutedGold;
  static const Color surfaceBright = surfaceLight;

  // ✨ Qibla & Special UI (Celestial Legacy Support)
  static const Color celestialGold = mutedGold;
  static const Color celestialGoldLight = sand;
  static const Color celestialSilver = sage;
  static const Color celestialGlow = Color(0x4DAA9A81);
  static const Color celestialBg = bgDark;
  static const Color compassFace = surfaceDark;
  static const Color compassText = textPrimaryDark;
  static const Color compassMarking = sage;

  // Prayer Colors
  static const Color fajr = Color(0xFF3F3D89);
  static const Color sunrise = Color(0xFFC99B35);
  static const Color ishraq = Color(0xFFFF9800); // Vibrant Morning Orange
  static const Color chast = Color(0xFFFFC107); // Bright Morning Gold
  static const Color dhuhr = Color(0xFFE49625);
  static const Color asr = Color(0xFFE25E25);
  static const Color maghrib = Color(0xFF8B1A1A);
  static const Color isha = Color(0xFF3B5D7E);

  // Day-specific colors
  static const Color fridayEmerald = Color(0xFF2E7D32);
  static const Color sundayCrimson = Color(0xFFC62828);
  static const Color weekdaySlate = Color(0xFF546E7A);

  // Milestone Colors
  static const Color sehriIndigo = Color(0xFF1A237E);
  static const Color sunriseGold = Color(0xFFFFA000);
  static const Color sunsetCrimson = Color(0xFFBF360C);
  static const Color iftarEmerald = Color(0xFF1B5E20);

  // 🕌 Quran Sanctuary Palette (Coffee & Coral)
  static const Color quranPrimary = Color(0xFF563429);
  static const Color quranSurface = Color(0xFFFFF8F4);
  static const Color quranSecondaryContainer = Color(0xFFFED4C2);
  static const Color quranPrimaryContainer = Color(0xFF704B3E);
  static const Color quranOnSurface = Color(0xFF1E1B18);
  static const Color quranSurfaceLow = Color(0xFFFAF2EC);
  static const Color quranSurfaceHigh = Color(0xFFEFE7E1);
  static const Color quranOutline = Color(0xFF83746F);
  static const Color quranOnSecondaryContainer = Color(0xFF795A4C);
  static const Color quranPrimaryFixedDim = Color(0xFFEDBBAB);

  /// ✅ Returns a premium multi-stop gradient based on the prayer name
  static LinearGradient getPrayerGradient(String prayerName) {
    final name = prayerName.toLowerCase();

    if (name.contains('fajr')) {
      return const LinearGradient(
        colors: [Color(0xFF1A1F3C), Color(0xFF283593), Color(0xFF3949AB)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }
    if (name.contains('sunrise')) {
      return const LinearGradient(
        colors: [Color(0xFFE65100), Color(0xFFFB8C00), Color(0xFFFFB300)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }
    if (name.contains('ishraq') ||
        name.contains('chast') ||
        name.contains('duha')) {
      return const LinearGradient(
        colors: [Color(0xFFFFA000), Color(0xFFFFD54F), Color(0xFF81D4FA)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }
    if (name.contains('dhuhr')) {
      return const LinearGradient(
        colors: [Color(0xFF0277BD), Color(0xFF039BE5), Color(0xFF4FC3F7)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }
    if (name.contains('asr')) {
      return const LinearGradient(
        colors: [Color(0xFFEF6C00), Color(0xFFFF9800), Color(0xFFFFCC80)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }
    if (name.contains('maghrib')) {
      return const LinearGradient(
        colors: [Color(0xFFBF360C), Color(0xFF880E4F), Color(0xFF4A148C)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }
    if (name.contains('isha')) {
      return const LinearGradient(
        colors: [Color(0xFF311B92), Color(0xFF1A237E), Color(0xFF0D47A1)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }

    return LinearGradient(
      colors: [primary, primary.withValues(alpha: 0.8)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  /// ✅ Returns a shadow matching the prayer's color for a 'glow' effect
  static BoxShadow getPrayerShadow(String prayerName, {bool isLarge = false}) {
    final color = getPrayerBaseColor(prayerName);
    return BoxShadow(
      color: color.withValues(alpha: isLarge ? 0.4 : 0.25),
      blurRadius: isLarge ? 24 : 12,
      offset: Offset(0, isLarge ? 8 : 4),
    );
  }

  static Color getPrayerBaseColor(String prayerName) {
    final name = prayerName.toLowerCase();
    if (name.contains('fajr')) return fajr;
    if (name.contains('sunrise')) return sunrise;
    if (name.contains('ishraq')) return ishraq;
    if (name.contains('chast') || name.contains('duha')) return chast;
    if (name.contains('dhuhr')) return dhuhr;
    if (name.contains('asr')) return asr;
    if (name.contains('maghrib')) return maghrib;
    if (name.contains('isha')) return isha;
    return primary;
  }

  // Gradients
  static const Gradient bentoGradient = LinearGradient(
    colors: [Color(0x1AAA9A81), Color(0x1A979D8B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient radialHighlight = RadialGradient(
    colors: [Color(0x33AA9A81), Colors.transparent],
    center: Alignment.center,
    radius: 0.8,
  );

  // Material 3 Fixed Roles
  static const Color primaryFixedDim = mutedGold;
  static const Color onPrimaryFixed = textPrimaryLight;
  static const Color primaryFixed = cream;

  static const Color secondaryFixedDim = sage;
  static const Color onSecondaryFixed = textPrimaryLight;
  static const Color secondaryFixed = cream;

  static const Color tertiaryFixedDim = grayGreen;
  static const Color onTertiaryFixed = textPrimaryLight;
  static const Color tertiaryFixed = cream;

  // Utility
  static Color withAlpha(Color color, double alpha) =>
      color.withValues(alpha: alpha);
}

class AppTypography {
  // Serif (Spiritual feel)
  static TextStyle get display => GoogleFonts.amiri(
        fontSize: 32,
        fontWeight: FontWeight.bold,
      );

  static TextStyle get headline => GoogleFonts.amiri(
        fontWeight: FontWeight.bold,
      );

  // Clean UI
  static TextStyle get body => GoogleFonts.inter();

  static TextStyle get title => GoogleFonts.inter(
        fontWeight: FontWeight.w600,
      );

  static TextStyle get label => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
      );

  // Special UI
  static TextStyle get compassDirection => headline.copyWith(fontSize: 24);
}

class AppShapes {
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 24.0;
  static const double radiusFull = 100.0;

  static BorderRadius get md => BorderRadius.circular(radiusMd);
  static BorderRadius get lg => BorderRadius.circular(radiusLg);
  static BorderRadius get xl => BorderRadius.circular(radiusXl);
  static BorderRadius get fullRadius => BorderRadius.circular(radiusFull);

  // Legacy Aliases
  static BorderRadius get smRadius => BorderRadius.circular(8.0);
  static BorderRadius get mdRadius => md;
  static BorderRadius get lgRadius => lg;
  static BorderRadius get xlRadius => xl;
  static BorderRadius get defaultRadius => md;
}

class AppAnimations {
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration pulseAnimation = Duration(seconds: 4);

  static const Curve smooth = Curves.easeInOut;
}
