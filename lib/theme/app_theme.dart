import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // I-add para sa SystemUiOverlayStyle

class AppTheme {
  // Define your green color palette
  static const Color primaryGreen = Color(0xFF4CAF50);
  static const Color darkGreen = Color(0xFF2E7D32);
  static const Color lightGreen = Color(0xFF81C784);
  static const Color greenAccent = Color(0xFF66BB6A);

  // I-add ang neutral colors para sa consistent UI elements
  static const Color surfaceLight = Colors.white;
  static const Color surfaceDark = Color(0xFF2D2D2D);
  static const Color backgroundLight = Color(0xFFE8F5E9);
  static const Color backgroundDark = Color(0xFF121212);

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

  // Shared text styles para sa About ug History pages
  static const TextStyle sectionTitleLight = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 20,
    color: darkGreen,
  );

  static const TextStyle sectionTitleDark = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 20,
    color: lightGreen,
  );

  static const TextStyle sectionContentLight = TextStyle(
    fontSize: 16,
    height: 1.5,
    color: Colors.black87,
  );

  static const TextStyle sectionContentDark = TextStyle(
    fontSize: 16,
    height: 1.5,
    color: Colors.white70,
  );

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: primaryGreen,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryGreen,
      brightness: Brightness.light,
      primary: primaryGreen,
      secondary: darkGreen,
      tertiary: greenAccent,
      // ignore: deprecated_member_use
      background: backgroundLight,
      surface: surfaceLight,
    ),
    scaffoldBackgroundColor: backgroundLight,
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

    // Updated text theme para sa About ug History pages
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: Colors.black87),
      // Para sa section titles sa About page
      titleLarge: sectionTitleLight,
      // Para sa content sa About ug History page
      bodyLarge: sectionContentLight,
      // Para sa headings sa modals
      headlineSmall: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: darkGreen,
      ),
    ),

    // Enhanced card theme para sa feature list ug history items
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
    ),

    // I-add ang tab theme para sa History page
    tabBarTheme: const TabBarThemeData(
      labelColor: Colors.white,
      unselectedLabelColor: Colors.white70,
      indicatorColor: Colors.white,
      indicatorSize: TabBarIndicatorSize.tab,
    ),

    // I-add ang bottom sheet theme para sa detail views
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
    ),

    // I-add ang icon theme para sa consistent icon styling
    iconTheme: const IconThemeData(color: darkGreen, size: 24),

    // I-add ang styling para sa ListTile elements
    listTileTheme: const ListTileThemeData(
      iconColor: darkGreen,
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),

    // I-add ang button theme para sa actions
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: primaryGreen,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
  );

  // Custom dark theme that maintains green colors
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: primaryGreen,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryGreen,
      brightness: Brightness.dark,
      primary: primaryGreen,
      secondary: lightGreen,
      tertiary: greenAccent,
      // ignore: deprecated_member_use
      background: backgroundDark,
      surface: surfaceDark,
    ),
    scaffoldBackgroundColor: backgroundDark,
    appBarTheme: const AppBarTheme(
      backgroundColor: darkGreen, // Darker green for dark mode
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

    // Updated text theme para sa About ug History pages sa dark mode
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: Colors.white70),
      // Para sa section titles sa About page
      titleLarge: sectionTitleDark,
      // Para sa content sa About ug History page
      bodyLarge: sectionContentDark,
      // Para sa headings sa modals
      headlineSmall: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: lightGreen,
      ),
    ),

    // Enhanced card theme para sa dark mode
    cardTheme: CardThemeData(
      color: const Color(0xFF2D2D2D),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
    ),

    // Tab theme para sa dark mode
    tabBarTheme: const TabBarThemeData(
      labelColor: Colors.white,
      unselectedLabelColor: Colors.white70,
      indicatorColor: lightGreen,
      indicatorSize: TabBarIndicatorSize.tab,
    ),

    // Bottom sheet theme para sa dark mode
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Color(0xFF2D2D2D),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
    ),

    // Icon theme para sa dark mode
    iconTheme: const IconThemeData(color: lightGreen, size: 24),

    // ListTile theme para sa dark mode
    listTileTheme: const ListTileThemeData(
      iconColor: lightGreen,
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),

    // Button theme para sa dark mode
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.black,
        backgroundColor: lightGreen,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
  );

  // Renamed for compatibility with the existing code
  static final ThemeData natureTheme = lightTheme;
  static final ThemeData natureDarkTheme = darkTheme;
}
