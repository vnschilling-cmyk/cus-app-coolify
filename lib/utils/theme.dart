import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const primaryColor = Color(0xFF6366F1); // Indigo
  static const secondaryColor = Color(0xFF10B981); // Emerald
  static const darkBackground = Color(0xFF0F172A);
  static const surfaceColor = Color(0xFF1E293B);
  static const accentColor = Color(0xFF818CF8);

  static final lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: const Color(0xFFF1F5F9), // Slate 100
    colorScheme: const ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      surface: Colors.white,
      onSurface: Color(0xFF1E293B), // Slate 800
    ),

    // Modern Typography with Thin Fonts (Light Mode)
    textTheme: GoogleFonts.interTextTheme(
      const TextTheme(
        displayLarge: TextStyle(
            fontWeight: FontWeight.w200,
            fontSize: 48,
            color: Color(0xFF1E293B)),
        displayMedium: TextStyle(
            fontWeight: FontWeight.w200,
            fontSize: 36,
            color: Color(0xFF1E293B)),
        displaySmall: TextStyle(
            fontWeight: FontWeight.w300,
            fontSize: 32,
            color: Color(0xFF1E293B)),
        headlineMedium: TextStyle(
            fontWeight: FontWeight.w300,
            fontSize: 24,
            color: Color(0xFF1E293B)),
        titleLarge: TextStyle(
            fontWeight: FontWeight.w300,
            fontSize: 22,
            color: Color(0xFF1E293B)),
        bodyLarge: TextStyle(
            fontWeight: FontWeight.w300,
            fontSize: 16,
            color: Color(0xFF334155)),
        bodyMedium: TextStyle(
            fontWeight: FontWeight.w300,
            fontSize: 14,
            color: Color(0xFF334155)),
        labelLarge: TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 14,
            color: Color(0xFF1E293B)),
      ),
    ),

    appBarTheme: AppBarTheme(
      backgroundColor: const Color(0xFFF1F5F9),
      elevation: 0,
      centerTitle: true,
      iconTheme: const IconThemeData(color: Color(0xFF1E293B)),
      titleTextStyle: GoogleFonts.inter(
        fontWeight: FontWeight.w200,
        fontSize: 20,
        color: const Color(0xFF1E293B),
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 56),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: GoogleFonts.inter(
          fontWeight: FontWeight.w400,
          fontSize: 16,
          letterSpacing: 1.1,
        ),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      hintStyle: GoogleFonts.inter(
        fontWeight: FontWeight.w200,
        color: Colors.black38,
      ),
      labelStyle: GoogleFonts.inter(
        fontWeight: FontWeight.w300,
        color: primaryColor,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: primaryColor, width: 1),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
    ),

    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    ),
  );

  static final darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: darkBackground,
    colorScheme: const ColorScheme.dark(
      primary: primaryColor,
      secondary: secondaryColor,
      surface: surfaceColor,
      onSurface: Colors.white,
    ),
    textTheme: GoogleFonts.interTextTheme(
      const TextTheme(
        displayLarge: TextStyle(fontWeight: FontWeight.w200, fontSize: 48),
        displayMedium: TextStyle(fontWeight: FontWeight.w200, fontSize: 36),
        displaySmall: TextStyle(fontWeight: FontWeight.w300, fontSize: 32),
        headlineMedium: TextStyle(fontWeight: FontWeight.w300, fontSize: 24),
        titleLarge: TextStyle(fontWeight: FontWeight.w300, fontSize: 22),
        bodyLarge: TextStyle(fontWeight: FontWeight.w300, fontSize: 16),
        bodyMedium: TextStyle(fontWeight: FontWeight.w300, fontSize: 14),
        labelLarge: TextStyle(fontWeight: FontWeight.w400, fontSize: 14),
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: darkBackground,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.inter(
        fontWeight: FontWeight.w200,
        fontSize: 20,
        color: Colors.white,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 56),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: GoogleFonts.inter(
          fontWeight: FontWeight.w400,
          fontSize: 16,
          letterSpacing: 1.1,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceColor.withValues(alpha: 0.5),
      hintStyle: GoogleFonts.inter(
        fontWeight: FontWeight.w200,
        color: Colors.white38,
      ),
      labelStyle: GoogleFonts.inter(
        fontWeight: FontWeight.w300,
        color: accentColor,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: accentColor, width: 1),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
    ),
    cardTheme: CardThemeData(
      color: surfaceColor,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    ),
  );
}
