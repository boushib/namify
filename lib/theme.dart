import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Violet and honey on warm cream (light) or deep plum (dark)
const brand = Color(0xFF6C4CF5);
const honey = Color(0xFFFFB547);
const plum = Color(0xFF15121F);
const plumSurface = Color(0xFF211C30);
const cream = Color(0xFFFFF8F0);

/// Big, friendly lettering for the names themselves
TextStyle nameStyle(BuildContext context, {double size = 44}) => GoogleFonts.fredoka(fontSize: size, fontWeight: FontWeight.w600, height: 1.05, color: Theme.of(context).colorScheme.onSurface);

ThemeData buildTheme(Brightness brightness) {
  final dark = brightness == Brightness.dark;
  final scheme = ColorScheme.fromSeed(
    seedColor: brand,
    brightness: brightness,
    primary: dark ? const Color(0xFF9D86FF) : brand,
    onPrimary: Colors.white,
    secondary: honey,
    onSecondary: const Color(0xFF2B1D00),
    surface: dark ? plum : cream,
    onSurface: dark ? const Color(0xFFF2EEFF) : const Color(0xFF1F1B2E),
    surfaceContainerLow: dark ? plumSurface : Colors.white,
    surfaceContainer: dark ? const Color(0xFF2A2440) : const Color(0xFFF6EEFF),
    surfaceContainerHighest: dark ? const Color(0xFF342D4D) : const Color(0xFFECE3FF),
  );
  final text = GoogleFonts.nunitoTextTheme(ThemeData(brightness: brightness).textTheme).apply(bodyColor: scheme.onSurface, displayColor: scheme.onSurface);

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: scheme.surface,
    textTheme: text.copyWith(
      headlineMedium: GoogleFonts.fredoka(fontSize: 30, fontWeight: FontWeight.w600, color: scheme.onSurface),
      titleLarge: GoogleFonts.fredoka(fontSize: 22, fontWeight: FontWeight.w600, color: scheme.onSurface),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.surface,
      foregroundColor: scheme.onSurface,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: GoogleFonts.fredoka(fontSize: 26, fontWeight: FontWeight.w600, color: scheme.onSurface),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: scheme.surfaceContainerLow,
      indicatorColor: scheme.primary.withValues(alpha: .16),
      labelTextStyle: WidgetStatePropertyAll(GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w700)),
    ),
    navigationRailTheme: NavigationRailThemeData(backgroundColor: scheme.surfaceContainerLow, indicatorColor: scheme.primary.withValues(alpha: .16)),
    cardTheme: CardThemeData(
      color: scheme.surfaceContainerLow,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(color: scheme.outlineVariant.withValues(alpha: .5)),
      ),
    ),
    chipTheme: ChipThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      side: BorderSide(color: scheme.outlineVariant.withValues(alpha: .7)),
      backgroundColor: scheme.surfaceContainerLow,
      selectedColor: scheme.primary.withValues(alpha: .14),
      checkmarkColor: scheme.primary,
      labelStyle: GoogleFonts.nunito(fontWeight: FontWeight.w700, color: scheme.onSurface),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(0, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w800),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w800),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: scheme.surfaceContainerLow,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: scheme.outlineVariant),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: scheme.outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: scheme.primary, width: 2),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
  );
}
