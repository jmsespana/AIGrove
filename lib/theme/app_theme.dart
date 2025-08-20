import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // I-add para sa SystemUiOverlayStyle

class AppTheme {
  // Define your green color palette
  static const Color primaryGreen = Color(0xFF4CAF50);
  static const Color darkGreen = Color(0xFF2E7D32);
  static const Color lightGreen = Color(0xFF81C784);
  static const Color greenAccent = Color(0xFF66BB6A);

  // I-add ang status bar styling constants
  static const SystemUiOverlayStyle lightStatusBar = SystemUiOverlayStyle(
    statusBarColor: Colors.black, // Black status bar area
    statusBarIconBrightness: Brightness.light, // White icons
    systemNavigationBarColor: Colors.white,
    systemNavigationBarIconBrightness: Brightness.dark,
  );

  static const SystemUiOverlayStyle darkStatusBar = SystemUiOverlayStyle(
    statusBarColor: Colors.black, // Black status bar area
    statusBarIconBrightness: Brightness.light, // White icons
    systemNavigationBarColor: Color(0xFF121212),
    systemNavigationBarIconBrightness: Brightness.light,
  );

  static final ThemeData natureTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: primaryGreen,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryGreen,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: const Color(0xFFE8F5E9),
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryGreen,
      elevation: 0,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      iconTheme: IconThemeData(color: Colors.white),
      systemOverlayStyle: lightStatusBar, // I-add ang status bar styling
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: darkGreen,
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
    ),
    drawerTheme: const DrawerThemeData(backgroundColor: Colors.white),
    textTheme: const TextTheme(bodyMedium: TextStyle(color: Colors.black87)),
    // I-add ang card theme para consistent sa profile page
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );

  // Custom dark theme that maintains green colors
  static final ThemeData natureDarkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: primaryGreen,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryGreen,
      brightness: Brightness.dark,
    ),
    scaffoldBackgroundColor: const Color(0xFF121212),
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryGreen, // Keep green in dark mode
      elevation: 0,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      iconTheme: IconThemeData(color: Colors.white),
      systemOverlayStyle: darkStatusBar, // I-add ang status bar styling
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF1E1E1E),
      selectedItemColor: lightGreen, // Lighter green for dark mode
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
    ),
    drawerTheme: const DrawerThemeData(backgroundColor: Color(0xFF1E1E1E)),
    cardTheme: CardThemeData(
      color: const Color(0xFF2D2D2D),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    textTheme: const TextTheme(bodyMedium: TextStyle(color: Colors.white70)),
  );
}
