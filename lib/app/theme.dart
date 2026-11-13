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
  /// Set by the app root from the user's light/dark choice, before the
  /// tree rebuilds; every neutral below follows it.
  static bool dark = false;

  static Color get bg =>
      dark ? const Color(0xFF130B0D) : const Color(0xFFF7F8F3);
  static Color get card =>
      dark ? const Color(0xFF1F1416) : const Color(0xFFFFFFFF);

  /// A slightly raised surface: search pills, photo backgrounds.
  static Color get soft =>
      dark ? const Color(0xFF2A1D20) : const Color(0xFFF4F4EF);
  static Color get ink =>
      dark ? const Color(0xFFF4EDEE) : const Color(0xFF231416);
  static Color get muted =>
      dark ? const Color(0xFFB9A9AB) : const Color(0xFF6D5C5E);
  static Color get line =>
      dark ? const Color(0xFF3A2C2F) : const Color(0xFFE7E6DF);

  /// Maroon, the primary colour: a lighter shade on dark ground so text
  /// and icons in it stay readable.
  static Color get indigo =>
      dark ? const Color(0xFFD25B69) : const Color(0xFF881824);
  static const gold = Color(0xFF82C247);
  static const rose = Color(0xFFD92D20);

  /// Logo green on its own, and a darker green for text on light ground.
  static const leaf = Color(0xFF82C247);
  static Color get leafDeep =>
      dark ? const Color(0xFF9BD468) : const Color(0xFF3F7D1C);

  /// Deep maroon for dark bands (header, AI band), and the pale tints.
  static const brandDark = Color(0xFF2A0A0F);
  static Color get maroonTint =>
      dark ? const Color(0xFF3B1A20) : const Color(0xFFF6E4E6);
  static Color get leafTint =>
      dark ? const Color(0xFF223318) : const Color(0xFFE6F3D6);

  /// The brand maroon itself, fixed in both modes (logo, splash).
  static const maroon = Color(0xFF881824);
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
  Color? primary,
  Color onPrimary = Colors.white,
  Color? accent,
  Color onAccent = Colors.white,
}) {
  primary ??= DukaColors.indigo;
  accent ??= DukaColors.indigo;
  final brightness = DukaColors.dark ? Brightness.dark : Brightness.light;
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

  final colorScheme =
      ColorScheme.fromSeed(seedColor: primary, brightness: brightness).copyWith(
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
    brightness: brightness,
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
      iconTheme: IconThemeData(color: DukaColors.ink),
    ),
    cardTheme: CardThemeData(
      color: DukaColors.card,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: DukaColors.line),
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
        side: BorderSide(color: DukaColors.line),
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
      fillColor: DukaColors.card,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: DukaColors.line),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: DukaColors.line),
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
    dividerTheme: DividerThemeData(
      color: DukaColors.line,
      space: 1,
      thickness: 1,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: DukaColors.card,
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
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: DukaColors.card,
      surfaceTintColor: Colors.transparent,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: DukaColors.card,
      surfaceTintColor: Colors.transparent,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: DukaColors.dark
          ? const Color(0xFF3A2C2F)
          : const Color(0xFF231416),
      contentTextStyle: GoogleFonts.inter(color: Colors.white),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      behavior: SnackBarBehavior.floating,
    ),
    chipTheme: base.chipTheme.copyWith(
      backgroundColor: DukaColors.card,
      selectedColor: DukaColors.maroonTint,
      checkmarkColor: primary,
      labelStyle: GoogleFonts.inter(
        fontWeight: FontWeight.w600,
        color: DukaColors.ink,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(999),
        side: BorderSide(color: DukaColors.line),
      ),
      side: BorderSide(color: DukaColors.line),
    ),
  );
}
