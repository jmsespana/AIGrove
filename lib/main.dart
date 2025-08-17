import 'package:aigrove/auth/landing_page.dart';
import 'package:aigrove/auth/login_page.dart';
import 'package:aigrove/auth/register_page.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; // Added
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
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inh0Z3p4b3N6eXJ4emJxdmZkZmlmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTQ5MzAwNjUsImV4cCI6MjA3MDUwNjA2NX0.H2D1E-358Dv4dRLwyzedUVp1Pdrj3nquSkCNLtsX1mQ',
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
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: const FaIcon(FontAwesomeIcons.bars), // menu icon
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: const Text("AIgrove"),
        actions: [
          IconButton(
            icon: FaIcon(
              widget.isDark
                  ? FontAwesomeIcons
                        .moon // dark mode icon
                  : FontAwesomeIcons.solidSun, // light mode icon
            ),
            onPressed: widget.toggleTheme,
          ),
        ],
      ),
      drawer: AppDrawer(),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        selectedItemColor: const Color(0xFF2E7D32),
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.house), // home icon
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.qrcode), // scan icon
            label: "Scan",
          ),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.map), // map icon
            label: "Map",
          ),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.trophy), // challenge icon
            label: "Challenge",
          ),
        ],
      ),
    );
  }
}
