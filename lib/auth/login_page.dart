// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/user_service.dart';
import '../theme/app_theme.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool rememberMe = false;
  bool loading = false;
  bool _passwordVisible = false;

  // I-validate ang form before login
  Future<void> _login() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    setState(() => loading = true);
    try {
      // Gamiton ang UserService instead of direct Supabase call
      final userService = Provider.of<UserService>(context, listen: false);
      await userService.login(emailController.text, passwordController.text);

      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/home',
        (route) => false, // I-remove ang tanan nga previous routes
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Define text colors base sa gradient position
    final Color topTextColor = Colors.white; // White text sa green gradient
    final Color bottomTextColor = isDark
        ? Colors.white
        : const Color(0xFF2D5016); // Dark text sa light gradient

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
              // Login form
              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 24,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // App icon - white sa taas
                      Container(
                        width: 160,
                        height: 160,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.25),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 12,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        // I-clip para makuha ang circular shape
                        child: ClipOval(
                          child: Padding(
                            padding: const EdgeInsets.all(
                              4,
                            ), // Spacing sa sulod
                            child: Image.asset(
                              'assets/images/logo.png', // Imong logo diri
                              fit: BoxFit.contain, // Para dili ma-crop ang logo
                              // Optional: I-apply ang color tint para mu-match sa theme
                              color: isDark
                                  ? AppTheme.lightGreen.withOpacity(0.9)
                                  : null,
                              colorBlendMode: isDark
                                  ? BlendMode.modulate
                                  : null,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Welcome text - white sa green area
                      Text(
                        "Welcome Back",
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppTheme.lightGreen : topTextColor,
                          letterSpacing: 1,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.4),
                              offset: const Offset(0, 2),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        "Sign in to continue exploring",
                        style: TextStyle(
                          fontSize: 16,
                          color: isDark
                              ? topTextColor.withOpacity(0.9)
                              : topTextColor,
                          fontWeight: FontWeight.w400,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.3),
                              offset: const Offset(0, 1),
                              blurRadius: 3,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 48),

                      // Email field - naa na sa light gradient area
                      _buildTextField(
                        controller: emailController,
                        label: 'Email Address',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        isDark: isDark,
                        textColor: isDark ? topTextColor : bottomTextColor,
                      ),

                      const SizedBox(height: 16),

                      // Password field
                      _buildTextField(
                        controller: passwordController,
                        label: 'Password',
                        icon: Icons.lock_outlined,
                        obscureText: !_passwordVisible,
                        isDark: isDark,
                        textColor: isDark ? topTextColor : bottomTextColor,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _passwordVisible
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: isDark
                                ? topTextColor.withOpacity(0.8)
                                : bottomTextColor.withOpacity(0.7),
                          ),
                          onPressed: () {
                            setState(() {
                              _passwordVisible = !_passwordVisible;
                            });
                          },
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Remember me checkbox - aligned to left
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 24,
                            width: 24,
                            child: Checkbox(
                              value: rememberMe,
                              onChanged: (val) =>
                                  setState(() => rememberMe = val!),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                              fillColor: MaterialStateProperty.resolveWith((
                                states,
                              ) {
                                if (states.contains(MaterialState.selected)) {
                                  return isDark
                                      ? Colors.white
                                      : AppTheme.primaryGreen;
                                }
                                return Colors.transparent;
                              }),
                              checkColor: isDark
                                  ? AppTheme.primaryGreen
                                  : Colors.white,
                              side: BorderSide(
                                color: isDark
                                    ? topTextColor.withOpacity(0.7)
                                    : bottomTextColor.withOpacity(0.5),
                                width: 2,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "Remember Me",
                            style: TextStyle(
                              color: isDark ? topTextColor : bottomTextColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
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

                      const SizedBox(height: 32),

                      // Login button - gamit ang theme colors
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: loading ? null : _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isDark
                                ? AppTheme.lightGreen
                                : AppTheme.primaryGreen,
                            foregroundColor: isDark
                                ? Colors.black
                                : Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 8,
                            shadowColor:
                                (isDark
                                        ? AppTheme.lightGreen
                                        : AppTheme.primaryGreen)
                                    .withOpacity(0.4),
                          ),
                          child: loading
                              ? SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      isDark ? Colors.black : Colors.white,
                                    ),
                                  ),
                                )
                              : Text(
                                  "Sign In",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1,
                                    color: isDark ? Colors.black : Colors.white,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Divider - adaptive color
                      Row(
                        children: [
                          Expanded(
                            child: Divider(
                              color: isDark
                                  ? topTextColor.withOpacity(0.5)
                                  : bottomTextColor.withOpacity(0.3),
                              thickness: 1.5,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              "OR",
                              style: TextStyle(
                                color: isDark
                                    ? topTextColor.withOpacity(0.85)
                                    : bottomTextColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              color: isDark
                                  ? topTextColor.withOpacity(0.5)
                                  : bottomTextColor.withOpacity(0.3),
                              thickness: 1.5,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Sign up link - dark text sa bottom
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have an account? ",
                            style: TextStyle(
                              color: isDark
                                  ? topTextColor.withOpacity(0.9)
                                  : bottomTextColor,
                              fontSize: 15,
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
                          TextButton(
                            onPressed: () =>
                                Navigator.pushNamed(context, '/register'),
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              "Sign Up",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? AppTheme.lightGreen
                                    : AppTheme.primaryGreen,
                                fontSize: 15,
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
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method para sa text fields - with adaptive text color
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isDark,
    required Color textColor,
    bool obscureText = false,
    TextInputType? keyboardType,
    Widget? suffixIcon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.12)
            : Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.4)
              : textColor.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: TextStyle(color: textColor, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: textColor.withOpacity(0.7),
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: Icon(
            icon,
            color: isDark ? AppTheme.lightGreen : textColor,
          ),
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 20,
          ),
        ),
      ),
    );
  }
}
