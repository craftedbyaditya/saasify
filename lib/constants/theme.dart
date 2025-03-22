import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static String get fontFamily => 'Quicksand';

  static TextStyle _getFont({
    required double fontSize,
    FontWeight? fontWeight,
    double? letterSpacing,
    Color? color,
  }) {
    return GoogleFonts.getFont(
      fontFamily,
      fontSize: fontSize,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
      color: color,
    );
  }

  static TextTheme get _textTheme {
    return TextTheme(
      displayLarge: _getFont(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        letterSpacing: -0.5,
      ),
      displayMedium: _getFont(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.5,
      ),
      displaySmall: _getFont(fontSize: 24, fontWeight: FontWeight.w600),
      headlineLarge: _getFont(fontSize: 20, fontWeight: FontWeight.w600),
      headlineMedium: _getFont(fontSize: 18, fontWeight: FontWeight.w500),
      titleLarge: _getFont(fontSize: 16, fontWeight: FontWeight.w600),
      titleMedium: _getFont(fontSize: 14, fontWeight: FontWeight.w500),
      bodyLarge: _getFont(fontSize: 16, fontWeight: FontWeight.normal),
      bodyMedium: _getFont(fontSize: 14, fontWeight: FontWeight.normal),
      bodySmall: _getFont(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: Colors.grey[600],
      ),
      labelLarge: _getFont(fontSize: 14, fontWeight: FontWeight.w500),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      appBarTheme: AppBarTheme(
        color: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        titleTextStyle: _textTheme.titleLarge,
      ),
      scaffoldBackgroundColor: Colors.white,
      primarySwatch: Colors.blue,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      textTheme: _textTheme,
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      cardTheme: CardTheme(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey.shade200),
        ),
        color: Colors.white,
      ),
    );
  }
}
