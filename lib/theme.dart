import 'package:flutter/material.dart';

class ThemeConfig {
  // Seed color for ColorScheme.fromSeed. Change this to match your brand.
  static const Color _seedColor = Color.fromARGB(255, 104, 101, 140);

  static ThemeData get lightTheme {
    final cs = ColorScheme.fromSeed(
        seedColor: _seedColor,
        brightness: Brightness.light,
        dynamicSchemeVariant: DynamicSchemeVariant.neutral,
        primary: const Color.fromARGB(255, 121, 142, 175),
        onPrimary: const Color.fromARGB(255, 224, 227, 233),
        secondary: const Color.fromARGB(255, 203, 216, 230),
        onSecondary: const Color.fromARGB(255, 80, 102, 134));
    final textTheme =
        Typography.material2021(platform: TargetPlatform.android).black.apply(
              bodyColor: cs.onSurface,
            );

    return ThemeData(
      useMaterial3: true,
      colorScheme: cs,
      splashColor: Colors.transparent,
      // prefer surface for background per latest SDK guidance
      scaffoldBackgroundColor: cs.surface,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        surfaceTintColor: cs.surface,
        backgroundColor: cs.surface,
        foregroundColor: cs.onSurface,
        elevation: 8,
        centerTitle: false,
        titleTextStyle: TextStyle(
            fontSize: 18, fontWeight: FontWeight.w600, color: cs.onSurface),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: cs.primary,
          foregroundColor: cs.onPrimary,
          elevation: 2,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: cs.primary,
          side: BorderSide(color: cs.primary.withAlpha(31)),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 18),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: cs.primary),
      ),
      inputDecorationTheme: InputDecorationTheme(
        isDense: true,
        filled: true,
        fillColor: cs.surface,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: cs.secondary.withAlpha(175))),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: cs.secondary, width: 1.5)),
        hintStyle: TextStyle(color: cs.onSurface.withAlpha(153)),
        labelStyle: TextStyle(color: cs.onSurface.withAlpha(204)),
      ),
      // Card theme kept minimal; cards inherit surface color and elevation from Material defaults
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: cs.surface,
        selectedItemColor: cs.primary,
        unselectedItemColor: cs.onSurface.withAlpha(153),
        showSelectedLabels: true,
        elevation: 8,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: cs.surfaceContainerHighest,
        contentTextStyle: TextStyle(color: cs.onSurface),
        behavior: SnackBarBehavior.floating,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.all(cs.primary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.all(cs.primary),
        trackColor: WidgetStateProperty.resolveWith(
            (states) => cs.primary.withAlpha(102)),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }

  static ThemeData get darkTheme {
    final cs = ColorScheme.fromSeed(
        seedColor: _seedColor,
        brightness: Brightness.dark,
        dynamicSchemeVariant: DynamicSchemeVariant.neutral,
        primary: const Color.fromARGB(255, 109, 125, 152),
        onPrimary: const Color.fromARGB(255, 29, 39, 52),
        secondary: const Color.fromARGB(255, 77, 92, 111),
        onSecondary: const Color.fromARGB(255, 95, 111, 132));
    final textTheme =
        Typography.material2021(platform: TargetPlatform.android).white.apply(
              bodyColor: cs.onSurface,
            );

    return ThemeData(
      useMaterial3: true,
      colorScheme: cs,
      splashColor: Colors.transparent,
      scaffoldBackgroundColor: cs.surface,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        surfaceTintColor: cs.surface,
        backgroundColor: cs.surface,
        foregroundColor: cs.onSurface,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
            fontSize: 18, fontWeight: FontWeight.w600, color: cs.onSurface),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: cs.primary,
          foregroundColor: cs.onPrimary,
          elevation: 2,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: cs.primary,
          side: BorderSide(color: cs.onSurface.withAlpha(31)),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 18),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        isDense: true,
        filled: true,
        fillColor: cs.surface,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: cs.secondary.withAlpha(175))),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: cs.secondary, width: 1.5)),
        hintStyle: TextStyle(color: cs.onSurface.withAlpha(153)),
        labelStyle: TextStyle(color: cs.onSurface.withAlpha(204)),
      ),
      // Card theme kept minimal; cards inherit surface color and elevation from Material defaults
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: cs.surface,
        selectedItemColor: cs.primary,
        unselectedItemColor: cs.onSurface.withAlpha(153),
        showSelectedLabels: true,
        elevation: 8,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: cs.surfaceContainerHighest,
        contentTextStyle: TextStyle(color: cs.onSurface),
        behavior: SnackBarBehavior.floating,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.all(cs.primary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.all(cs.primary),
        trackColor: WidgetStateProperty.resolveWith(
            (states) => cs.primary.withAlpha(102)),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }
}
