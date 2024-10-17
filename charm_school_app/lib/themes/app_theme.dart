import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get customTheme {
    return ThemeData(
      primaryColor: Colors.purple[800],
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.purple[800],
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      textTheme: TextTheme(
        bodyLarge: TextStyle(color: Colors.purple[900]),
        bodyMedium: TextStyle(color: Colors.purple[900]),
        titleLarge: const TextStyle(color: Colors.white, fontSize: 20),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.purple[800], // Button background color
          foregroundColor: Colors.white, // Button text color
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
      drawerTheme: const DrawerThemeData(
        backgroundColor: Colors.white,
      ),
      tabBarTheme: TabBarTheme(
        labelColor: Colors.white,
        unselectedLabelColor: Colors.purple[800],
        indicator: const BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Colors.white,
              width: 3.0,
            ),
          ),
        ),
      ),
      colorScheme: ColorScheme.fromSwatch(
        primarySwatch: Colors.purple,
      ).copyWith(secondary: Colors.white),
      iconTheme: const IconThemeData(color: Colors.white),
    );
  }
}
