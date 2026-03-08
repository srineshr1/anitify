import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ─── Light Palette ────────────────────────────────────────────────────────
  static const Color bg = Color(0xFFF5F5F7);
  static const Color bgCard = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFF0F0F5);
  static const Color surfaceLight = Color(0xFFE8E8F0);
  static const Color border = Color(0xFFDCDCE5);

  // Accents (unchanged — brand identity)
  static const Color accent = Color(0xFF7C6AF7);
  static const Color accentGlow = Color(0x337C6AF7);
  static const Color accentSoft = Color(0xFF6B5CE6);
  static const Color pink = Color(0xFFE56BFF);
  static const Color pinkGlow = Color(0x33E56BFF);
  static const Color teal = Color(0xFF3BDFCC);

  // Text
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF6B6B7B);
  static const Color textMuted = Color(0xFFA0A0B0);

  // ─── TextStyle helper using Inter ──────────────────────────────────────────
  static TextStyle _inter({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w400,
    Color color = textPrimary,
    double letterSpacing = 0,
    double height = 1.0,
  }) {
    return GoogleFonts.inter(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
    );
  }

  static ThemeData get light => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: bg,
    colorScheme: const ColorScheme.light(
      primary: accent,
      secondary: pink,
      surface: surface,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: _inter(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        letterSpacing: -0.3,
      ),
    ),
    textTheme: TextTheme(
      displayLarge: _inter(fontSize: 32, fontWeight: FontWeight.w700, color: textPrimary, letterSpacing: -1),
      titleLarge: _inter(fontSize: 18, fontWeight: FontWeight.w600, color: textPrimary),
      titleMedium: _inter(fontSize: 15, fontWeight: FontWeight.w500, color: textPrimary),
      bodyLarge: _inter(fontSize: 14, fontWeight: FontWeight.w400, color: textSecondary),
      bodyMedium: _inter(fontSize: 13, fontWeight: FontWeight.w400, color: textSecondary),
      labelSmall: _inter(fontSize: 11, fontWeight: FontWeight.w500, color: textMuted, letterSpacing: 0.8),
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: accent,
      inactiveTrackColor: border,
      thumbColor: accent,
      overlayColor: accentGlow,
      trackHeight: 3,
      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
    ),
  );
}
