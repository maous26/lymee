import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EnhancedTheme {
  // Enhanced Color Palette with Light Effects
  static const Color primaryTeal = Color(0xFF14B8A6); // Bright, readable teal
  static const Color primaryTealLight =
      Color(0xFF2DD4BF); // Light teal for effects
  static const Color primaryTealDark = Color(0xFF0F766E); // Dark teal for depth
  static const Color primaryTealExtraLight =
      Color(0xFFCCFBF1); // Very light for backgrounds

  static const Color secondaryOrange = Color(0xFFF97316);
  static const Color secondaryOrangeLight = Color(0xFFFB923C);
  static const Color secondaryOrangeDark = Color(0xFFEA580C);

  // Neutral colors with better contrast
  static const Color neutralWhite = Color(0xFFFFFFFF);
  static const Color neutralGray50 = Color(0xFFFAFAFA);
  static const Color neutralGray100 = Color(0xFFF5F5F5);
  static const Color neutralGray200 = Color(0xFFE5E5E5);
  static const Color neutralGray300 = Color(0xFFD4D4D4);
  static const Color neutralGray400 = Color(0xFFA3A3A3);
  static const Color neutralGray500 = Color(0xFF737373);
  static const Color neutralGray600 = Color(0xFF525252);
  static const Color neutralGray700 = Color(0xFF404040);
  static const Color neutralGray800 = Color(0xFF262626);
  static const Color neutralGray900 = Color(0xFF171717);

  // Success and error colors
  static const Color successGreen = Color(0xFF10B981);
  static const Color errorRed = Color(0xFFEF4444);
  static const Color warningYellow = Color(0xFFF59E0B);
  static const Color infoBlue = Color(0xFF3B82F6);

  // Spacing
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;
  static const double spacingXXL = 48.0;

  // Border radius
  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;
  static const double radiusXL = 24.0;

  // Shadows with light effects
  static const List<BoxShadow> shadowLight = [
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 4,
      offset: Offset(0, 2),
    ),
  ];

  static const List<BoxShadow> shadowMedium = [
    BoxShadow(
      color: Color(0x14000000),
      blurRadius: 8,
      offset: Offset(0, 4),
    ),
  ];

  static const List<BoxShadow> shadowHeavy = [
    BoxShadow(
      color: Color(0x1F000000),
      blurRadius: 16,
      offset: Offset(0, 8),
    ),
  ];

  // Glowing effect shadows
  static const List<BoxShadow> glowTeal = [
    BoxShadow(
      color: Color(0x2014B8A6),
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
  ];

  static const List<BoxShadow> glowOrange = [
    BoxShadow(
      color: Color(0x20F97316),
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
  ];

  // Typography
  static TextTheme get textTheme => GoogleFonts.interTextTheme(
        const TextTheme(
          displayLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
            color: neutralGray900,
          ),
          displayMedium: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.25,
            color: neutralGray900,
          ),
          displaySmall: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: neutralGray900,
          ),
          headlineLarge: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: neutralGray900,
          ),
          headlineMedium: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: neutralGray900,
          ),
          headlineSmall: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: neutralGray900,
          ),
          titleLarge: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: neutralGray900,
          ),
          titleMedium: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: neutralGray900,
          ),
          titleSmall: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: neutralGray700,
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: neutralGray700,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: neutralGray600,
          ),
          bodySmall: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: neutralGray500,
          ),
          labelLarge: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: neutralGray700,
          ),
          labelMedium: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: neutralGray600,
          ),
          labelSmall: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: neutralGray500,
          ),
        ),
      );

  // Main theme
  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        fontFamily: GoogleFonts.inter().fontFamily,
        colorScheme: const ColorScheme.light(
          primary: primaryTeal,
          onPrimary: neutralWhite,
          primaryContainer: primaryTealExtraLight,
          onPrimaryContainer: primaryTealDark,
          secondary: secondaryOrange,
          onSecondary: neutralWhite,
          secondaryContainer: Color(0xFFFED7AA),
          onSecondaryContainer: secondaryOrangeDark,
          surface: neutralWhite,
          onSurface: neutralGray900,
          surfaceContainerHighest: neutralGray100,
          onSurfaceVariant: neutralGray700,
          outline: neutralGray300,
          error: errorRed,
          onError: neutralWhite,
        ),
        textTheme: textTheme,
        appBarTheme: AppBarTheme(
          backgroundColor: primaryTeal,
          foregroundColor: neutralWhite,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: textTheme.headlineSmall?.copyWith(
            color: neutralWhite,
            fontWeight: FontWeight.w600,
          ),
          iconTheme: const IconThemeData(
            color: neutralWhite,
            size: 24,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryTeal,
            foregroundColor: neutralWhite,
            elevation: 0,
            shadowColor: Colors.transparent,
            padding: const EdgeInsets.symmetric(
                horizontal: spacingL, vertical: spacingM),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radiusM),
            ),
            textStyle: textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ).copyWith(
            overlayColor: WidgetStateProperty.all(
                primaryTealLight.withValues(alpha: 0.1)),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: primaryTeal,
            padding: const EdgeInsets.symmetric(
                horizontal: spacingM, vertical: spacingS),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radiusM),
            ),
            textStyle: textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ).copyWith(
            overlayColor:
                WidgetStateProperty.all(primaryTeal.withValues(alpha: 0.1)),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: primaryTeal,
            side: const BorderSide(color: primaryTeal, width: 1.5),
            padding: const EdgeInsets.symmetric(
                horizontal: spacingL, vertical: spacingM),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radiusM),
            ),
            textStyle: textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ).copyWith(
            overlayColor:
                WidgetStateProperty.all(primaryTeal.withValues(alpha: 0.1)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: neutralGray50,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusM),
            borderSide: const BorderSide(color: neutralGray200),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusM),
            borderSide: const BorderSide(color: neutralGray200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusM),
            borderSide: const BorderSide(color: primaryTeal, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusM),
            borderSide: const BorderSide(color: errorRed),
          ),
          contentPadding: const EdgeInsets.symmetric(
              horizontal: spacingM, vertical: spacingM),
          hintStyle: textTheme.bodyMedium?.copyWith(color: neutralGray400),
          labelStyle: textTheme.bodyMedium?.copyWith(color: neutralGray600),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusM),
          ),
          color: neutralWhite,
          shadowColor: Colors.transparent,
          margin: EdgeInsets.zero,
        ),
        tabBarTheme: TabBarThemeData(
          labelColor: primaryTeal,
          unselectedLabelColor: neutralGray500,
          indicatorColor: primaryTeal,
          indicatorSize: TabBarIndicatorSize.label,
          labelStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: neutralWhite,
          selectedItemColor: primaryTeal,
          unselectedItemColor: neutralGray400,
          elevation: 8,
          type: BottomNavigationBarType.fixed,
        ),
      );
}
