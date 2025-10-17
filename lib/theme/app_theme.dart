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

  // ============================================
  // BOTTOM NAV CUSTOMIZATION PROPERTIES
  // ============================================

  // Bottom Nav Colors - GLASSMORPHISM EFFECT
  // Transparent glass effect para sa light mode
  // ignore: deprecated_member_use
  static final Color bottomNavBackgroundLight = Colors.white.withOpacity(0.7);
  // Transparent glass effect para sa dark mode
  static final Color bottomNavBackgroundDark = const Color(
    0xFF1E1E1E,
  // ignore: deprecated_member_use
  ).withOpacity(0.7);

  static const Color bottomNavSelectedLight = darkGreen;
  static const Color bottomNavSelectedDark = lightGreen;
  static const Color bottomNavUnselectedLight = Colors.grey;
  static const Color bottomNavUnselectedDark = Colors.grey;

  // Bottom Nav Border Radius
  static const double bottomNavBorderRadius = 30.0;
  static const double bottomNavItemBorderRadius = 20.0;
  static const double bottomNavIconBoxBorderRadius = 15.0;

  // Bottom Nav Spacing
  static const EdgeInsets bottomNavMargin = EdgeInsets.only(
    left: 12.0,
    right: 12.0,
    bottom: 12.0,
  );
  static const EdgeInsets bottomNavPadding = EdgeInsets.symmetric(
    vertical: 10.0,
    horizontal: 4.0,
  );
  static const EdgeInsets bottomNavItemPadding = EdgeInsets.symmetric(
    horizontal: 12.0,
    vertical: 8.0,
  );
  static const EdgeInsets bottomNavIconPadding = EdgeInsets.all(10.0);

  // Bottom Nav Icon Sizes
  static const double bottomNavIconSizeSelected = 24.0;
  static const double bottomNavIconSizeUnselected = 20.0;

  // Bottom Nav Text Styles
  static const double bottomNavTextSizeSelected = 11.0;
  static const double bottomNavTextSizeUnselected = 9.0;
  static const double bottomNavTextLetterSpacing = 0.5;

  // Bottom Nav Shadow - Enhanced para sa glass effect
  static List<BoxShadow> getBottomNavShadow({bool isDark = false}) {
    return [
      BoxShadow(
        // ignore: deprecated_member_use
        color: Colors.black.withOpacity(isDark ? 0.3 : 0.15),
        blurRadius: 20,
        spreadRadius: 5,
        offset: const Offset(0, 5),
      ),
    ];
  }

  // Bottom Nav Blur Amount - Para sa glassmorphism
  static const double bottomNavBlurAmount = 10.0;

  // Bottom Nav Item Background Opacity
  static const double bottomNavSelectedBackgroundOpacity = 0.15;
  static const double bottomNavUnselectedBackgroundOpacity = 0.08;

  // Bottom Nav Icon Box Background Opacity
  static const double bottomNavSelectedIconBoxOpacity = 0.2;
  static const double bottomNavUnselectedIconBoxOpacity = 0.08;

  // Bottom Nav Border Width
  static const double bottomNavItemBorderWidth = 2.0;
  static const double bottomNavIconBoxBorderWidth = 1.5;

  // Bottom Nav Icon Box Border Opacity
  static const double bottomNavSelectedIconBoxBorderOpacity = 0.4;

  // Bottom Nav Border - Para sa glass effect
  static Border getBottomNavBorder({bool isDark = false}) {
    return Border.all(
      color: isDark
          // ignore: deprecated_member_use
          ? Colors.white.withOpacity(0.1)
          // ignore: deprecated_member_use
          : Colors.white.withOpacity(0.3),
      width: 1.5,
    );
  }

  // Helper method para makuha ang selected color based sa isDark
  static Color getBottomNavSelectedColor(bool isDark) {
    return isDark ? bottomNavSelectedDark : bottomNavSelectedLight;
  }

  // Helper method para makuha ang unselected color based sa isDark
  static Color getBottomNavUnselectedColor(bool isDark) {
    return isDark ? bottomNavUnselectedDark : bottomNavUnselectedLight;
  }

  // Helper method para makuha ang background color based sa isDark
  static Color getBottomNavBackgroundColor(bool isDark) {
    return isDark ? bottomNavBackgroundDark : bottomNavBackgroundLight;
  }

  // ============================================
  // END OF BOTTOM NAV CUSTOMIZATION
  // ============================================

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
      systemOverlayStyle: lightStatusBar,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: darkGreen,
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
    ),
    drawerTheme: const DrawerThemeData(backgroundColor: Colors.white),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: Colors.black87),
      titleLarge: sectionTitleLight,
      bodyLarge: sectionContentLight,
      headlineSmall: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: darkGreen,
      ),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
    ),
    tabBarTheme: const TabBarThemeData(
      labelColor: Colors.white,
      unselectedLabelColor: Colors.white70,
      indicatorColor: Colors.white,
      indicatorSize: TabBarIndicatorSize.tab,
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
    ),
    iconTheme: const IconThemeData(color: darkGreen, size: 24),
    listTileTheme: const ListTileThemeData(
      iconColor: darkGreen,
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: primaryGreen,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
  );

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
      backgroundColor: darkGreen,
      elevation: 0,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      iconTheme: IconThemeData(color: Colors.white),
      systemOverlayStyle: darkStatusBar,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF1E1E1E),
      selectedItemColor: lightGreen,
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
    ),
    drawerTheme: const DrawerThemeData(backgroundColor: Color(0xFF1E1E1E)),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: Colors.white70),
      titleLarge: sectionTitleDark,
      bodyLarge: sectionContentDark,
      headlineSmall: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: lightGreen,
      ),
    ),
    cardTheme: CardThemeData(
      color: const Color(0xFF2D2D2D),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
    ),
    tabBarTheme: const TabBarThemeData(
      labelColor: Colors.white,
      unselectedLabelColor: Colors.white70,
      indicatorColor: lightGreen,
      indicatorSize: TabBarIndicatorSize.tab,
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Color(0xFF2D2D2D),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
    ),
    iconTheme: const IconThemeData(color: lightGreen, size: 24),
    listTileTheme: const ListTileThemeData(
      iconColor: lightGreen,
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),
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

  // ============================================
  // GRADIENT BACKGROUND DECORATIONS
  // ============================================
  
  /// Gradient background para sa light mode
  /// Gikan sa green[700] paingon sa green[50]
  static BoxDecoration getGradientBackground({bool isDark = false}) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: isDark
            ? [
                const Color(0xFF2E7D32), // darkGreen
                const Color(0xFF1B5E20), // darker green
              ]
            : [
                const Color(0xFF4CAF50), // primaryGreen
                const Color(0xFFE8F5E9), // very light green
              ],
      ),
    );
  }

  /// Alternative gradient - top to bottom fade
  static BoxDecoration getPageGradient(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return getGradientBackground(isDark: isDark);
  }
}
