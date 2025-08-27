import 'package:aigrove/auth/landing_page.dart';
import 'package:aigrove/auth/login_page.dart';
import 'package:aigrove/auth/register_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // I-add para sa SystemUiOverlayStyle
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'services/user_service.dart';
import 'services/profile_service.dart';
import 'pages/home_page.dart';
import 'pages/scan_page.dart';
import 'pages/map_page.dart';
import 'pages/challenge_page.dart';
import 'theme/app_theme.dart';
import 'widgets/app_drawer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://xtgzxoszyrxzbqvfdfif.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inh0Z3p4b3N6eXJ4emJxdmZkZmlmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTQ5MzAwNjUsImV4cCI6MjA3MDUwNjA2NX0.H2D1E-358Dv4dRLwyzedUVp1Pdrj3nquSkCNLtsX1mQ',
    // Add this parameter to ensure persistence
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce,
    ),
  );

  final userService = UserService();
  await userService.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => userService),
        ChangeNotifierProvider(create: (_) => ProfileService()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isDark = false;

  void toggleTheme() {
    setState(() {
      isDark = !isDark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AIgrove',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.natureTheme,
      darkTheme: AppTheme.natureDarkTheme,
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,

      // I-add ang global status bar styling para sa black SafeArea
      builder: (context, child) {
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: const SystemUiOverlayStyle(
            statusBarColor: Colors.black, // Black status bar area
            statusBarIconBrightness: Brightness.light, // White icons
          ),
          child: child!,
        );
      },

      initialRoute: '/landing',
      routes: {
        '/landing': (context) => const LandingPage(),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/home': (context) =>
            MainScreen(isDark: isDark, toggleTheme: toggleTheme),
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  final bool isDark;
  final VoidCallback toggleTheme;

  const MainScreen({
    super.key,
    required this.isDark,
    required this.toggleTheme,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomePage(),
    ScanPage(),
    MapPage(),
    ChallengePage(),
  ];

  @override
  Widget build(BuildContext context) {
    // Dinamikong background color base sa current theme mode
    final barBackgroundColor = widget.isDark
        ? const Color(0xFF1E1E1E)
        : Colors.white;
    // Text ug icon color na appropriate sa background
    final contentColor = widget.isDark ? Colors.white : Colors.green.shade700;

    // I-wrap ang Scaffold sa SafeArea para ma-ensure nga black ang status bar area
    return Container(
      color: Colors.black, // Black background para sa SafeArea
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            leading: Builder(
              builder: (context) => IconButton(
                icon: FaIcon(
                  FontAwesomeIcons.bars,
                  color: contentColor, // Dynamic color based on theme
                ),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
            ),
            title: Text(
              "AIgrove",
              style: TextStyle(
                color: contentColor,
              ), // Dynamic color based on theme
            ),
            backgroundColor: barBackgroundColor, // Dynamic color based on theme
            actions: [
              IconButton(
                icon: FaIcon(
                  widget.isDark
                      ? FontAwesomeIcons.moon
                      : FontAwesomeIcons.solidSun,
                  color: contentColor, // Dynamic color based on theme
                ),
                onPressed: widget.toggleTheme,
              ),
            ],
          ),
          drawer: AppDrawer(), // Gi-maintain ang existing AppDrawer
          body: _pages[_currentIndex], // Gi-maintain ang existing pages
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: barBackgroundColor, // Dynamic color based on theme
              boxShadow: [
                BoxShadow(
                  // ignore: deprecated_member_use
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 5,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              currentIndex: _currentIndex,
              backgroundColor:
                  barBackgroundColor, // Dynamic color based on theme
              selectedItemColor: widget.isDark
                  ? Colors
                        .green
                        .shade400 // Mas light nga green sa dark mode
                  : Colors.green.shade700, // Dark green sa light mode
              unselectedItemColor: widget.isDark
                  ? Colors
                        .grey // Grey sa dark mode
                  : Colors.grey.shade600, // Darker grey sa light mode
              elevation: 8,
              selectedFontSize: 12,
              unselectedFontSize: 10,
              iconSize: 24,
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              items: const [
                BottomNavigationBarItem(
                  icon: FaIcon(FontAwesomeIcons.house),
                  activeIcon: FaIcon(FontAwesomeIcons.houseChimney, size: 28),
                  label: "Home",
                ),
                BottomNavigationBarItem(
                  icon: FaIcon(
                    FontAwesomeIcons.camera,
                  ), // Camera para sa plant scanning
                  activeIcon: FaIcon(
                    FontAwesomeIcons.cameraRetro,
                    size: 28,
                  ), // Retro camera when active
                  label: "Scan",
                ),
                BottomNavigationBarItem(
                  icon: FaIcon(FontAwesomeIcons.locationDot), // Location pin
                  activeIcon: FaIcon(
                    FontAwesomeIcons.mapLocationDot,
                    size: 28,
                  ), // Map with location when active
                  label: "Map",
                ),
                BottomNavigationBarItem(
                  icon: FaIcon(
                    FontAwesomeIcons.trophy,
                  ), // Star para sa achievements
                  activeIcon: FaIcon(
                    FontAwesomeIcons.star,
                    size: 28,
                  ), // Solid star when active
                  label: "Challenge",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
