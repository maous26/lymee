// lib/presentation/themes/unified_theme.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Unified Design System for LYM Nutrition
/// Creates a homogeneous, marketing-friendly UI across all screens
class UnifiedTheme {
  // Core Brand Colors - Based on the beautiful teal from landing page
  static const Color primaryTeal =
      Color(0xFF4FD1C5); // Main teal (mint from LymDesignSystem)
  static const Color primaryTealLight = Color(0xFF81E6D9); // Light variant
  static const Color primaryTealDark = Color(0xFF2C7A7B); // Dark variant

  // Secondary Colors - Complementary and professional
  static const Color secondaryOrange = Color(0xFFFFBF47); // Warm, energetic
  static const Color accentBlue = Color(0xFF4299E1); // Trust, reliability
  static const Color accentGreen = Color(0xFF68D391); // Health, success

  // Neutral Colors - Professional and clean
  static const Color neutralWhite = Color(0xFFFFFFFF);
  static const Color neutralGray50 = Color(0xFFFAFAFA);
  static const Color neutralGray100 = Color(0xFFF7FAFC);
  static const Color neutralGray200 = Color(0xFFEDF2F7);
  static const Color neutralGray300 = Color(0xFFE2E8F0);
  static const Color neutralGray400 = Color(0xFFCBD5E0);
  static const Color neutralGray500 = Color(0xFFA0AEC0);
  static const Color neutralGray600 = Color(0xFF718096);
  static const Color neutralGray700 = Color(0xFF4A5568);
  static const Color neutralGray800 = Color(0xFF2D3748);
  static const Color neutralGray900 = Color(0xFF1A202C);

  // Semantic Colors - Clear communication
  static const Color successColor = Color(0xFF38A169);
  static const Color warningColor = Color(0xFFED8936);
  static const Color errorColor = Color(0xFFE53E3E);
  static const Color infoColor = Color(0xFF3182CE);

  // Typography System - Modern, readable, professional
  static TextTheme get textTheme => GoogleFonts.interTextTheme().copyWith(
        // Display styles - For hero sections and landing pages
        displayLarge: GoogleFonts.inter(
          fontSize: 48,
          fontWeight: FontWeight.w800,
          letterSpacing: -1.5,
          height: 1.1,
          color: neutralGray900,
        ),
        displayMedium: GoogleFonts.inter(
          fontSize: 36,
          fontWeight: FontWeight.w700,
          letterSpacing: -1.0,
          height: 1.2,
          color: neutralGray900,
        ),
        displaySmall: GoogleFonts.inter(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.5,
          height: 1.2,
          color: neutralGray900,
        ),

        // Headline styles - For section headers
        headlineLarge: GoogleFonts.inter(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
          height: 1.3,
          color: neutralGray800,
        ),
        headlineMedium: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
          height: 1.3,
          color: neutralGray800,
        ),
        headlineSmall: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
          height: 1.3,
          color: neutralGray800,
        ),

        // Title styles - For card headers and important text
        titleLarge: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
          height: 1.4,
          color: neutralGray800,
        ),
        titleMedium: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
          height: 1.4,
          color: neutralGray800,
        ),
        titleSmall: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
          height: 1.4,
          color: neutralGray800,
        ),

        // Body styles - For main content
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          letterSpacing: 0,
          height: 1.5,
          color: neutralGray700,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          letterSpacing: 0,
          height: 1.5,
          color: neutralGray600,
        ),
        bodySmall: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          letterSpacing: 0,
          height: 1.4,
          color: neutralGray500,
        ),

        // Label styles - For buttons and form labels
        labelLarge: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
          height: 1.2,
          color: neutralGray700,
        ),
        labelMedium: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
          height: 1.2,
          color: neutralGray600,
        ),
        labelSmall: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
          height: 1.1,
          color: neutralGray500,
        ),
      );

  // Color Scheme - Consistent across the app
  static ColorScheme get colorScheme => const ColorScheme.light(
        brightness: Brightness.light,
        primary: primaryTeal,
        onPrimary: neutralWhite,
        primaryContainer: primaryTealLight,
        onPrimaryContainer: primaryTealDark,
        secondary: secondaryOrange,
        onSecondary: neutralWhite,
        secondaryContainer: Color(0xFFFFF3CD),
        onSecondaryContainer: Color(0xFF8B4513),
        tertiary: accentBlue,
        onTertiary: neutralWhite,
        tertiaryContainer: Color(0xFFE6F3FF),
        onTertiaryContainer: Color(0xFF1A365D),
        error: errorColor,
        onError: neutralWhite,
        errorContainer: Color(0xFFFED7D7),
        onErrorContainer: Color(0xFF742A2A),
        surface: neutralWhite,
        onSurface: neutralGray800,
        onSurfaceVariant: neutralGray600,
        outline: neutralGray300,
        outlineVariant: neutralGray200,
        shadow: neutralGray900,
        scrim: neutralGray900,
        inverseSurface: neutralGray800,
        onInverseSurface: neutralWhite,
        inversePrimary: primaryTealLight,
        surfaceTint: primaryTeal,
      );

  // Theme Data - Complete theme configuration
  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        colorScheme: colorScheme,
        textTheme: textTheme,
        fontFamily: GoogleFonts.inter().fontFamily,

        // App Bar Theme
        appBarTheme: AppBarTheme(
          elevation: 0,
          backgroundColor: primaryTeal,
          foregroundColor: neutralWhite,
          centerTitle: true,
          titleTextStyle: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: neutralWhite,
          ),
          iconTheme: const IconThemeData(color: neutralWhite),
        ),

        // Card Theme
        cardTheme: CardThemeData(
          elevation: 4,
          shadowColor: neutralGray200,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          color: neutralWhite,
          surfaceTintColor: Colors.transparent,
        ),

        // Elevated Button Theme
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryTeal,
            foregroundColor: neutralWhite,
            elevation: 2,
            shadowColor: primaryTeal.withValues(alpha: 0.3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            textStyle: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        // Text Button Theme
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: primaryTeal,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            textStyle: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        // Outlined Button Theme
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: primaryTeal,
            side: const BorderSide(color: primaryTeal, width: 1.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            textStyle: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        // Input Decoration Theme
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: neutralGray50,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: neutralGray300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: neutralGray300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: primaryTeal, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: errorColor),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          labelStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: neutralGray600,
          ),
          hintStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: neutralGray500,
          ),
        ),

        // Floating Action Button Theme
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: primaryTeal,
          foregroundColor: neutralWhite,
          elevation: 6,
          shape: CircleBorder(),
        ),

        // Chip Theme
        chipTheme: ChipThemeData(
          backgroundColor: neutralGray100,
          labelStyle: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: neutralGray700,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        ),

        // Tab Bar Theme
        tabBarTheme: TabBarThemeData(
          labelColor: neutralWhite,
          unselectedLabelColor: neutralWhite.withValues(alpha: 0.7),
          indicator: const UnderlineTabIndicator(
            borderSide: BorderSide(color: neutralWhite, width: 3),
          ),
          labelStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),

        // Progress Indicator Theme
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: primaryTeal,
          linearTrackColor: neutralGray200,
          circularTrackColor: neutralGray200,
        ),

        // Divider Theme
        dividerTheme: const DividerThemeData(
          color: neutralGray200,
          thickness: 1,
          space: 1,
        ),

        // Scaffold Background
        scaffoldBackgroundColor: neutralGray50,
      );

  // Common Spacing Values
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;
  static const double spacingXXL = 48.0;
  static const double spacingXXXL = 64.0;

  // Common Border Radius Values
  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;
  static const double radiusXL = 20.0;
  static const double radiusXXL = 24.0;

  // Common Shadows
  static List<BoxShadow> get shadowSmall => [
        BoxShadow(
          color: neutralGray300.withValues(alpha: 0.3),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> get shadowMedium => [
        BoxShadow(
          color: neutralGray400.withValues(alpha: 0.2),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get shadowLarge => [
        BoxShadow(
          color: neutralGray500.withValues(alpha: 0.15),
          blurRadius: 16,
          offset: const Offset(0, 8),
        ),
      ];

  // Marketing-friendly gradients
  static LinearGradient get primaryGradient => const LinearGradient(
        colors: [primaryTeal, primaryTealLight],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  static LinearGradient get secondaryGradient => const LinearGradient(
        colors: [secondaryOrange, Color(0xFFFFF3CD)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  static LinearGradient get successGradient => const LinearGradient(
        colors: [accentGreen, Color(0xFFC6F6D5)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
}
