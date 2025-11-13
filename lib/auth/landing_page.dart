// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/user_service.dart';
import '../theme/app_theme.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // I-setup ang animation para smooth ang pagpakita
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _animationController.forward();

    // Check kung naka-login na ba ang user
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuth();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _checkAuth() {
    // Kuhaon ang user service ug i-check kung authenticated
    final userService = Provider.of<UserService>(context, listen: false);
    if (userService.isAuthenticated) {
      // I-redirect ang user sa home page kay naka-login na siya
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Define text colors base sa gradient position
    final Color topTextColor =
        Colors.white; // White text sa green gradient (taas)
    final Color bottomTextColor = isDark
        ? Colors.white
        : const Color(0xFF2D5016); // Dark text sa light gradient (ubos)

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [AppTheme.darkGreen, const Color(0xFF1B5E20)]
                : [
                    AppTheme.primaryGreen,
                    AppTheme.lightGreen,
                    AppTheme.backgroundLight,
                  ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Scrollable content - kini ang mo-scroll
              SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 100),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32.0,
                    vertical: 40.0,
                  ),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 20),

                          // App Logo/Icon with mangrove theme
                          Container(
                            width: 160,
                            height: 160,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            // I-clip ang image para makuha ang circular shape
                            child: ClipOval(
                              child: Image.asset(
                                'assets/images/logo.png',
                                fit: BoxFit
                                    .cover, // I-adjust unsaon pag-fit ang logo
                                // Para makuha ang white/transparent effect:
                                color: isDark
                                    ? AppTheme.lightGreen.withOpacity(0.9)
                                    : null,
                                colorBlendMode: isDark
                                    ? BlendMode.modulate
                                    : null,
                              ),
                            ),
                          ),

                          const SizedBox(height: 30),

                          // App Title - white text sa green area
                          Text(
                            'AIgrove',
                            style: TextStyle(
                              fontSize: 52,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? AppTheme.lightGreen
                                  : topTextColor,
                              letterSpacing: 2,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.5),
                                  offset: const Offset(0, 3),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Subtitle - with better contrast
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.white.withOpacity(0.1)
                                  : Colors.black.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.4),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              'Discover Mangroves with AI',
                              style: TextStyle(
                                fontSize: 16,
                                color: isDark ? topTextColor : topTextColor,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.5,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withOpacity(0.3),
                                    offset: const Offset(0, 1),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 50),

                          // Main Description - transition area, gamiton ang white pa
                          Text(
                            'AIgrove lets you explore the amazing world of mangroves in the Caraga Region with just a snap!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              color: isDark ? topTextColor : topTextColor,
                              height: 1.6,
                              fontWeight: FontWeight.w600,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.4),
                                  offset: const Offset(0, 2),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Secondary description - transition to dark text
                          Text(
                            'Using artificial intelligence, the app instantly identifies mangrove species, shows where they grow, and explains how they protect coasts, store carbon, and support marine life.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 15,
                              color: isDark
                                  ? topTextColor.withOpacity(0.9)
                                  : const Color(0xFF1B4332),
                              height: 1.5,
                              fontWeight: FontWeight.w400,
                              shadows: isDark
                                  ? [
                                      Shadow(
                                        color: Colors.black.withOpacity(0.3),
                                        offset: const Offset(0, 1),
                                        blurRadius: 4,
                                      ),
                                    ]
                                  : null,
                            ),
                          ),

                          const SizedBox(height: 40),

                          // Feature Cards Grid - 2x2 layout with fixed overflow
                          GridView.count(
                            crossAxisCount: 2,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                            childAspectRatio: 0.95,
                            children: [
                              _buildFeatureCard(
                                Icons.camera_alt_rounded,
                                'Scan',
                                'Instant species identification',
                                isDark,
                                bottomTextColor,
                              ),
                              _buildFeatureCard(
                                Icons.map_rounded,
                                'Maps',
                                'Real-time location data',
                                isDark,
                                bottomTextColor,
                              ),
                              _buildFeatureCard(
                                Icons.quiz_rounded,
                                'Quizzes',
                                'Fun learning challenges',
                                isDark,
                                bottomTextColor,
                              ),
                              _buildFeatureCard(
                                Icons.dashboard_rounded,
                                'Dashboard',
                                'Interactive insights',
                                isDark,
                                bottomTextColor,
                              ),
                            ],
                          ),

                          const SizedBox(height: 40),

                          // Bottom tagline - dark text sa light gradient area
                          Text(
                            'Learning about mangroves has never been this easy and exciting!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 15,
                              color: isDark
                                  ? topTextColor.withOpacity(0.85)
                                  : bottomTextColor,
                              fontStyle: FontStyle.italic,
                              height: 1.4,
                              fontWeight: FontWeight.w400,
                              shadows: isDark
                                  ? [
                                      Shadow(
                                        color: Colors.black.withOpacity(0.3),
                                        offset: const Offset(0, 1),
                                        blurRadius: 4,
                                      ),
                                    ]
                                  : null,
                            ),
                          ),

                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Floating Get Started Button
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        (isDark ? AppTheme.darkGreen : AppTheme.backgroundLight)
                            .withOpacity(0.3),
                        (isDark ? AppTheme.darkGreen : AppTheme.backgroundLight)
                            .withOpacity(0.95),
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 20,
                  ),
                  child: ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, '/login'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark
                          ? AppTheme.lightGreen
                          : AppTheme.primaryGreen,
                      foregroundColor: isDark ? Colors.black : Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 8,
                      shadowColor:
                          (isDark ? AppTheme.lightGreen : AppTheme.primaryGreen)
                              .withOpacity(0.5),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Get Started',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                            color: isDark ? Colors.black : Colors.white,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          Icons.arrow_forward_rounded,
                          color: isDark ? Colors.black : Colors.white,
                          size: 24,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget para sa feature cards - with adaptive text color
  Widget _buildFeatureCard(
    IconData icon,
    String title,
    String description,
    bool isDark,
    Color textColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.1)
            : Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.4)
              : textColor.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isDark ? AppTheme.lightGreen : AppTheme.primaryGreen,
            size: 38,
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: TextStyle(
              color: isDark ? Colors.white : textColor,
              fontSize: 15,
              fontWeight: FontWeight.bold,
              shadows: isDark
                  ? [
                      Shadow(
                        color: Colors.black.withOpacity(0.3),
                        offset: const Offset(0, 1),
                        blurRadius: 3,
                      ),
                    ]
                  : null,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDark
                  ? Colors.white.withOpacity(0.9)
                  : textColor.withOpacity(0.8),
              fontSize: 11,
              height: 1.3,
              fontWeight: FontWeight.w400,
              shadows: isDark
                  ? [
                      Shadow(
                        color: Colors.black.withOpacity(0.3),
                        offset: const Offset(0, 1),
                        blurRadius: 2,
                      ),
                    ]
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}
