import 'package:aigrove/auth/landing_page.dart';
import 'package:aigrove/auth/login_page.dart';
import 'package:aigrove/auth/register_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
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
import 'widgets/custom_bottom_nav.dart'; // I-import ang bag-ong custom bottom nav

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ADD THIS LINE - Load environment variables
  try {
    await dotenv.load(fileName: "assets/.env");
    debugPrint('✅ .env file na-load na');
    debugPrint(
      '🔑 OPENROUTER_API_KEY: ${dotenv.env['OPENROUTER_API_KEY']?.substring(0, 20)}...',
    );
  } catch (e) {
    debugPrint('❌ Error sa pag-load sa .env file: $e');
  }

  await Supabase.initialize(
    url: 'https://xtgzxoszyrxzbqvfdfif.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inh0Z3p4b3N6eXJ4emJxdmZkZmlmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTQ5MzAwNjUsImV4cCI6MjA3MDUwNjA2NX0.H2D1E-358Dv4dRLwyzedUVp1Pdrj3nquSkCNLtsX1mQ',
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
      builder: (context, child) {
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: const SystemUiOverlayStyle(
            statusBarColor: Colors.black,
            statusBarIconBrightness: Brightness.light,
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
    final barBackgroundColor = widget.isDark
        ? const Color(0xFF1E1E1E)
        : Colors.white;
    final contentColor = widget.isDark ? Colors.white : Colors.green.shade700;

    return Container(
      color: Colors.black,
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            leading: Builder(
              builder: (context) => IconButton(
                icon: FaIcon(FontAwesomeIcons.bars, color: contentColor),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
            ),
            title: Text("AIgrove", style: TextStyle(color: contentColor)),
            backgroundColor: barBackgroundColor,
            actions: [
              IconButton(
                icon: FaIcon(
                  widget.isDark
                      ? FontAwesomeIcons.moon
                      : FontAwesomeIcons.solidSun,
                  color: contentColor,
                ),
                onPressed: widget.toggleTheme,
              ),
            ],
          ),
          drawer: AppDrawer(),
          body: _pages[_currentIndex],
          // Gamiton ang bag-ong CustomBottomNav widget
          bottomNavigationBar: CustomBottomNav(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            isDark: widget.isDark,
          ),
        ),
      ),
    );
  }
}
