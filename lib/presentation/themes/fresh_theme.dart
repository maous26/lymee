// lib/presentation/themes/fresh_theme.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';

class FreshTheme {
  // Palette principale
  static const Color primaryMint = Color(0xFF00D4AA);
  static const Color primaryMintLight = Color(0xFF4DFFDA);
  static const Color primaryMintDark = Color(0xFF00A085);

  static const Color accentCoral = Color(0xFFFF6B6B);
  static const Color accentCoralLight = Color(0xFFFF9F9F);
  static const Color accentCoralDark = Color(0xFFE55555);

  static const Color serenityBlue = Color(0xFF4ECDC4);
  static const Color deepOcean = Color(0xFF2C3E50);
  static const Color sunGold = Color(0xFFFFA726);
  static const Color warmAmber = Color(0xFFFFCC02);

  static const Color cloudWhite = Color(0xFFFBFBFB);
  static const Color mistGray = Color(0xFFF5F7FA);
  static const Color stormGray = Color(0xFF8E9AAF);
  static const Color midnightGray = Color(0xFF2C3E50);

  // Méthodes pour le score nutritionnel
  static Color getNutritionScoreColor(double score) {
    if (score >= 4.0) return const Color(0xFF4CAF50); // Vert
    if (score >= 3.0) return const Color(0xFFFF9800); // Orange
    if (score >= 2.0) return const Color(0xFFFF5722); // Rouge-orange
    return const Color(0xFFF44336); // Rouge
  }

  static String getNutritionScoreLabel(double score) {
    if (score >= 4.0) return 'Excellent';
    if (score >= 3.0) return 'Bon';
    if (score >= 2.0) return 'Moyen';
    return 'Faible';
  }

  static ThemeData light() {
    final ThemeData base = ThemeData.light(useMaterial3: true);

    final TextTheme textTheme = TextTheme(
      displayLarge: GoogleFonts.poppins(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        color: midnightGray,
      ),
      headlineMedium: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.15,
        color: midnightGray,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: midnightGray,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: midnightGray,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: midnightGray,
      ),
      labelLarge: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        color: Colors.white,
      ),
    );

    return base.copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryMint,
        primary: primaryMint,
        secondary: accentCoral,
        tertiary: serenityBlue,
        surface: cloudWhite,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: cloudWhite,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: midnightGray,
        centerTitle: true,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: midnightGray,
        ),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryMint,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          elevation: 0,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: mistGray,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primaryMint, width: 1.5),
        ),
        hintStyle: GoogleFonts.inter(color: stormGray),
      ),
      chipTheme: base.chipTheme.copyWith(
        color: const WidgetStatePropertyAll(
          Color(0x1A00D4AA), // mint with low opacity
        ),
        labelStyle: GoogleFonts.inter(
          color: primaryMint,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      cardTheme: const CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
      ),
      dividerColor: mistGray,
      splashColor: primaryMint.withValues(alpha: 0.08),
      highlightColor: primaryMint.withValues(alpha: 0.04),
    );
  }
}
