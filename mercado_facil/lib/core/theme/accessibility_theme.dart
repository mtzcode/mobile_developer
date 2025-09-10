import 'package:flutter/material.dart';

/// Tema de acessibilidade com cores otimizadas para alto contraste
class AccessibilityTheme {
  // Cores com alto contraste (WCAG AA compliant)
  static const Color highContrastPrimary = Color(0xFF1A1A1A);
  static const Color highContrastSecondary = Color(0xFF2D2D2D);
  static const Color highContrastSurface = Color(0xFFFFFFFF);
  static const Color highContrastBackground = Color(0xFFF5F5F5);
  static const Color highContrastError = Color(0xFFD32F2F);
  static const Color highContrastSuccess = Color(0xFF2E7D32);
  static const Color highContrastWarning = Color(0xFFF57C00);
  static const Color highContrastInfo = Color(0xFF1976D2);
  
  // Cores de texto com alto contraste
  static const Color highContrastOnPrimary = Color(0xFFFFFFFF);
  static const Color highContrastOnSecondary = Color(0xFFFFFFFF);
  static const Color highContrastOnSurface = Color(0xFF000000);
  static const Color highContrastOnBackground = Color(0xFF000000);
  static const Color highContrastOnError = Color(0xFFFFFFFF);
  static const Color highContrastOnSuccess = Color(0xFFFFFFFF);
  static const Color highContrastOnWarning = Color(0xFFFFFFFF);
  static const Color highContrastOnInfo = Color(0xFFFFFFFF);
  
  // Cores para modo escuro com alto contraste
  static const Color darkHighContrastPrimary = Color(0xFF64B5F6);
  static const Color darkHighContrastSecondary = Color(0xFF81C784);
  static const Color darkHighContrastSurface = Color(0xFF424242);
  static const Color darkHighContrastBackground = Color(0xFF121212);
  static const Color darkHighContrastError = Color(0xFFEF5350);
  static const Color darkHighContrastSuccess = Color(0xFF66BB6A);
  static const Color darkHighContrastWarning = Color(0xFFFFB74D);
  static const Color darkHighContrastInfo = Color(0xFF42A5F5);
  
  // Cores de texto para modo escuro com alto contraste
  static const Color darkHighContrastOnPrimary = Color(0xFF000000);
  static const Color darkHighContrastOnSecondary = Color(0xFF000000);
  static const Color darkHighContrastOnSurface = Color(0xFFFFFFFF);
  static const Color darkHighContrastOnBackground = Color(0xFFFFFFFF);
  static const Color darkHighContrastOnError = Color(0xFF000000);
  static const Color darkHighContrastOnSuccess = Color(0xFF000000);
  static const Color darkHighContrastOnWarning = Color(0xFF000000);
  static const Color darkHighContrastOnInfo = Color(0xFF000000);

  /// Tema claro com alto contraste
  static ThemeData get highContrastLightTheme {
    return ThemeData(
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: highContrastPrimary,
        onPrimary: highContrastOnPrimary,
        secondary: highContrastSecondary,
        onSecondary: highContrastOnSecondary,
        surface: highContrastSurface,
        onSurface: highContrastOnSurface,
        error: highContrastError,
        onError: highContrastOnError,
      ),
      textTheme: _getHighContrastTextTheme(),
      elevatedButtonTheme: _getHighContrastElevatedButtonTheme(),
      outlinedButtonTheme: _getHighContrastOutlinedButtonTheme(),
      textButtonTheme: _getHighContrastTextButtonTheme(),
      inputDecorationTheme: _getHighContrastInputDecorationTheme(),
      cardTheme: _getHighContrastCardTheme(),
      appBarTheme: _getHighContrastAppBarTheme(),
      bottomNavigationBarTheme: _getHighContrastBottomNavigationBarTheme(),
      floatingActionButtonTheme: _getHighContrastFloatingActionButtonTheme(),
      snackBarTheme: _getHighContrastSnackBarTheme(),
      chipTheme: _getHighContrastChipTheme(),
      dividerTheme: _getHighContrastDividerTheme(),
    );
  }

  /// Tema escuro com alto contraste
  static ThemeData get highContrastDarkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: darkHighContrastPrimary,
        onPrimary: darkHighContrastOnPrimary,
        secondary: darkHighContrastSecondary,
        onSecondary: darkHighContrastOnSecondary,
        surface: darkHighContrastSurface,
        onSurface: darkHighContrastOnSurface,
        error: darkHighContrastError,
        onError: darkHighContrastOnError,
      ),
      textTheme: _getDarkHighContrastTextTheme(),
      elevatedButtonTheme: _getDarkHighContrastElevatedButtonTheme(),
      outlinedButtonTheme: _getDarkHighContrastOutlinedButtonTheme(),
      textButtonTheme: _getDarkHighContrastTextButtonTheme(),
      inputDecorationTheme: _getDarkHighContrastInputDecorationTheme(),
      cardTheme: _getDarkHighContrastCardTheme(),
      appBarTheme: _getDarkHighContrastAppBarTheme(),
      bottomNavigationBarTheme: _getDarkHighContrastBottomNavigationBarTheme(),
      floatingActionButtonTheme: _getDarkHighContrastFloatingActionButtonTheme(),
      snackBarTheme: _getDarkHighContrastSnackBarTheme(),
      chipTheme: _getDarkHighContrastChipTheme(),
      dividerTheme: _getDarkHighContrastDividerTheme(),
    );
  }

  /// Texto com alto contraste para tema claro
  static TextTheme _getHighContrastTextTheme() {
    return const TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: highContrastOnSurface,
        letterSpacing: -0.5,
      ),
      displayMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: highContrastOnSurface,
        letterSpacing: -0.5,
      ),
      displaySmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: highContrastOnSurface,
        letterSpacing: -0.25,
      ),
      headlineLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: highContrastOnSurface,
        letterSpacing: -0.25,
      ),
      headlineMedium: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: highContrastOnSurface,
        letterSpacing: -0.15,
      ),
      headlineSmall: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: highContrastOnSurface,
        letterSpacing: -0.15,
      ),
      titleLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: highContrastOnSurface,
        letterSpacing: 0.15,
      ),
      titleMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: highContrastOnSurface,
        letterSpacing: 0.15,
      ),
      titleSmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: highContrastOnSurface,
        letterSpacing: 0.1,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: highContrastOnSurface,
        letterSpacing: 0.5,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: highContrastOnSurface,
        letterSpacing: 0.25,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: highContrastOnSurface,
        letterSpacing: 0.4,
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: highContrastOnSurface,
        letterSpacing: 1.25,
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: highContrastOnSurface,
        letterSpacing: 1.25,
      ),
      labelSmall: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: highContrastOnSurface,
        letterSpacing: 1.5,
      ),
    );
  }

  /// Texto com alto contraste para tema escuro
  static TextTheme _getDarkHighContrastTextTheme() {
    return const TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: darkHighContrastOnSurface,
        letterSpacing: -0.5,
      ),
      displayMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: darkHighContrastOnSurface,
        letterSpacing: -0.5,
      ),
      displaySmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: darkHighContrastOnSurface,
        letterSpacing: -0.25,
      ),
      headlineLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: darkHighContrastOnSurface,
        letterSpacing: -0.25,
      ),
      headlineMedium: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: darkHighContrastOnSurface,
        letterSpacing: -0.15,
      ),
      headlineSmall: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: darkHighContrastOnSurface,
        letterSpacing: -0.15,
      ),
      titleLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: darkHighContrastOnSurface,
        letterSpacing: 0.15,
      ),
      titleMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: darkHighContrastOnSurface,
        letterSpacing: 0.15,
      ),
      titleSmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: darkHighContrastOnSurface,
        letterSpacing: 0.1,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: darkHighContrastOnSurface,
        letterSpacing: 0.5,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: darkHighContrastOnSurface,
        letterSpacing: 0.25,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: darkHighContrastOnSurface,
        letterSpacing: 0.4,
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: darkHighContrastOnSurface,
        letterSpacing: 1.25,
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: darkHighContrastOnSurface,
        letterSpacing: 1.25,
      ),
      labelSmall: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: darkHighContrastOnSurface,
        letterSpacing: 1.5,
      ),
    );
  }

  /// Botão elevado com alto contraste
  static ElevatedButtonThemeData _getHighContrastElevatedButtonTheme() {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: highContrastPrimary,
        foregroundColor: highContrastOnPrimary,
        elevation: 4,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  /// Botão elevado com alto contraste (tema escuro)
  static ElevatedButtonThemeData _getDarkHighContrastElevatedButtonTheme() {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: darkHighContrastPrimary,
        foregroundColor: darkHighContrastOnPrimary,
        elevation: 4,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  /// Botão outline com alto contraste
  static OutlinedButtonThemeData _getHighContrastOutlinedButtonTheme() {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: highContrastPrimary,
        side: const BorderSide(color: highContrastPrimary, width: 2),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  /// Botão outline com alto contraste (tema escuro)
  static OutlinedButtonThemeData _getDarkHighContrastOutlinedButtonTheme() {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: darkHighContrastPrimary,
        side: const BorderSide(color: darkHighContrastPrimary, width: 2),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  /// Botão de texto com alto contraste
  static TextButtonThemeData _getHighContrastTextButtonTheme() {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: highContrastPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  /// Botão de texto com alto contraste (tema escuro)
  static TextButtonThemeData _getDarkHighContrastTextButtonTheme() {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: darkHighContrastPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  /// Decoração de input com alto contraste
  static InputDecorationTheme _getHighContrastInputDecorationTheme() {
    return const InputDecorationTheme(
      border: OutlineInputBorder(
        borderSide: BorderSide(color: highContrastPrimary, width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: highContrastPrimary, width: 2),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: highContrastPrimary, width: 3),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: highContrastError, width: 2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: highContrastError, width: 3),
      ),
      labelStyle: TextStyle(
        color: highContrastPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      hintStyle: TextStyle(
        color: highContrastPrimary,
        fontSize: 16,
        fontWeight: FontWeight.normal,
      ),
      errorStyle: TextStyle(
        color: highContrastError,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  /// Decoração de input com alto contraste (tema escuro)
  static InputDecorationTheme _getDarkHighContrastInputDecorationTheme() {
    return const InputDecorationTheme(
      border: OutlineInputBorder(
        borderSide: BorderSide(color: darkHighContrastPrimary, width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: darkHighContrastPrimary, width: 2),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: darkHighContrastPrimary, width: 3),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: darkHighContrastError, width: 2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: darkHighContrastError, width: 3),
      ),
      labelStyle: TextStyle(
        color: darkHighContrastPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      hintStyle: TextStyle(
        color: darkHighContrastPrimary,
        fontSize: 16,
        fontWeight: FontWeight.normal,
      ),
      errorStyle: TextStyle(
        color: darkHighContrastError,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  /// Card com alto contraste
  static CardThemeData _getHighContrastCardTheme() {
    return CardThemeData(
      color: highContrastSurface,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: highContrastPrimary, width: 1),
      ),
    );
  }

  /// Card com alto contraste (tema escuro)
  static CardThemeData _getDarkHighContrastCardTheme() {
    return CardThemeData(
      color: darkHighContrastSurface,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: darkHighContrastPrimary, width: 1),
      ),
    );
  }

  /// AppBar com alto contraste
  static AppBarTheme _getHighContrastAppBarTheme() {
    return const AppBarTheme(
      backgroundColor: highContrastPrimary,
      foregroundColor: highContrastOnPrimary,
      elevation: 4,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: highContrastOnPrimary,
        letterSpacing: 0.15,
      ),
    );
  }

  /// AppBar com alto contraste (tema escuro)
  static AppBarTheme _getDarkHighContrastAppBarTheme() {
    return const AppBarTheme(
      backgroundColor: darkHighContrastPrimary,
      foregroundColor: darkHighContrastOnPrimary,
      elevation: 4,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: darkHighContrastOnPrimary,
        letterSpacing: 0.15,
      ),
    );
  }

  /// BottomNavigationBar com alto contraste
  static BottomNavigationBarThemeData _getHighContrastBottomNavigationBarTheme() {
    return const BottomNavigationBarThemeData(
      backgroundColor: highContrastSurface,
      selectedItemColor: highContrastPrimary,
      unselectedItemColor: highContrastOnSurface,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    );
  }

  /// BottomNavigationBar com alto contraste (tema escuro)
  static BottomNavigationBarThemeData _getDarkHighContrastBottomNavigationBarTheme() {
    return const BottomNavigationBarThemeData(
      backgroundColor: darkHighContrastSurface,
      selectedItemColor: darkHighContrastPrimary,
      unselectedItemColor: darkHighContrastOnSurface,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    );
  }

  /// FloatingActionButton com alto contraste
  static FloatingActionButtonThemeData _getHighContrastFloatingActionButtonTheme() {
    return const FloatingActionButtonThemeData(
      backgroundColor: highContrastPrimary,
      foregroundColor: highContrastOnPrimary,
      elevation: 6,
    );
  }

  /// FloatingActionButton com alto contraste (tema escuro)
  static FloatingActionButtonThemeData _getDarkHighContrastFloatingActionButtonTheme() {
    return const FloatingActionButtonThemeData(
      backgroundColor: darkHighContrastPrimary,
      foregroundColor: darkHighContrastOnPrimary,
      elevation: 6,
    );
  }

  /// SnackBar com alto contraste
  static SnackBarThemeData _getHighContrastSnackBarTheme() {
    return const SnackBarThemeData(
      backgroundColor: highContrastSurface,
      contentTextStyle: TextStyle(
        color: highContrastOnSurface,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      actionTextColor: highContrastPrimary,
    );
  }

  /// SnackBar com alto contraste (tema escuro)
  static SnackBarThemeData _getDarkHighContrastSnackBarTheme() {
    return const SnackBarThemeData(
      backgroundColor: darkHighContrastSurface,
      contentTextStyle: TextStyle(
        color: darkHighContrastOnSurface,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      actionTextColor: darkHighContrastPrimary,
    );
  }

  /// Chip com alto contraste
  static ChipThemeData _getHighContrastChipTheme() {
    return const ChipThemeData(
      backgroundColor: highContrastSurface,
      selectedColor: highContrastPrimary,
      labelStyle: TextStyle(
        color: highContrastOnSurface,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      secondaryLabelStyle: TextStyle(
        color: highContrastOnPrimary,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  /// Chip com alto contraste (tema escuro)
  static ChipThemeData _getDarkHighContrastChipTheme() {
    return const ChipThemeData(
      backgroundColor: darkHighContrastSurface,
      selectedColor: darkHighContrastPrimary,
      labelStyle: TextStyle(
        color: darkHighContrastOnSurface,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      secondaryLabelStyle: TextStyle(
        color: darkHighContrastOnPrimary,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  /// Divider com alto contraste
  static DividerThemeData _getHighContrastDividerTheme() {
    return const DividerThemeData(
      color: highContrastPrimary,
      thickness: 2,
      space: 1,
    );
  }

  /// Divider com alto contraste (tema escuro)
  static DividerThemeData _getDarkHighContrastDividerTheme() {
    return const DividerThemeData(
      color: darkHighContrastPrimary,
      thickness: 2,
      space: 1,
    );
  }

  /// Verifica se duas cores têm contraste adequado
  static bool hasAdequateContrast(Color foreground, Color background) {
    final luminance1 = foreground.computeLuminance();
    final luminance2 = background.computeLuminance();
    final brightest = luminance1 > luminance2 ? luminance1 : luminance2;
    final darkest = luminance1 > luminance2 ? luminance2 : luminance1;
    final contrast = (brightest + 0.05) / (darkest + 0.05);
    return contrast >= 4.5; // WCAG AA standard
  }

  /// Obtém cor de texto adequada para um fundo
  static Color getAdequateTextColor(Color backgroundColor) {
    const lightText = Color(0xFF000000);
    const darkText = Color(0xFFFFFFFF);
    
    if (hasAdequateContrast(lightText, backgroundColor)) {
      return lightText;
    } else {
      return darkText;
    }
  }
}