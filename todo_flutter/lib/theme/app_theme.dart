import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  AppColors._();

  // Core brand color - indigo ink, used for primary actions and accents.
  static const Color primary = Color(0xFF4C5FD5);
  static const Color primaryDark = Color(0xFF7B8AF2);

  // Backgrounds
  static const Color backgroundLight = Color(0xFFF3F4F8);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color backgroundDark = Color(0xFF12141C);
  static const Color surfaceDark = Color(0xFF1C1F2B);

  // Text
  static const Color textPrimaryLight = Color(0xFF1B1E2B);
  static const Color textSecondaryLight = Color(0xFF6B7080);
  static const Color textPrimaryDark = Color(0xFFEDEFF7);
  static const Color textSecondaryDark = Color(0xFF9AA0B4);

  // Priority accents
  static const Color priorityLow = Color(0xFF2FA88F);
  static const Color priorityMedium = Color(0xFFF2A93B);
  static const Color priorityHigh = Color(0xFFE5484D);

  static Color priorityColor(String priority) {
    switch (priority) {
      case 'low':
        return priorityLow;
      case 'high':
        return priorityHigh;
      default:
        return priorityMedium;
    }
  }
}

class AppTheme {
  AppTheme._();

  static ThemeData light() {
    final base = ThemeData(brightness: Brightness.light, useMaterial3: true);
    final textTheme = _textTheme(base.textTheme, AppColors.textPrimaryLight);

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.backgroundLight,
      colorScheme: base.colorScheme.copyWith(
        primary: AppColors.primary,
        secondary: AppColors.priorityLow,
        surface: AppColors.surfaceLight,
        error: AppColors.priorityHigh,
      ),
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.backgroundLight,
        foregroundColor: AppColors.textPrimaryLight,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.sora(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimaryLight,
        ),
      ),
      cardTheme: const CardThemeData(
        color: AppColors.surfaceLight,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(18)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceLight,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.6),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 15),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      chipTheme: base.chipTheme.copyWith(
        labelStyle: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w500),
        selectedColor: AppColors.primary.withOpacity(0.15),
        backgroundColor: Colors.grey.shade100,
        shape: StadiumBorder(side: BorderSide(color: Colors.grey.shade300)),
      ),
    );
  }

  static ThemeData dark() {
    final base = ThemeData(brightness: Brightness.dark, useMaterial3: true);
    final textTheme = _textTheme(base.textTheme, AppColors.textPrimaryDark);

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.backgroundDark,
      colorScheme: base.colorScheme.copyWith(
        primary: AppColors.primaryDark,
        secondary: AppColors.priorityLow,
        surface: AppColors.surfaceDark,
        error: AppColors.priorityHigh,
      ),
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.backgroundDark,
        foregroundColor: AppColors.textPrimaryDark,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.sora(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimaryDark,
        ),
      ),
      cardTheme: const CardThemeData(
        color: AppColors.surfaceDark,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(18)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceDark,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade800),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade800),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primaryDark, width: 1.6),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryDark,
          foregroundColor: AppColors.backgroundDark,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 15),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primaryDark,
        foregroundColor: AppColors.backgroundDark,
      ),
      chipTheme: base.chipTheme.copyWith(
        labelStyle: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w500),
        selectedColor: AppColors.primaryDark.withOpacity(0.25),
        backgroundColor: Colors.grey.shade900,
        shape: StadiumBorder(side: BorderSide(color: Colors.grey.shade700)),
      ),
    );
  }

  static TextTheme _textTheme(TextTheme base, Color color) {
    return GoogleFonts.interTextTheme(base).copyWith(
      displaySmall: GoogleFonts.sora(fontSize: 30, fontWeight: FontWeight.w700, color: color),
      headlineMedium: GoogleFonts.sora(fontSize: 24, fontWeight: FontWeight.w700, color: color),
      headlineSmall: GoogleFonts.sora(fontSize: 20, fontWeight: FontWeight.w700, color: color),
      titleLarge: GoogleFonts.sora(fontSize: 17, fontWeight: FontWeight.w600, color: color),
      bodyLarge: GoogleFonts.inter(fontSize: 15, color: color),
      bodyMedium: GoogleFonts.inter(fontSize: 13.5, color: color),
    );
  }
}
