// lib/presentation/themes/premium_theme.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class PremiumTheme {
  // Couleurs principales - Nouvelle palette sophistiquée avec orange en principal
  static const Color primaryLight =
      Color(0xFFFF8F00); // Orange vif - nouvelle couleur principale
  static const Color primaryDark = Color(0xFFE65100); // Orange profond
  static const Color secondaryLight =
      Color(0xFF26A69A); // Vert teal - ancienne couleur principale
  static const Color secondaryDark = Color(0xFF00766C); // Vert teal foncé
  static const Color techColor = Color(0xFF7E57C2); // Violet technologique
  static const Color techColorDark = Color(0xFF5E35B1); // Violet tech foncé
  static const Color accentColor = Color(0xFF5C6BC0); // Indigo accent
  static const Color accentColorDark = Color(0xFF3F51B5); // Indigo foncé

  // Gradients avec la nouvelle palette
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryLight, primaryDark],
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [secondaryLight, secondaryDark],
  );

  static const LinearGradient techGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [techColor, techColorDark],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accentColor, accentColorDark],
  );

  // Propriétés de compatibilité pour les références existantes dans le code
  static const Color primaryColor = primaryLight; // Orange vif
  static const Color secondaryColor = secondaryLight; // Vert teal
  static const Color primaryDarkColor = primaryDark; // Orange foncé

  // Couleurs nutritionnelles spécifiques
  static const Color proteinColor =
      Color(0xFF5E72E4); // Bleu vif pour les protéines
  static const Color carbsColor =
      Color(0xFFFEBD38); // Jaune doré pour les glucides
  static const Color fatColor = Color(0xFFFF5252); // Rouge vif pour les lipides
  static const Color fiberColor = Color(0xFF11CDEF); // Cyan pour les fibres
  static const Color waterColor = Color(0xFF32A4FC); // Bleu pour l'eau

  // Couleurs sémantiques
  static const Color success = Color(0xFF2DCE89); // Vert réussite
  static const Color error = Color(0xFFF5365C); // Rouge erreur
  static const Color warning = Color(0xFFFFB236); // Jaune avertissement
  static const Color info = Color(0xFF11CDEF); // Bleu information

  // Couleurs neutres
  static const Color textDark = Color(0xFF1F2937); // Texte principal
  static const Color textMedium = Color(0xFF6B7280); // Texte secondaire
  static const Color textLight = Color(0xFFD1D5DB); // Texte tertiaire
  static const Color divider = Color(0xFFE5E7EB); // Ligne de séparation

  // Couleurs de fond
  static const Color backgroundLight =
      Color(0xFFF9FAFB); // Fond principal clair
  static const Color surfaceLight = Colors.white; // Surfaces claires
  static const Color backgroundDark =
      Color(0xFF111827); // Fond principal sombre
  static const Color surfaceDark = Color(0xFF1F2937); // Surfaces sombres

  // Ombres
  static List<BoxShadow> shadowSmall = [
    BoxShadow(
      color: Colors.black.withOpacity(0.04),
      blurRadius: 3,
      offset: const Offset(0, 1),
    ),
    BoxShadow(
      color: Colors.black.withOpacity(0.06),
      blurRadius: 2,
      offset: const Offset(0, 1),
    ),
  ];

  static List<BoxShadow> shadowMedium = [
    BoxShadow(
      color: Colors.black.withOpacity(0.1),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
    BoxShadow(
      color: Colors.black.withOpacity(0.06),
      blurRadius: 4,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> shadowLarge = [
    BoxShadow(
      color: Colors.black.withOpacity(0.15),
      blurRadius: 20,
      offset: const Offset(0, 10),
    ),
    BoxShadow(
      color: Colors.black.withOpacity(0.1),
      blurRadius: 6,
      offset: const Offset(0, 3),
    ),
  ];

  // Glassmorphism et effets modernes
  static BoxDecoration glassEffect = BoxDecoration(
    color: Colors.white.withOpacity(0.15),
    borderRadius: BorderRadius.circular(16),
    border: Border.all(
      color: Colors.white.withOpacity(0.2),
      width: 1.5,
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 20,
      ),
    ],
    backgroundBlendMode: BlendMode.srcOver,
  );

  static BoxDecoration neumorphicEffect({Color? color, bool pressed = false}) {
    final effectiveColor = color ?? backgroundLight;
    return BoxDecoration(
      color: effectiveColor,
      borderRadius: BorderRadius.circular(16),
      boxShadow: pressed
          ? [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                offset: const Offset(2, 2),
                blurRadius: 4,
                spreadRadius: 1,
              ),
              BoxShadow(
                color: Colors.white.withOpacity(0.5),
                offset: const Offset(-2, -2),
                blurRadius: 4,
                spreadRadius: 1,
              ),
            ]
          : [
              BoxShadow(
                color: Colors.white.withOpacity(0.5),
                offset: const Offset(-2, -2),
                blurRadius: 4,
                spreadRadius: 1,
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                offset: const Offset(2, 2),
                blurRadius: 4,
                spreadRadius: 1,
              ),
            ],
    );
  }

  // Animations
  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationMedium = Duration(milliseconds: 400);
  static const Duration animationSlow = Duration(milliseconds: 800);

  // Dimensions
  static const double borderRadiusSmall = 8.0;
  static const double borderRadiusMedium = 16.0;
  static const double borderRadiusLarge = 24.0;
  static const double borderRadiusXLarge = 32.0;
  static const double cardPadding = 20.0;
  static const double spacing = 16.0;
  static const double iconSize = 24.0;

  // Compatibility aliases for old AppTheme properties
  static const Color primaryLightColor = primaryLight;

  // Nutrition scores (compatibility with old AppTheme)
  static const Color scoreExcellent = success;
  static const Color scoreGood = primaryLight;
  static const Color scoreMedium = warning;
  static const Color scorePoor = accentColor;
  static const Color scoreBad = error;

  // Utility methods for nutrition scores
  static Color getNutritionScoreColor(double score) {
    if (score >= 4.5) return scoreExcellent; // 4.5-5: Excellent
    if (score >= 3.5) return scoreGood; // 3.5-4.5: Bon
    if (score >= 2.5) return scoreMedium; // 2.5-3.5: Moyen
    if (score >= 1.5) return scorePoor; // 1.5-2.5: Faible
    return scoreBad; // 1-1.5: Mauvais
  }

  static String getNutritionScoreLabel(double score) {
    if (score >= 4.5) return 'Excellent';
    if (score >= 3.5) return 'Bon';
    if (score >= 2.5) return 'Moyen';
    if (score >= 1.5) return 'Faible';
    return 'Mauvais';
  }

  // Thème clair
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: primaryLight,
    colorScheme: ColorScheme.light(
      primary: primaryLight,
      onPrimary: Colors.white,
      primaryContainer: primaryLight.withOpacity(0.15),
      onPrimaryContainer: primaryDark,
      secondary: secondaryLight,
      onSecondary: Colors.white,
      secondaryContainer: secondaryLight.withOpacity(0.15),
      onSecondaryContainer: secondaryDark,
      tertiary: accentColor,
      onTertiary: Colors.white,
      tertiaryContainer: accentColor.withOpacity(0.15),
      onTertiaryContainer: accentColorDark,
      error: error,
      onError: Colors.white,
      background: backgroundLight,
      onBackground: textDark,
      surface: surfaceLight,
      onSurface: textDark,
    ),

    // Typographie
    textTheme: GoogleFonts.poppinsTextTheme(
      ThemeData.light().textTheme.copyWith(
            displayLarge: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
              color: textDark,
            ),
            displayMedium: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
              color: textDark,
            ),
            displaySmall: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.25,
              color: textDark,
            ),
            headlineMedium: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.25,
              color: textDark,
            ),
            headlineSmall: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.25,
              color: textDark,
            ),
            titleLarge: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 0,
              color: textDark,
            ),
            titleMedium: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.1,
              color: textDark,
            ),
            titleSmall: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.1,
              color: textMedium,
            ),
            bodyLarge: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.normal,
              letterSpacing: 0.15,
              color: textDark,
            ),
            bodyMedium: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.normal,
              letterSpacing: 0.25,
              color: textDark,
            ),
            bodySmall: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.normal,
              letterSpacing: 0.4,
              color: textMedium,
            ),
            labelLarge: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.1,
              color: primaryLight,
            ),
            labelMedium: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
              color: primaryLight,
            ),
            labelSmall: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
              color: textMedium,
            ),
          ),
    ),

    // Composants
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: textDark,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      titleTextStyle: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textDark,
      ),
      iconTheme: const IconThemeData(color: textDark),
      centerTitle: true,
    ),

    bottomAppBarTheme: const BottomAppBarTheme(
      color: Colors.white,
      elevation: 0,
    ),

    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: primaryLight,
      unselectedItemColor: textMedium,
      selectedLabelStyle: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      unselectedLabelStyle: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      elevation: 8,
      type: BottomNavigationBarType.fixed,
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.disabled)) {
            return primaryLight.withOpacity(0.5);
          }
          return primaryLight;
        }),
        foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
        elevation: MaterialStateProperty.all<double>(0),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadiusMedium),
          ),
        ),
        padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
          const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
        textStyle: MaterialStateProperty.all<TextStyle>(
          GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        overlayColor:
            MaterialStateProperty.all<Color>(Colors.white.withOpacity(0.1)),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: ButtonStyle(
        foregroundColor: MaterialStateProperty.all<Color>(primaryLight),
        backgroundColor: MaterialStateProperty.all<Color>(Colors.transparent),
        side: MaterialStateProperty.all<BorderSide>(
          BorderSide(color: primaryLight, width: 2),
        ),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadiusMedium),
          ),
        ),
        padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
          const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
        textStyle: MaterialStateProperty.all<TextStyle>(
          GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
        foregroundColor: MaterialStateProperty.all<Color>(primaryLight),
        padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
          const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
        textStyle: MaterialStateProperty.all<TextStyle>(
          GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.25,
          ),
        ),
      ),
    ),

    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: primaryLight,
      foregroundColor: Colors.white,
      elevation: 4,
      highlightElevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadiusMedium),
      ),
    ),

    iconTheme: const IconThemeData(
      color: textDark,
      size: iconSize,
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadiusMedium),
        borderSide: BorderSide(color: textLight.withOpacity(0.5), width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadiusMedium),
        borderSide: BorderSide(color: textLight.withOpacity(0.5), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadiusMedium),
        borderSide: BorderSide(color: primaryLight, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadiusMedium),
        borderSide: BorderSide(color: error, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadiusMedium),
        borderSide: BorderSide(color: error, width: 2),
      ),
      hintStyle: TextStyle(color: textMedium.withOpacity(0.6)),
      labelStyle: const TextStyle(color: textMedium),
      errorStyle: const TextStyle(color: error, fontSize: 12),
      prefixIconColor: textMedium,
      suffixIconColor: textMedium,
    ),

    checkboxTheme: CheckboxThemeData(
      fillColor: MaterialStateProperty.resolveWith<Color>((states) {
        if (states.contains(MaterialState.selected)) {
          return primaryLight;
        }
        return Colors.transparent;
      }),
      checkColor: MaterialStateProperty.all<Color>(Colors.white),
      side: BorderSide(color: textMedium.withOpacity(0.5), width: 1.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadiusSmall / 2),
      ),
    ),

    radioTheme: RadioThemeData(
      fillColor: MaterialStateProperty.resolveWith<Color>((states) {
        if (states.contains(MaterialState.selected)) {
          return primaryLight;
        }
        return textMedium.withOpacity(0.5);
      }),
    ),

    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.resolveWith<Color>((states) {
        if (states.contains(MaterialState.selected)) {
          return primaryLight;
        }
        return Colors.white;
      }),
      trackColor: MaterialStateProperty.resolveWith<Color>((states) {
        if (states.contains(MaterialState.selected)) {
          return primaryLight.withOpacity(0.4);
        }
        return textLight.withOpacity(0.3);
      }),
    ),

    chipTheme: ChipThemeData(
      backgroundColor: primaryLight.withOpacity(0.1),
      selectedColor: primaryLight.withOpacity(0.2),
      disabledColor: textLight.withOpacity(0.1),
      labelStyle: TextStyle(color: primaryDark),
      secondaryLabelStyle: const TextStyle(color: Colors.white),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadiusMedium),
        side: BorderSide(color: primaryLight.withOpacity(0.2)),
      ),
    ),

    cardTheme: CardTheme(
      color: Colors.white,
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadiusMedium),
        side: BorderSide(
          color: textLight.withOpacity(0.2),
          width: 1,
        ),
      ),
    ),

    sliderTheme: SliderThemeData(
      activeTrackColor: primaryLight,
      inactiveTrackColor: primaryLight.withOpacity(0.2),
      thumbColor: Colors.white,
      overlayColor: primaryLight.withOpacity(0.2),
      valueIndicatorColor: primaryLight,
      valueIndicatorTextStyle: const TextStyle(color: Colors.white),
      trackHeight: 4,
      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
    ),

    tabBarTheme: TabBarTheme(
      labelColor: primaryLight,
      unselectedLabelColor: textMedium,
      indicatorColor: primaryLight,
      labelStyle: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    ),

    dialogTheme: DialogTheme(
      backgroundColor: Colors.white,
      elevation: 24,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadiusLarge),
      ),
      titleTextStyle: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: textDark,
      ),
      contentTextStyle: GoogleFonts.poppins(
        fontSize: 16,
        color: textDark,
      ),
    ),

    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: Colors.white,
      elevation: 24,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(borderRadiusLarge),
          topRight: Radius.circular(borderRadiusLarge),
        ),
      ),
    ),

    dividerTheme: const DividerThemeData(
      color: divider,
      thickness: 1,
      space: 24,
    ),

    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: primaryLight,
      circularTrackColor: primaryLight.withOpacity(0.2),
      linearTrackColor: primaryLight.withOpacity(0.2),
    ),

    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: textDark.withOpacity(0.9),
        borderRadius: BorderRadius.circular(borderRadiusSmall),
      ),
      textStyle: const TextStyle(color: Colors.white),
    ),

    snackBarTheme: SnackBarThemeData(
      backgroundColor: textDark,
      contentTextStyle: const TextStyle(color: Colors.white),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadiusMedium),
      ),
      behavior: SnackBarBehavior.floating,
      elevation: 6,
    ),
  );

  // Thème sombre
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: primaryLight,
    colorScheme: ColorScheme.dark(
      primary: primaryLight,
      onPrimary: Colors.white,
      primaryContainer: primaryLight.withOpacity(0.15),
      onPrimaryContainer: Colors.white,
      secondary: secondaryLight,
      onSecondary: Colors.white,
      secondaryContainer: secondaryLight.withOpacity(0.15),
      onSecondaryContainer: Colors.white,
      tertiary: accentColor,
      onTertiary: Colors.white,
      tertiaryContainer: accentColor.withOpacity(0.15),
      onTertiaryContainer: Colors.white,
      error: error,
      onError: Colors.white,
      background: backgroundDark,
      onBackground: Colors.white,
      surface: surfaceDark,
      onSurface: Colors.white,
    ),

    // Typographie
    textTheme: GoogleFonts.poppinsTextTheme(
      ThemeData.dark().textTheme.copyWith(
            displayLarge: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
              color: Colors.white,
            ),
            displayMedium: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
              color: Colors.white,
            ),
            displaySmall: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.25,
              color: Colors.white,
            ),
            headlineMedium: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.25,
              color: Colors.white,
            ),
            headlineSmall: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.25,
              color: Colors.white,
            ),
            titleLarge: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 0,
              color: Colors.white,
            ),
            titleMedium: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.1,
              color: Colors.white,
            ),
            titleSmall: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.1,
              color: Colors.white.withOpacity(0.7),
            ),
            bodyLarge: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.normal,
              letterSpacing: 0.15,
              color: Colors.white,
            ),
            bodyMedium: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.normal,
              letterSpacing: 0.25,
              color: Colors.white,
            ),
            bodySmall: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.normal,
              letterSpacing: 0.4,
              color: Colors.white.withOpacity(0.7),
            ),
            labelLarge: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.1,
              color: primaryLight,
            ),
            labelMedium: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
              color: primaryLight,
            ),
            labelSmall: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
    ),

    // Composants
    appBarTheme: AppBarTheme(
      backgroundColor: surfaceDark,
      foregroundColor: Colors.white,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      titleTextStyle: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      iconTheme: const IconThemeData(color: Colors.white),
      centerTitle: true,
    ),

    bottomAppBarTheme: BottomAppBarTheme(
      color: surfaceDark,
      elevation: 0,
    ),

    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: surfaceDark,
      selectedItemColor: primaryLight,
      unselectedItemColor: Colors.white.withOpacity(0.6),
      selectedLabelStyle: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      unselectedLabelStyle: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      elevation: 8,
      type: BottomNavigationBarType.fixed,
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.disabled)) {
            return primaryLight.withOpacity(0.5);
          }
          return primaryLight;
        }),
        foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
        elevation: MaterialStateProperty.all<double>(0),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadiusMedium),
          ),
        ),
        padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
          const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
        textStyle: MaterialStateProperty.all<TextStyle>(
          GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        overlayColor:
            MaterialStateProperty.all<Color>(Colors.white.withOpacity(0.1)),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: ButtonStyle(
        foregroundColor: MaterialStateProperty.all<Color>(primaryLight),
        backgroundColor: MaterialStateProperty.all<Color>(Colors.transparent),
        side: MaterialStateProperty.all<BorderSide>(
          BorderSide(color: primaryLight, width: 2),
        ),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadiusMedium),
          ),
        ),
        padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
          const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
        textStyle: MaterialStateProperty.all<TextStyle>(
          GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
        foregroundColor: MaterialStateProperty.all<Color>(primaryLight),
        padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
          const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
        textStyle: MaterialStateProperty.all<TextStyle>(
          GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.25,
          ),
        ),
      ),
    ),

    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: primaryLight,
      foregroundColor: Colors.white,
      elevation: 4,
      highlightElevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadiusMedium),
      ),
    ),

    iconTheme: const IconThemeData(
      color: Colors.white,
      size: iconSize,
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceDark,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadiusMedium),
        borderSide: BorderSide(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadiusMedium),
        borderSide: BorderSide(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadiusMedium),
        borderSide: BorderSide(color: primaryLight, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadiusMedium),
        borderSide: BorderSide(color: error, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadiusMedium),
        borderSide: BorderSide(color: error, width: 2),
      ),
      hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
      labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
      errorStyle: TextStyle(color: error, fontSize: 12),
      prefixIconColor: Colors.white.withOpacity(0.7),
      suffixIconColor: Colors.white.withOpacity(0.7),
    ),

    checkboxTheme: CheckboxThemeData(
      fillColor: MaterialStateProperty.resolveWith<Color>((states) {
        if (states.contains(MaterialState.selected)) {
          return primaryLight;
        }
        return Colors.transparent;
      }),
      checkColor: MaterialStateProperty.all<Color>(Colors.white),
      side: BorderSide(color: Colors.white.withOpacity(0.5), width: 1.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadiusSmall / 2),
      ),
    ),

    radioTheme: RadioThemeData(
      fillColor: MaterialStateProperty.resolveWith<Color>((states) {
        if (states.contains(MaterialState.selected)) {
          return primaryLight;
        }
        return Colors.white.withOpacity(0.5);
      }),
    ),

    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.resolveWith<Color>((states) {
        if (states.contains(MaterialState.selected)) {
          return primaryLight;
        }
        return Colors.white;
      }),
      trackColor: MaterialStateProperty.resolveWith<Color>((states) {
        if (states.contains(MaterialState.selected)) {
          return primaryLight.withOpacity(0.4);
        }
        return Colors.white.withOpacity(0.3);
      }),
    ),

    chipTheme: ChipThemeData(
      backgroundColor: primaryLight.withOpacity(0.1),
      selectedColor: primaryLight.withOpacity(0.2),
      disabledColor: Colors.white.withOpacity(0.1),
      labelStyle: TextStyle(color: Colors.white),
      secondaryLabelStyle: TextStyle(color: Colors.white),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadiusMedium),
        side: BorderSide(color: primaryLight.withOpacity(0.2)),
      ),
    ),

    cardTheme: CardTheme(
      color: surfaceDark,
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadiusMedium),
        side: BorderSide(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
    ),

    sliderTheme: SliderThemeData(
      activeTrackColor: primaryLight,
      inactiveTrackColor: primaryLight.withOpacity(0.2),
      thumbColor: Colors.white,
      overlayColor: primaryLight.withOpacity(0.2),
      valueIndicatorColor: primaryLight,
      valueIndicatorTextStyle: const TextStyle(color: Colors.white),
      trackHeight: 4,
      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
    ),

    tabBarTheme: TabBarTheme(
      labelColor: primaryLight,
      unselectedLabelColor: Colors.white.withOpacity(0.7),
      indicatorColor: primaryLight,
      labelStyle: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    ),

    dialogTheme: DialogTheme(
      backgroundColor: surfaceDark,
      elevation: 24,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadiusLarge),
      ),
      titleTextStyle: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      contentTextStyle: GoogleFonts.poppins(
        fontSize: 16,
        color: Colors.white,
      ),
    ),

    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: surfaceDark,
      elevation: 24,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(borderRadiusLarge),
          topRight: Radius.circular(borderRadiusLarge),
        ),
      ),
    ),

    dividerTheme: DividerThemeData(
      color: Colors.white.withOpacity(0.2),
      thickness: 1,
      space: 24,
    ),

    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: primaryLight,
      circularTrackColor: primaryLight.withOpacity(0.2),
      linearTrackColor: primaryLight.withOpacity(0.2),
    ),

    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(borderRadiusSmall),
      ),
      textStyle: const TextStyle(color: textDark),
    ),

    snackBarTheme: SnackBarThemeData(
      backgroundColor: surfaceLight,
      contentTextStyle: const TextStyle(color: textDark),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadiusMedium),
      ),
      behavior: SnackBarBehavior.floating,
      elevation: 6,
    ),
  );
}
