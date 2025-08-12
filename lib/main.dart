import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; // Added
import 'package:supabase_flutter/supabase_flutter.dart';
import 'pages/home_page.dart';
import 'pages/scan_page.dart';
import 'pages/map_page.dart';
import 'pages/challenge_page.dart';
import 'theme/app_theme.dart';
import 'widgets/app_drawer.dart';

const supabaseUrl = 'https://xtgzxoszyrxzbqvfdfif.supabase.co';
const supabaseKey =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inh0Z3p4b3N6eXJ4emJxdmZkZmlmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTQ5MzAwNjUsImV4cCI6MjA3MDUwNjA2NX0.H2D1E-358Dv4dRLwyzedUVp1Pdrj3nquSkCNLtsX1mQ';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseKey);
  runApp(const AIGroveApp());
}

class AIGroveApp extends StatefulWidget {
  const AIGroveApp({super.key});

  @override
  State<AIGroveApp> createState() => _AIGroveAppState();
}

class _AIGroveAppState extends State<AIGroveApp> {
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
      theme: AppTheme.natureTheme, // Light theme
      darkTheme: AppTheme.natureDarkTheme, // Dark theme with green colors
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      home: MainScreen(isDark: isDark, toggleTheme: toggleTheme),
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
      drawer: const AppDrawer(),
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
