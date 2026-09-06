import 'package:flutter/material.dart';

/// Central design tokens for NovaKrishi.
///
/// The product is a "direct agri-marketplace" — the brand language leans on
/// deep forest greens for trust/security, a bright mint/lime green for
/// growth & pricing accents, and a warm off-white canvas so produce photos
/// and price cards pop.
class AppColors {
  AppColors._();

  static const Color primaryDark = Color(0xFF0B4D33); // deep forest green
  static const Color primary = Color(0xFF0F6B44); // core brand green
  static const Color primaryLight = Color(0xFF14894F);
  static const Color accentMint = Color(0xFF34C77B); // bright accent / CTAs
  static const Color accentLime = Color(0xFF7ED957); // AI / growth accents

  static const Color success = Color(0xFF16A34A);
  static const Color danger = Color(0xFFDC2626);
  static const Color warningBg = Color(0xFFFFF7E6);

  static const Color surface = Color(0xFFFFFFFF);
  static const Color canvas = Color(0xFFF6FAF7); // app background
  static const Color mintTint = Color(0xFFEAF7EF); // soft green card fill
  static const Color mintTintStrong = Color(0xFFDFF3E6);

  static const Color border = Color(0xFFE3E9E5);
  static const Color textPrimary = Color(0xFF102818);
  static const Color textSecondary = Color(0xFF5A6B60);
  static const Color textMuted = Color(0xFF8A968E);

  static const Color chipUnselected = Color(0xFFF0F3F1);
}

class AppRadii {
  AppRadii._();
  static const double sm = 8;
  static const double md = 14;
  static const double lg = 20;
  static const double pill = 999;
}

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        secondary: AppColors.accentMint,
        surface: AppColors.surface,
      ),
      scaffoldBackgroundColor: AppColors.canvas,
      fontFamily: 'Roboto',
    );

    return base.copyWith(
      textTheme: base.textTheme.copyWith(
        displaySmall: const TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
          height: 1.15,
        ),
        titleLarge: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        titleMedium: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        bodyMedium: const TextStyle(
          fontSize: 13.5,
          color: AppColors.textSecondary,
          height: 1.4,
        ),
        bodySmall: const TextStyle(
          fontSize: 12,
          color: AppColors.textMuted,
        ),
        labelLarge: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryDark,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.primaryDark.withOpacity(0.4),
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.md),
          ),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryDark,
          minimumSize: const Size.fromHeight(52),
          side: const BorderSide(color: AppColors.border, width: 1.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.md),
          ),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.canvas,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.sm),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.sm),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.sm),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.6),
        ),
        hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13.5),
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: AppColors.chipUnselected,
        selectedColor: AppColors.primaryDark,
        labelStyle: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.pill),
          side: BorderSide.none,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
      dividerTheme: const DividerThemeData(color: AppColors.border, thickness: 1),
    );
  }
}

/// Reusable card decoration used across dashboard / price / product cards.
BoxDecoration appCardDecoration({
  Color color = AppColors.surface,
  double radius = AppRadii.md,
  Color borderColor = AppColors.border,
  List<BoxShadow>? shadow,
}) {
  return BoxDecoration(
    color: color,
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: borderColor),
    boxShadow: shadow ??
        [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
  );
}
