import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// "Wazi" — the app's design language: clean, minimal, trustworthy.
/// One confident brand accent, thin dividers instead of heavy card
/// chrome, generous whitespace.
///
/// The accent pair (navy + gold) is the DukaFlow logo's own palette —
/// `ink`/`indigo` are the logo's navy (same value as the backend's
/// `Merchant::DEFAULT_BRAND_COLOR`, so mobile and the merchant's own
/// portal branding start from the same navy), and `gold` is the logo's
/// gold, reserved for small accents rather than large filled surfaces
/// (navy already carries the primary/interactive role `indigo` had).
class DukaColors {
  static const bg = Color(0xFFF7F8FA);
  static const card = Color(0xFFFFFFFF);
  static const ink = Color(0xFF01162F);
  static const muted = Color(0xFF6B7280);
  static const line = Color(0xFFE9EAEE);
  static const indigo = Color(0xFF01162F);
  static const gold = Color(0xFFC9972E);
  static const rose = Color(0xFFE15252);
}

ThemeData buildDukaTheme() {
  final textTheme = GoogleFonts.karlaTextTheme().copyWith(
    displayLarge:
        GoogleFonts.outfit(fontWeight: FontWeight.w700, color: DukaColors.ink),
    displayMedium:
        GoogleFonts.outfit(fontWeight: FontWeight.w700, color: DukaColors.ink),
    displaySmall:
        GoogleFonts.outfit(fontWeight: FontWeight.w600, color: DukaColors.ink),
    headlineLarge:
        GoogleFonts.outfit(fontWeight: FontWeight.w700, color: DukaColors.ink),
    headlineMedium:
        GoogleFonts.outfit(fontWeight: FontWeight.w700, color: DukaColors.ink),
    headlineSmall:
        GoogleFonts.outfit(fontWeight: FontWeight.w600, color: DukaColors.ink),
    titleLarge:
        GoogleFonts.outfit(fontWeight: FontWeight.w600, color: DukaColors.ink),
    titleMedium:
        GoogleFonts.outfit(fontWeight: FontWeight.w600, color: DukaColors.ink),
    titleSmall:
        GoogleFonts.karla(fontWeight: FontWeight.w700, color: DukaColors.ink),
    bodyLarge: GoogleFonts.karla(color: DukaColors.ink),
    bodyMedium: GoogleFonts.karla(color: DukaColors.ink),
    bodySmall: GoogleFonts.karla(color: DukaColors.muted),
    labelLarge:
        GoogleFonts.karla(fontWeight: FontWeight.w700, color: DukaColors.ink),
  );

  final colorScheme =
      ColorScheme.fromSeed(seedColor: DukaColors.indigo).copyWith(
    primary: DukaColors.indigo,
    onPrimary: Colors.white,
    secondary: DukaColors.indigo,
    onSecondary: Colors.white,
    surface: DukaColors.card,
    onSurface: DukaColors.ink,
    error: DukaColors.rose,
    onError: Colors.white,
  );

  final base = ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: DukaColors.bg,
    textTheme: textTheme,
  );

  return base.copyWith(
    appBarTheme: AppBarTheme(
      backgroundColor: DukaColors.bg,
      foregroundColor: DukaColors.ink,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: GoogleFonts.outfit(
          fontSize: 19, fontWeight: FontWeight.w700, color: DukaColors.ink),
      iconTheme: const IconThemeData(color: DukaColors.ink),
    ),
    cardTheme: CardThemeData(
      color: DukaColors.card,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: DukaColors.line)),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: DukaColors.indigo,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: GoogleFonts.karla(fontWeight: FontWeight.w700, fontSize: 15),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: DukaColors.indigo,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: GoogleFonts.karla(fontWeight: FontWeight.w700, fontSize: 15),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: DukaColors.indigo,
        side: const BorderSide(color: DukaColors.line),
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: DukaColors.indigo,
        textStyle: GoogleFonts.karla(fontWeight: FontWeight.w700),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: DukaColors.indigo,
      foregroundColor: Colors.white,
      elevation: 1,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: DukaColors.line)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: DukaColors.line)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: DukaColors.indigo, width: 1.5)),
      hintStyle: GoogleFonts.karla(color: DukaColors.muted),
      labelStyle: GoogleFonts.karla(color: DukaColors.muted),
    ),
    listTileTheme: ListTileThemeData(
      iconColor: DukaColors.ink,
      titleTextStyle: GoogleFonts.karla(
          fontWeight: FontWeight.w700, fontSize: 14.5, color: DukaColors.ink),
      subtitleTextStyle:
          GoogleFonts.karla(fontSize: 12.5, color: DukaColors.muted),
    ),
    dividerTheme:
        const DividerThemeData(color: DukaColors.line, space: 1, thickness: 1),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colors.white,
      indicatorColor: DukaColors.indigo.withValues(alpha: .10),
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      height: 64,
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => GoogleFonts.karla(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: states.contains(WidgetState.selected)
              ? DukaColors.indigo
              : DukaColors.muted,
        ),
      ),
      iconTheme: WidgetStateProperty.resolveWith(
        (states) => IconThemeData(
          color: states.contains(WidgetState.selected)
              ? DukaColors.indigo
              : DukaColors.muted,
        ),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: DukaColors.ink,
      contentTextStyle: GoogleFonts.karla(color: Colors.white),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      behavior: SnackBarBehavior.floating,
    ),
    chipTheme: base.chipTheme.copyWith(
      backgroundColor: const Color(0xFFF1F2F5),
      labelStyle:
          GoogleFonts.karla(fontWeight: FontWeight.w600, color: DukaColors.ink),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
          side: const BorderSide(color: DukaColors.line)),
      side: const BorderSide(color: DukaColors.line),
    ),
  );
}
