import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ── Brand Colors ──────────────────────────────────────────────────────
const Color kGreen      = Color(0xFF1B6B2A);
const Color kGreenLight = Color(0xFF2E9944);
const Color kGreenPale  = Color(0xFFE8F5EB);
const Color kGreenDark  = Color(0xFF0D4018);
const Color kOrange     = Color(0xFFE65100);
const Color kRed        = Color(0xFFC62828);
const Color kBlue       = Color(0xFF1565C0);
const Color kPurple     = Color(0xFF6A1B9A);
const Color kAmber      = Color(0xFFF57F17);

// Light palette
const Color kBg       = Color(0xFFF4F8F4);
const Color kCard     = Color(0xFFFFFFFF);
const Color kBorder   = Color(0xFFD6E8D8);
const Color kInputBg  = Color(0xFFF0F7F1);
const Color kText     = Color(0xFF111811);
const Color kTextSec  = Color(0xFF4A6A4C);
const Color kTextMuted= Color(0xFF8AA88C);
const Color kTextHint = Color(0xFFB0C8B2);

ThemeData buildAppTheme()  => _build(Brightness.light);
ThemeData buildDarkTheme() => _build(Brightness.dark);

ThemeData _build(Brightness b) {
  final dark = b == Brightness.dark;
  final bg       = dark ? const Color(0xFF0F1F11) : kBg;
  final card     = dark ? const Color(0xFF1A2E1C) : kCard;
  final border   = dark ? const Color(0xFF2A4A2D) : kBorder;
  final inputBg  = dark ? const Color(0xFF152017) : kInputBg;
  final text     = dark ? const Color(0xFFE8F5EA) : kText;
  final textSec  = dark ? const Color(0xFF9EC4A2) : kTextSec;
  final textMuted= dark ? const Color(0xFF5A7A5D) : kTextMuted;
  final textHint = dark ? const Color(0xFF3A5A3D) : kTextHint;

  return ThemeData(
    useMaterial3: true,
    brightness: b,
    colorScheme: ColorScheme.fromSeed(
      seedColor: kGreen,
      brightness: b,
      primary: kGreen,
      secondary: kGreenLight,
      surface: card,
      background: bg,
      error: kRed,
    ),
    scaffoldBackgroundColor: bg,
    textTheme: GoogleFonts.plusJakartaSansTextTheme(
      dark ? ThemeData.dark().textTheme : ThemeData.light().textTheme,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: card,
      foregroundColor: text,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: GoogleFonts.plusJakartaSans(
        fontSize: 18, fontWeight: FontWeight.w700, color: text),
      iconTheme: IconThemeData(color: text),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: kGreen, foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w700),
        elevation: 0,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: kGreen,
        minimumSize: const Size(double.infinity, 52),
        side: const BorderSide(color: kGreen, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: inputBg,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: border)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: border)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: kGreen, width: 1.8)),
      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: kRed)),
      hintStyle: GoogleFonts.plusJakartaSans(color: textHint, fontSize: 14),
      labelStyle: GoogleFonts.plusJakartaSans(color: textSec, fontSize: 13),
      errorStyle: GoogleFonts.plusJakartaSans(color: kRed, fontSize: 12),
    ),
    cardTheme: CardTheme(
      color: card, elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16), side: BorderSide(color: border)),
      margin: EdgeInsets.zero,
    ),
    dividerTheme: DividerThemeData(color: border, thickness: 1, space: 1),
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.resolveWith((s) =>
          s.contains(MaterialState.selected) ? kGreen : (dark ? Colors.grey.shade600 : Colors.grey.shade400)),
      trackColor: MaterialStateProperty.resolveWith((s) =>
          s.contains(MaterialState.selected) ? kGreen.withOpacity(0.4) : (dark ? Colors.grey.shade800 : Colors.grey.shade300)),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: dark ? const Color(0xFF1A2E1C) : kText,
      contentTextStyle: GoogleFonts.plusJakartaSans(color: dark ? const Color(0xFFE8F5EA) : Colors.white, fontSize: 13),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      behavior: SnackBarBehavior.floating,
    ),
  );
}

// ── Theme-aware color helpers ──────────────────────────────────────────────
// Use these instead of hardcoded kText/kTextSec/kGreenPale etc. in widgets
extension ThemeColors on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
  Color get tText     => isDark ? const Color(0xFFE8F5EA) : kText;
  Color get tTextSec  => isDark ? const Color(0xFF9EC4A2) : kTextSec;
  Color get tTextMuted=> isDark ? const Color(0xFF5A7A5D) : kTextMuted;
  Color get tCard     => isDark ? const Color(0xFF1A2E1C) : kCard;
  Color get tBg       => isDark ? const Color(0xFF0F1F11) : kBg;
  Color get tBorder   => isDark ? const Color(0xFF2A4A2D) : kBorder;
  Color get tInputBg  => isDark ? const Color(0xFF152017) : kInputBg;
  Color get tGreenPale=> isDark ? const Color(0xFF1A3A1C) : kGreenPale;
}
