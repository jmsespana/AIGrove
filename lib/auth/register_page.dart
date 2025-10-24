// pages/register_page.dart
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/app_theme.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final nameController = TextEditingController();
  final lastnameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  bool loading = false;
  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;
  String _selectedRole = 'user';

  // I-validate ang email
  bool isValidEmail(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);
  }

  // I-check kung strong ba ang password
  bool isPasswordStrong(String password) {
    return password.length >= 8 && // min length
        RegExp(r'[A-Z]').hasMatch(password) && // uppercase
        RegExp(r'[a-z]').hasMatch(password) && // lowercase
        RegExp(r'[0-9]').hasMatch(password); // numbers
  }

  Future<void> _register() async {
    // I-validate ang form before registration
    if (nameController.text.isEmpty ||
        lastnameController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Palihug fill-up ang tanang fields')),
      );
      return;
    }

    if (!isValidEmail(emailController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Palihug i-enter ang valid nga email')),
      );
      return;
    }

    if (!isPasswordStrong(passwordController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Ang password kinahanglan 8 ka characters ug naay uppercase, lowercase, ug numbers',
          ),
        ),
      );
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Password doesn\'t match!')));
      return;
    }

    setState(() => loading = true);

    try {
      final response = await Supabase.instance.client.auth.signUp(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
        data: {
          'first_name': nameController.text.trim(),
          'last_name': lastnameController.text.trim(),
          'role': _selectedRole,
        },
      );

      if (!mounted) return;

      setState(() => loading = false);

      if (response.user != null) {
        // I-initialize ang user data pinaagi sa pag-insert sa profile row
        try {
          await Supabase.instance.client.from('profiles').insert({
            'id': response.user!.id,
            'first_name': nameController.text.trim(),
            'last_name': lastnameController.text.trim(),
            'email': emailController.text.trim(),
            'role': _selectedRole,
          });
        } catch (e) {
          // Ignore profile insert errors, ang registration mismo successful na
        }

        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Registration successful! Please login with your credentials.',
            ),
            duration: Duration(seconds: 4),
          ),
        );

        Future.delayed(const Duration(seconds: 2), () {
          if (!mounted) return;
          Navigator.pushReplacementNamed(context, '/login');
        });
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Registration failed')));
      }
    } catch (error) {
      if (!mounted) return;
      setState(() => loading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${error.toString()}')));
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    lastnameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Define text colors based sa gradient position
    final Color topTextColor = Colors.white; // White text sa green gradient
    final Color bottomTextColor = isDark
        ? Colors.black87
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
              // Register form
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
                        width: 80,
                        height: 80,
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
                        child: Icon(
                          Icons.eco,
                          size: 45,
                          color: isDark ? AppTheme.lightGreen : topTextColor,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Welcome text - white sa green area
                      Text(
                        "Create Account",
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppTheme.lightGreen : topTextColor,
                          letterSpacing: 1,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.3),
                              offset: const Offset(0, 2),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        "Join us in exploring mangroves",
                        style: TextStyle(
                          fontSize: 16,
                          color: isDark
                              ? Colors.white.withOpacity(0.9)
                              : topTextColor,
                          fontWeight: FontWeight.w400,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.2),
                              offset: const Offset(0, 1),
                              blurRadius: 3,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 40),

                      // First Name field - naa na sa transition area, gamiton ang semi-dark
                      _buildTextField(
                        controller: nameController,
                        label: 'First Name',
                        icon: Icons.person_outline,
                        isDark: isDark,
                        textColor: isDark
                            ? topTextColor
                            : const Color(0xFF1B4332),
                      ),

                      const SizedBox(height: 16),

                      // Last Name field
                      _buildTextField(
                        controller: lastnameController,
                        label: 'Last Name',
                        icon: Icons.person_outline,
                        isDark: isDark,
                        textColor: isDark
                            ? topTextColor
                            : const Color(0xFF1B4332),
                      ),

                      const SizedBox(height: 16),

                      // Email field
                      _buildTextField(
                        controller: emailController,
                        label: 'Email Address',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        isDark: isDark,
                        textColor: isDark ? topTextColor : bottomTextColor,
                      ),

                      const SizedBox(height: 16),

                      // Role Selection Dropdown - dark text sa light gradient
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withOpacity(0.12)
                              : Colors.white.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isDark
                                ? Colors.white.withOpacity(0.4)
                                : bottomTextColor.withOpacity(0.3),
                            width: 1.5,
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: _selectedRole,
                            dropdownColor: isDark
                                ? AppTheme.darkGreen
                                : Colors.white,
                            style: TextStyle(
                              color: isDark ? topTextColor : bottomTextColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                            icon: Icon(
                              Icons.arrow_drop_down,
                              color: isDark
                                  ? AppTheme.lightGreen
                                  : bottomTextColor,
                            ),
                            items: [
                              DropdownMenuItem(
                                value: 'user',
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.person,
                                      color: isDark
                                          ? topTextColor
                                          : bottomTextColor,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 12),
                                    Text('User'),
                                  ],
                                ),
                              ),
                              DropdownMenuItem(
                                value: 'admin',
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.admin_panel_settings,
                                      color: isDark
                                          ? topTextColor
                                          : bottomTextColor,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 12),
                                    Text('Admin'),
                                  ],
                                ),
                              ),
                            ],
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                setState(() {
                                  _selectedRole = newValue;
                                });
                              }
                            },
                          ),
                        ),
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

                      // Confirm Password field
                      _buildTextField(
                        controller: confirmPasswordController,
                        label: 'Confirm Password',
                        icon: Icons.lock_outlined,
                        obscureText: !_confirmPasswordVisible,
                        isDark: isDark,
                        textColor: isDark ? topTextColor : bottomTextColor,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _confirmPasswordVisible
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: isDark
                                ? topTextColor.withOpacity(0.8)
                                : bottomTextColor.withOpacity(0.7),
                          ),
                          onPressed: () {
                            setState(() {
                              _confirmPasswordVisible =
                                  !_confirmPasswordVisible;
                            });
                          },
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Register button - gamit ang theme colors
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: loading ? null : _register,
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
                                  "Sign Up",
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
                                  ? Colors.white.withOpacity(0.5)
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
                                  ? Colors.white.withOpacity(0.5)
                                  : bottomTextColor.withOpacity(0.3),
                              thickness: 1.5,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Login link - dark text sa bottom white gradient
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Already have an account? ",
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
                                Navigator.pushNamed(context, '/login'),
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              "Login",
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
