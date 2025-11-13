import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../theme/app_theme.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        elevation: 2,
        // Dili na kinahanglan ang drawer, automatic nang i-show ang back button
      ),
      body: Container(
        decoration: AppTheme.getGradientBackground(isDark: isDark),
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Help & Support Section
            _buildSectionHeader('Help & Support', isDark),
            const SizedBox(height: 8),
            _buildSettingsCard(
              isDark: isDark,
              children: [
                _buildMenuTile(
                  icon: FontAwesomeIcons.circleQuestion,
                  title: 'FAQ',
                  subtitle: 'Frequently asked questions',
                  onTap: () => _showFAQDialog(context, isDark),
                  isDark: isDark,
                ),
                const Divider(height: 1),
                _buildMenuTile(
                  icon: FontAwesomeIcons.fileLines,
                  title: 'Terms & Conditions',
                  subtitle: 'Legal documents and policies',
                  onTap: () => _showTermsDialog(context, isDark),
                  isDark: isDark,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Helper method para sa section header
  Widget _buildSectionHeader(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: isDark ? AppTheme.lightGreen : AppTheme.darkGreen,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  // Helper method para sa settings card container
  Widget _buildSettingsCard({
    required bool isDark,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
      child: Column(children: children),
    );
  }

  // Helper method para sa menu tile
  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDark
              // ignore: deprecated_member_use
              ? AppTheme.lightGreen.withOpacity(0.1)
              // ignore: deprecated_member_use
              : AppTheme.primaryGreen.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: FaIcon(
          icon,
          color: isDark ? AppTheme.lightGreen : AppTheme.darkGreen,
          size: 20,
        ),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  // Dialog para sa FAQ
  void _showFAQDialog(BuildContext context, bool isDark) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          constraints: const BoxConstraints(maxHeight: 600),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [AppTheme.darkGreen, AppTheme.primaryGreen]
                        : [AppTheme.primaryGreen, AppTheme.lightGreen],
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    const FaIcon(
                      FontAwesomeIcons.circleQuestion,
                      color: Colors.white,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Frequently Asked Questions',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),

              // FAQ Content
              Flexible(
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  shrinkWrap: true,
                  children: [
                    _buildFAQItem(
                      question: 'What is AIGrove?',
                      answer:
                          'AIGrove is an eco-friendly AI assistant that helps people become more environment-conscious through AI-powered features.',
                      isDark: isDark,
                    ),
                    _buildFAQItem(
                      question: 'How do I scan a plant?',
                      answer:
                          'Simply tap the Scan icon in the navigation bar and point your camera at the plant. The AI will automatically identify the species and provide details.',
                      isDark: isDark,
                    ),
                    _buildFAQItem(
                      question: 'Is AIGrove free to use?',
                      answer:
                          'Yes! AIGrove is completely free to use for everyone. We want environmental awareness to be accessible to all.',
                      isDark: isDark,
                    ),
                    _buildFAQItem(
                      question: 'How do I update my profile?',
                      answer:
                          'Click your profile picture in the drawer or go to the Profile page and tap the Edit icon to update your information.',
                      isDark: isDark,
                    ),
                    _buildFAQItem(
                      question: 'What is the purpose of the Challenge feature?',
                      answer:
                          'The Challenge feature helps you participate in eco-friendly activities and earn points while helping the environment.',
                      isDark: isDark,
                    ),
                  ],
                ),
              ),

              // Close Button
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark
                          ? AppTheme.lightGreen
                          : AppTheme.primaryGreen,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Close',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
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

  // Dialog para sa Terms & Conditions
  void _showTermsDialog(BuildContext context, bool isDark) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          constraints: const BoxConstraints(maxHeight: 600),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [AppTheme.darkGreen, AppTheme.primaryGreen]
                        : [AppTheme.primaryGreen, AppTheme.lightGreen],
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    const FaIcon(
                      FontAwesomeIcons.fileLines,
                      color: Colors.white,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Terms & Conditions',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // Terms Content
              Flexible(
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  shrinkWrap: true,
                  children: [
                    _buildTermsSection(
                      title: '1. Use of Service',
                      content:
                          'By using AIGrove, you agree to use the app for legal and eco-friendly purposes only. You may not use the app to harm the environment or others.',
                      isDark: isDark,
                    ),
                    _buildTermsSection(
                      title: '2. User Account',
                      content:
                          'You are responsible for maintaining the confidentiality of your account credentials. You may not share your account with other users.',
                      isDark: isDark,
                    ),
                    _buildTermsSection(
                      title: '3. Privacy and Data',
                      content:
                          'Your personal information and scan history are securely stored. We will not share your data with third parties without your permission.',
                      isDark: isDark,
                    ),
                    _buildTermsSection(
                      title: '4. AI Accuracy',
                      content:
                          'AI plant identification is based on machine learning and may not be 100% accurate. Use it as a reference only and not for medical or critical purposes.',
                      isDark: isDark,
                    ),
                    _buildTermsSection(
                      title: '5. Updates and Changes',
                      content:
                          'We may modify these Terms & Conditions at any time. Continued use of the app after changes means you accept the new terms.',
                      isDark: isDark,
                    ),
                    _buildTermsSection(
                      title: '6. Termination',
                      content:
                          'We may suspend or terminate your access if you violate these terms. You may also delete your account at any time.',
                      isDark: isDark,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Last updated: November 10, 2025',
                      style: TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: isDark ? Colors.white54 : Colors.black54,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              // Close Button
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark
                          ? AppTheme.lightGreen
                          : AppTheme.primaryGreen,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'I Agree',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
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

  // Helper widget para sa FAQ item
  Widget _buildFAQItem({
    required String question,
    required String answer,
    required bool isDark,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.question_answer,
                size: 20,
                color: isDark ? AppTheme.lightGreen : AppTheme.darkGreen,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  question,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppTheme.lightGreen : AppTheme.darkGreen,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 28),
            child: Text(
              answer,
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper widget para sa Terms section
  Widget _buildTermsSection({
    required String title,
    required String content,
    required bool isDark,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? AppTheme.lightGreen : AppTheme.darkGreen,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
