import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// A class that contains all theme configurations for the cryptocurrency application.
class AppTheme {
  AppTheme._();
// static const Color accentTeal = Color(0xFF3c065e); // Main accent - Modern purple


  // Dark theme colors
  // static const Color primaryDark = Color(0xFF1A1B23); // Deep background
  // static const Color secondaryDark = Color(0xFF2A2D3A); // Card surfaces
  // // static const Color accentTeal = Color(0xFF00D4AA); // Trust-building teal
  // static const Color accentTeal = Color(0xFF455bff); // Trust-building teal
  // static const Color warningOrange = Color(0xFFFF6B35); // Alert color
  // static const Color successGreen = Color(0xFF00C896); // Success indicators
  // static const Color textPrimary = Color(0xFFFFFFFF); // High contrast text
  // static const Color textSecondary = Color(0xFFB8BCC8); // Supporting text
  // static const Color borderSubtle = Color(0xFF3A3D4A); // Minimal borders
  // static const Color surfaceElevated = Color(0xFF252831); // Modal backgrounds
  // static const Color errorRed = Color(0xFFFF6B6B); // Error states
  // static const Color shadowColor = Color(0x1A000000); // Subtle light shadow
  // static const Color elevatedShadowColor = Color(0x1A000000);
  // static const Color green = Color(0xFF068C06); // Fresh success green


  // light theme colors
  // static const Color primaryDark = Color(0xFFFAFAFB); // Clean light background
  static const Color primaryDark = Color(0xFFFFFCF2); // Clean light background
  static const Color secondaryDark = Color(0xFFFFFFFF); // Pure white card surfaces
  static const Color accentTeal = Color(0xFF455bff); // Main accent - Modern blue
  static const Color accentSecondry = Color(0xFFdde8ff);
  static const Color accentTherd = Color(0xFFecf3ff);
  static const Color warningOrange = Color(0xFFFF6B35); // Warm gold for warnings
  static const Color successGreen = Color(0xFF00C896); // Fresh success green
  static const Color green = Color(0xFF068C06); // Fresh success green
  static const Color textPrimary = Color(0xFF111827); // Dark text for contrast
  static const Color textSecondary = Color(0xFF6B7280); // Medium gray supporting text
  static const Color borderSubtle = Color(0xFFD6D8DC); // Light gray borders
  static const Color hintTextColor = Color(0xFFC9CACD);
  static const Color surfaceElevated = Color(0xFFFFFFFF); // White elevated surfaces
  static const Color errorRed = Color(0xFFEF4444); // Clean error red
  static const Color shadowColor = Color(0x1A000000); // Subtle light shadow
  static const Color elevatedShadowColor = Color(0x1A000000);
  static const Color black = Color(0xFF000000);

  // static const Color borderSubtle = Color(0xFFE5E7EB); // Light gray borders
  // Brand gradient colors
  static const LinearGradient brandGradient = LinearGradient(
    colors: [accentTeal, accentTeal],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Dark theme optimized for cryptocurrency applications
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    colorScheme: ColorScheme(
      brightness: Brightness.dark,
      primary: accentTeal,
      onPrimary: primaryDark,
      primaryContainer: accentTeal.withAlpha(51),
      onPrimaryContainer: textPrimary,
      secondary: successGreen,
      onSecondary: primaryDark,
      secondaryContainer: successGreen.withAlpha(51),
      onSecondaryContainer: textPrimary,
      tertiary: warningOrange,
      onTertiary: textPrimary,
      tertiaryContainer: warningOrange.withAlpha(51),
      onTertiaryContainer: textPrimary,
      error: errorRed,
      onError: textPrimary,
      surface: primaryDark,
      onSurface: textPrimary,
      onSurfaceVariant: textSecondary,
      outline: borderSubtle,
      outlineVariant: borderSubtle.withAlpha(128),
      shadow: shadowColor,
      scrim: primaryDark.withAlpha(204),
      inverseSurface: textPrimary,
      onInverseSurface: primaryDark,
      inversePrimary: accentTeal,
    ),
    scaffoldBackgroundColor: primaryDark,
    cardColor: secondaryDark,
    dividerColor: borderSubtle,

    // AppBar theme for secure, professional appearance
    appBarTheme: AppBarTheme(
      backgroundColor: primaryDark,
      foregroundColor: textPrimary,
      elevation: 0,
      shadowColor: elevatedShadowColor,
      titleTextStyle: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        letterSpacing: 0.15,
      ),
      iconTheme: const IconThemeData(
        color: textPrimary,
        size: 24,
      ),
      actionsIconTheme: const IconThemeData(
        color: textPrimary,
        size: 24,
      ),
    ),

    // Card theme with subtle elevation
    cardTheme: CardThemeData(
      color: secondaryDark,
      elevation: 2.0,
      shadowColor: elevatedShadowColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),

    // Bottom navigation optimized for crypto operations
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: surfaceElevated,
      selectedItemColor: accentTeal,
      unselectedItemColor: textSecondary,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
      selectedLabelStyle: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      unselectedLabelStyle: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
      ),
    ),

    // Floating action button for primary crypto actions
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: accentTeal,
      foregroundColor: primaryDark,
      elevation: 4,
      focusElevation: 6,
      hoverElevation: 6,
      highlightElevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),

    // Button themes for financial operations
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: primaryDark,
        backgroundColor: accentTeal,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        elevation: 2,
        shadowColor: elevatedShadowColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        textStyle: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: accentTeal,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        side: const BorderSide(color: accentTeal, width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        textStyle: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
        ),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: accentTeal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        textStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.25,
        ),
      ),
    ),

    // Typography optimized for financial data
    textTheme: _buildCryptoTextTheme(),

    // Input decoration for secure form fields
    inputDecorationTheme: InputDecorationTheme(
      fillColor: secondaryDark,
      filled: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(color: borderSubtle, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(color: borderSubtle, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(color: accentTeal, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(color: errorRed, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(color: errorRed, width: 2),
      ),
      labelStyle: GoogleFonts.inter(
        color: textSecondary,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      hintStyle: GoogleFonts.inter(
        color: textSecondary.withAlpha(179),
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      prefixIconColor: textSecondary,
      suffixIconColor: textSecondary,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),

    // Switch theme for settings
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return accentTeal;
        }
        return textSecondary;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return accentTeal.withAlpha(77);
        }
        return borderSubtle;
      }),
    ),

    // Checkbox theme
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return accentTeal;
        }
        return Colors.transparent;
      }),
      checkColor: WidgetStateProperty.all(primaryDark),
      side: const BorderSide(color: borderSubtle, width: 2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
    ),

    // Radio theme
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return accentTeal;
        }
        return borderSubtle;
      }),
    ),

    // Progress indicator for blockchain operations
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: accentTeal,
      linearTrackColor: borderSubtle,
      circularTrackColor: borderSubtle,
    ),

    // Slider theme
    sliderTheme: SliderThemeData(
      activeTrackColor: accentTeal,
      thumbColor: accentTeal,
      overlayColor: accentTeal.withAlpha(51),
      inactiveTrackColor: borderSubtle,
      valueIndicatorColor: accentTeal,
      valueIndicatorTextStyle: GoogleFonts.inter(
        color: primaryDark,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
    ),

    // Tab bar theme
    tabBarTheme: TabBarThemeData(
      labelColor: accentTeal,
      unselectedLabelColor: textSecondary,
      indicatorColor: accentTeal,
      indicatorSize: TabBarIndicatorSize.label,
      labelStyle: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
      unselectedLabelStyle: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
      ),
    ),

    // Tooltip theme
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: surfaceElevated,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      textStyle: GoogleFonts.inter(
        color: textPrimary,
        fontSize: 12,
        fontWeight: FontWeight.w400,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    ),

    // Snackbar theme for notifications
    snackBarTheme: SnackBarThemeData(
      backgroundColor: surfaceElevated,
      contentTextStyle: GoogleFonts.inter(
        color: textPrimary,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      actionTextColor: accentTeal,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      elevation: 4,
    ),

    // Dialog theme
    dialogTheme: DialogThemeData(
      backgroundColor: surfaceElevated,
      elevation: 8,
      shadowColor: shadowColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      titleTextStyle: GoogleFonts.inter(
        color: textPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.15,
      ),
      contentTextStyle: GoogleFonts.inter(
        color: textSecondary,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
      ),
    ),

    // Bottom sheet theme
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: surfaceElevated,
      elevation: 8,
      shadowColor: shadowColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
    ),

    // List tile theme
    listTileTheme: ListTileThemeData(
      tileColor: Colors.transparent,
      selectedTileColor: accentTeal.withAlpha(26),
      iconColor: textSecondary,
      textColor: textPrimary,
      selectedColor: accentTeal,
      titleTextStyle: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: textPrimary,
        letterSpacing: 0.15,
      ),
      subtitleTextStyle: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: textSecondary,
        letterSpacing: 0.25,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),
  );

  /// Light theme (minimal implementation for contrast)
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    colorScheme: ColorScheme(
      brightness: Brightness.light,
      primary: accentTeal,
      onPrimary: Colors.white,
      primaryContainer: accentTeal.withAlpha(26),
      onPrimaryContainer: primaryDark,
      secondary: successGreen,
      onSecondary: Colors.white,
      secondaryContainer: successGreen.withAlpha(26),
      onSecondaryContainer: primaryDark,
      tertiary: warningOrange,
      onTertiary: Colors.white,
      tertiaryContainer: warningOrange.withAlpha(26),
      onTertiaryContainer: primaryDark,
      error: errorRed,
      onError: Colors.white,
      surface: Colors.white,
      onSurface: primaryDark,
      onSurfaceVariant: const Color(0xFF6B7280),
      outline: const Color(0xFFE5E7EB),
      outlineVariant: const Color(0xFFF3F4F6),
      shadow: const Color(0x1A000000),
      scrim: primaryDark.withAlpha(128),
      inverseSurface: primaryDark,
      onInverseSurface: Colors.white,
      inversePrimary: accentTeal,
    ),
    scaffoldBackgroundColor: Colors.white,
    textTheme: _buildCryptoTextTheme(isLight: true),
  );

  /// Helper method to build cryptocurrency-optimized text theme
  static TextTheme _buildCryptoTextTheme({bool isLight = false}) {
    final Color primaryTextColor = isLight ? primaryDark : textPrimary;
    final Color secondaryTextColor =
        isLight ? const Color(0xFF6B7280) : textSecondary;

    return TextTheme(
      // Display styles for large headings
      displayLarge: GoogleFonts.inter(
        fontSize: 57,
        fontWeight: FontWeight.w700,
        color: primaryTextColor,
        letterSpacing: -0.25,
        height: 1.12,
      ),
      displayMedium: GoogleFonts.inter(
        fontSize: 45,
        fontWeight: FontWeight.w600,
        color: primaryTextColor,
        letterSpacing: 0,
        height: 1.16,
      ),
      displaySmall: GoogleFonts.inter(
        fontSize: 36,
        fontWeight: FontWeight.w600,
        color: primaryTextColor,
        letterSpacing: 0,
        height: 1.22,
      ),

      // Headline styles for section headers
      headlineLarge: GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.w600,
        color: primaryTextColor,
        letterSpacing: 0,
        height: 1.25,
      ),
      headlineMedium: GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: primaryTextColor,
        letterSpacing: 0,
        height: 1.29,
      ),
      headlineSmall: GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w500,
        color: primaryTextColor,
        letterSpacing: 0,
        height: 1.33,
      ),

      // Title styles for cards and components
      titleLarge: GoogleFonts.inter(
        fontSize: 22,
        fontWeight: FontWeight.w500,
        color: primaryTextColor,
        letterSpacing: 0,
        height: 1.27,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: primaryTextColor,
        letterSpacing: 0.15,
        height: 1.50,
      ),
      titleSmall: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: primaryTextColor,
        letterSpacing: 0.1,
        height: 1.43,
      ),

      // Body styles for main content
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: primaryTextColor,
        letterSpacing: 0.5,
        height: 1.50,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: primaryTextColor,
        letterSpacing: 0.25,
        height: 1.43,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: secondaryTextColor,
        letterSpacing: 0.4,
        height: 1.33,
      ),

      // Label styles for buttons and small text
      labelLarge: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: primaryTextColor,
        letterSpacing: 0.1,
        height: 1.43,
      ),
      labelMedium: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: primaryTextColor,
        letterSpacing: 0.5,
        height: 1.33,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: secondaryTextColor,
        letterSpacing: 0.5,
        height: 1.45,
      ),
    );
  }

  /// Monospace text style for cryptocurrency addresses and data
  static TextStyle monoTextStyle({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w400,
    Color? color,
    bool isLight = false,
  }) {
    return GoogleFonts.jetBrainsMono(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color ?? (isLight ? primaryDark : textPrimary),
      letterSpacing: 0.25,
      height: 1.4,
    );
  }

  /// Custom box shadow for elevated surfaces
  static List<BoxShadow> get elevatedShadow => [
        BoxShadow(
          color: shadowColor,
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ];

  /// Custom box shadow for floating elements
  static List<BoxShadow> get floatingShadow => [
        BoxShadow(
          color: shadowColor,
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ];

  /// Glassmorphism effect for special components
  static BoxDecoration get glassmorphismDecoration => BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: borderSubtle.withAlpha(51),
          width: 1,
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            surfaceElevated.withAlpha(204),
            secondaryDark.withAlpha(153),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      );
}
