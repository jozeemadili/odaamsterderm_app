import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// "Wazi": the app's design language, clean, minimal, trustworthy.
/// One confident brand accent, thin dividers instead of heavy card
/// chrome, generous whitespace.
///
/// Colours come from the Amsterdam Group logo, the same palette as the
/// website: maroon (`indigo`, the primary/interactive colour, kept under
/// its old name so every screen follows) and green (`gold`/`leaf`, the
/// accent for highlights and good news), with a warm near-black for text.
class DukaColors {
  static const bg = Color(0xFFF7F8F3);
  static const card = Color(0xFFFFFFFF);
  static const ink = Color(0xFF231416);
  static const muted = Color(0xFF6D5C5E);
  static const line = Color(0xFFE7E6DF);
  static const indigo = Color(0xFF881824);
  static const gold = Color(0xFF82C247);
  static const rose = Color(0xFFD92D20);

  /// Logo green on its own, and a darker green for text on light ground.
  static const leaf = Color(0xFF82C247);
  static const leafDeep = Color(0xFF3F7D1C);

  /// Deep maroon for dark bands (header, AI band), and a pale maroon tint.
  static const brandDark = Color(0xFF2A0A0F);
  static const maroonTint = Color(0xFFF6E4E6);
  static const leafTint = Color(0xFFE6F3D6);
}

/// "#14532D" → Color; null when the value isn't a 6-digit hex colour.
Color? colorFromHex(String? hex) {
  final value = hex?.replaceFirst('#', '');
  if (value == null || value.length != 6) return null;
  final parsed = int.tryParse(value, radix: 16);
  return parsed == null ? null : Color(0xFF000000 | parsed);
}

/// The app theme. Sellers get their own brand colours ([primary] main,
/// [accent] highlights); everyone else gets Amsterdam Digital's.
ThemeData buildDukaTheme({
  Color primary = DukaColors.indigo,
  Color onPrimary = Colors.white,
  Color accent = DukaColors.indigo,
  Color onAccent = Colors.white,
}) {
  final textTheme = GoogleFonts.interTextTheme().copyWith(
    displayLarge: GoogleFonts.montserrat(
      fontWeight: FontWeight.w700,
      color: DukaColors.ink,
    ),
    displayMedium: GoogleFonts.montserrat(
      fontWeight: FontWeight.w700,
      color: DukaColors.ink,
    ),
    displaySmall: GoogleFonts.montserrat(
      fontWeight: FontWeight.w600,
      color: DukaColors.ink,
    ),
    headlineLarge: GoogleFonts.montserrat(
      fontWeight: FontWeight.w700,
      color: DukaColors.ink,
    ),
    headlineMedium: GoogleFonts.montserrat(
      fontWeight: FontWeight.w700,
      color: DukaColors.ink,
    ),
    headlineSmall: GoogleFonts.montserrat(
      fontWeight: FontWeight.w600,
      color: DukaColors.ink,
    ),
    titleLarge: GoogleFonts.montserrat(
      fontWeight: FontWeight.w600,
      color: DukaColors.ink,
    ),
    titleMedium: GoogleFonts.montserrat(
      fontWeight: FontWeight.w600,
      color: DukaColors.ink,
    ),
    titleSmall: GoogleFonts.inter(
      fontWeight: FontWeight.w700,
      color: DukaColors.ink,
    ),
    bodyLarge: GoogleFonts.inter(color: DukaColors.ink),
    bodyMedium: GoogleFonts.inter(color: DukaColors.ink),
    bodySmall: GoogleFonts.inter(color: DukaColors.muted),
    labelLarge: GoogleFonts.inter(
      fontWeight: FontWeight.w700,
      color: DukaColors.ink,
    ),
  );

  final colorScheme = ColorScheme.fromSeed(seedColor: primary).copyWith(
    primary: primary,
    onPrimary: onPrimary,
    secondary: accent,
    onSecondary: onAccent,
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
      titleTextStyle: GoogleFonts.montserrat(
        fontSize: 19,
        fontWeight: FontWeight.w700,
        color: DukaColors.ink,
      ),
      iconTheme: const IconThemeData(color: DukaColors.ink),
    ),
    cardTheme: CardThemeData(
      color: DukaColors.card,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: DukaColors.line),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: onPrimary,
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        shape: const StadiumBorder(),
        textStyle: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 15),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: onPrimary,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 15),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primary,
        side: const BorderSide(color: DukaColors.line),
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primary,
        textStyle: GoogleFonts.inter(fontWeight: FontWeight.w700),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: accent,
      foregroundColor: onAccent,
      elevation: 1,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: DukaColors.line),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: DukaColors.line),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: primary, width: 1.5),
      ),
      hintStyle: GoogleFonts.inter(color: DukaColors.muted),
      labelStyle: GoogleFonts.inter(color: DukaColors.muted),
    ),
    listTileTheme: ListTileThemeData(
      iconColor: DukaColors.ink,
      titleTextStyle: GoogleFonts.inter(
        fontWeight: FontWeight.w700,
        fontSize: 14.5,
        color: DukaColors.ink,
      ),
      subtitleTextStyle: GoogleFonts.inter(
        fontSize: 12.5,
        color: DukaColors.muted,
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: DukaColors.line,
      space: 1,
      thickness: 1,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colors.white,
      indicatorColor: accent.withValues(alpha: .28),
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      height: 64,
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: states.contains(WidgetState.selected)
              ? primary
              : DukaColors.muted,
        ),
      ),
      iconTheme: WidgetStateProperty.resolveWith(
        (states) => IconThemeData(
          color: states.contains(WidgetState.selected)
              ? primary
              : DukaColors.muted,
        ),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: DukaColors.ink,
      contentTextStyle: GoogleFonts.inter(color: Colors.white),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      behavior: SnackBarBehavior.floating,
    ),
    chipTheme: base.chipTheme.copyWith(
      backgroundColor: Colors.white,
      selectedColor: DukaColors.maroonTint,
      checkmarkColor: primary,
      labelStyle: GoogleFonts.inter(
        fontWeight: FontWeight.w600,
        color: DukaColors.ink,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(999),
        side: const BorderSide(color: DukaColors.line),
      ),
      side: const BorderSide(color: DukaColors.line),
    ),
  );
}
