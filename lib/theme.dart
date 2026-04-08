import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ThemeConfig {
  // Seed color for ColorScheme.fromSeed. Change this to match your brand.
  static const Color _seedColor = Color(0xFF68658C);

  static ThemeData get lightTheme {
    final cs = ColorScheme.fromSeed(
        seedColor: _seedColor,
        brightness: Brightness.light,
        dynamicSchemeVariant: DynamicSchemeVariant.neutral,
        primary: const Color(0xFF798EAF),
        secondary: const Color(0xFFCBD8E6),
        tertiary: const Color(0xFF506686),
        surface: const Color(0xFFFEF7FF),
        surfaceContainerLowest: const Color(0xFFFFFFFF),
        surfaceContainerLow: const Color(0xFFF7F3FA),
        surfaceContainer: const Color(0xFFF1EDF4),
        surfaceContainerHigh: const Color(0xFFEBE7EF),
        surfaceContainerHighest: const Color(0xFFE5E1E9),
        outlineVariant: const Color(0xFFC5C6D0),
        onSurface: const Color(0xFF1D1B20),
        onPrimary: const Color(0xFFE0E3E9),
        onSecondary: const Color(0xFF506686));
    final textTheme = GoogleFonts.nunitoTextTheme(
      Typography.material2021(platform: TargetPlatform.android).black.apply(
            bodyColor: cs.onSurface,
          ),
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
        elevation: 0,
        centerTitle: false,
        toolbarTextStyle: textTheme.bodyLarge?.copyWith(color: cs.onSurface),
        titleTextStyle: textTheme.titleLarge?.copyWith(
            fontSize: 18, fontWeight: FontWeight.w600, color: cs.onSurface),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: cs.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: cs.outlineVariant.withAlpha(76),
          ),
        ),
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w800,
          color: cs.onSurface,
          letterSpacing: -0.5,
        ),
        contentTextStyle: textTheme.bodyLarge?.copyWith(
          color: cs.onSurfaceVariant,
        ),
        actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      ),
      popupMenuTheme: PopupMenuThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: cs.outlineVariant.withAlpha(51),
            width: 1,
          ),
        ),
        elevation: 0,
        color: cs.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        menuStyle: MenuStyle(
          shape: WidgetStateProperty.all(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          backgroundColor: WidgetStateProperty.all(cs.surface),
          surfaceTintColor: WidgetStateProperty.all(cs.surface),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: cs.primary,
          foregroundColor: cs.onPrimary,
          elevation: 0,
          shadowColor: Colors.transparent,
          minimumSize: const Size(0, 56),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: textTheme.labelLarge
              ?.copyWith(fontWeight: FontWeight.w800, fontSize: 16),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 56),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: cs.primary,
          minimumSize: const Size(0, 56),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: textTheme.labelLarge
              ?.copyWith(fontWeight: FontWeight.w800, fontSize: 16),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: cs.primary,
          minimumSize: const Size(0, 56),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: textTheme.labelLarge
              ?.copyWith(fontWeight: FontWeight.w800, fontSize: 16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        isDense: true,
        filled: true,
        fillColor: cs.surfaceContainerLow.withAlpha(128),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: cs.outlineVariant.withAlpha(128))),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: cs.primary, width: 2.0)),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: cs.error, width: 2.0)),
        focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: cs.error, width: 2.0)),
        hintStyle: TextStyle(color: cs.onSurface.withAlpha(153)),
        labelStyle: TextStyle(color: cs.onSurface.withAlpha(204)),
      ),
      cardTheme: CardThemeData(
        color: cs.surfaceContainerLow.withAlpha(210),
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: cs.outlineVariant.withAlpha(76)),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: cs.surface,
        selectedItemColor: cs.primary,
        unselectedItemColor: cs.onSurface.withAlpha(153),
        showSelectedLabels: true,
        elevation: 8,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: cs.primaryContainer,
        side: BorderSide(
          color: cs.outlineVariant.withAlpha(51),
          width: 1,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        labelStyle: TextStyle(
          fontSize: 12,
          color: cs.onPrimaryContainer,
        ),
        deleteIconColor: cs.onPrimaryContainer,
        iconTheme: IconThemeData(color: cs.onPrimaryContainer, size: 16),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        clipBehavior: Clip.antiAlias,
        backgroundColor: cs.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          side: BorderSide(
            color: cs.outlineVariant.withAlpha(51),
            width: 1,
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: cs.surfaceContainerLow,
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
        primary: const Color(0xFF879BBD),
        secondary: const Color(0xFF587192),
        tertiary: const Color(0xFF6D7F96),
        surface: const Color(0xFF101418),
        surfaceContainerLowest: const Color(0xFF0A0F13),
        surfaceContainerLow: const Color(0xFF181C20),
        surfaceContainer: const Color(0xFF1C2024),
        surfaceContainerHigh: const Color(0xFF262A2F),
        surfaceContainerHighest: const Color(0xFF31353A),
        outlineVariant: const Color(0xFF44474D),
        onSurface: const Color(0xFFE0E3E9),
        onPrimary: const Color(0xFF1D2734),
        onSecondary: const Color(0xFF6D7F96));
    final textTheme = GoogleFonts.nunitoTextTheme(
      Typography.material2021(platform: TargetPlatform.android).white.apply(
            bodyColor: cs.onSurface,
          ),
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
        toolbarTextStyle: textTheme.bodyLarge?.copyWith(color: cs.onSurface),
        titleTextStyle: textTheme.titleLarge?.copyWith(
            fontSize: 18, fontWeight: FontWeight.w600, color: cs.onSurface),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: cs.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: cs.outlineVariant.withAlpha(76),
          ),
        ),
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w800,
          color: cs.onSurface,
          letterSpacing: -0.5,
        ),
        contentTextStyle: textTheme.bodyLarge?.copyWith(
          color: cs.onSurfaceVariant,
        ),
        actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      ),
      popupMenuTheme: PopupMenuThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: cs.outlineVariant.withAlpha(51),
            width: 1,
          ),
        ),
        elevation: 0,
        color: cs.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        menuStyle: MenuStyle(
          shape: WidgetStateProperty.all(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          backgroundColor: WidgetStateProperty.all(cs.surface),
          surfaceTintColor: WidgetStateProperty.all(cs.surface),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: cs.primary,
          foregroundColor: cs.onPrimary,
          elevation: 0,
          shadowColor: Colors.transparent,
          minimumSize: const Size(0, 56),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: textTheme.labelLarge
              ?.copyWith(fontWeight: FontWeight.w800, fontSize: 16),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 56),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: cs.primary,
          minimumSize: const Size(0, 56),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: textTheme.labelLarge
              ?.copyWith(fontWeight: FontWeight.w800, fontSize: 16),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: cs.primary,
          minimumSize: const Size(0, 56),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: textTheme.labelLarge
              ?.copyWith(fontWeight: FontWeight.w800, fontSize: 16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        isDense: true,
        filled: true,
        fillColor: cs.surfaceContainerLow.withAlpha(128),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: cs.outlineVariant.withAlpha(128))),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: cs.primary, width: 2.0)),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: cs.error, width: 2.0)),
        focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: cs.error, width: 2.0)),
        hintStyle: TextStyle(color: cs.onSurface.withAlpha(153)),
        labelStyle: TextStyle(color: cs.onSurface.withAlpha(204)),
      ),
      cardTheme: CardThemeData(
        color: cs.secondaryContainer.withAlpha(90),
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: cs.outlineVariant.withAlpha(76)),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: cs.surface,
        selectedItemColor: cs.primary,
        unselectedItemColor: cs.onSurface.withAlpha(153),
        showSelectedLabels: true,
        elevation: 8,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: cs.primaryContainer,
        side: BorderSide(
          color: cs.outlineVariant.withAlpha(51),
          width: 1,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        labelStyle: TextStyle(
          fontSize: 12,
          color: cs.onPrimaryContainer,
        ),
        deleteIconColor: cs.onPrimaryContainer,
        iconTheme: IconThemeData(color: cs.onPrimaryContainer, size: 16),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        clipBehavior: Clip.antiAlias,
        backgroundColor: cs.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          side: BorderSide(
            color: cs.outlineVariant.withAlpha(51),
            width: 1,
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: cs.surfaceContainerLow,
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
