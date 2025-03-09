import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      appBarTheme: AppBarTheme(
        color: Colors.white,
        elevation: 10.0,
        iconTheme: IconThemeData(color: Colors.black),
        titleTextStyle: TextStyle(color: Colors.black),
      ),
      scaffoldBackgroundColor: Colors.white,
      primarySwatch: Colors.blue,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      textTheme: TextTheme(
        displayLarge: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
        bodyLarge: TextStyle(fontSize: 14.0),
      ),
      inputDecorationTheme: InputDecorationTheme(border: OutlineInputBorder()),
    );
  }
}
