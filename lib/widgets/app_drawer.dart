import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../pages/profile_page.dart';
import '../pages/history_page.dart'; // I-add para direct navigation
import '../pages/about_page.dart'; // I-add para direct navigation
import '../services/user_service.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        // I-add ang SafeArea para dili ma-overlap sa status bar
        child: Consumer<UserService>(
          // Wrap with Consumer
          builder: (context, userService, child) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Clickable profile header with avatar and name
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.green.shade700, Colors.green.shade800],
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _navigateToProfile(context),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            // Avatar nga naka-handle sa tanan posibleng cases
                            CircleAvatar(
                              radius: 32,
                              backgroundColor: Colors.white,
                              backgroundImage: userService.avatarUrl != null
                                  ? NetworkImage(userService.avatarUrl!)
                                  : (userService.avatarImage != null
                                            ? FileImage(
                                                userService.avatarImage!,
                                              )
                                            : null)
                                        as ImageProvider?,
                              child:
                                  (userService.avatarUrl == null &&
                                      userService.avatarImage == null)
                                  ? const Icon(
                                      Icons.person,
                                      size: 40,
                                      color: Colors.green,
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    userService.userName.isEmpty
                                        ? "AIGrove User"
                                        : userService.userName,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white24,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Text(
                                      'View Profile',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.white70,
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                const Divider(height: 1),

                // Menu items with improved styling
                _buildDrawerItem(
                  context,
                  icon: FontAwesomeIcons.clockRotateLeft,
                  title: 'History',
                  onTap: () => _navigateToHistory(context),
                ),
                _buildDrawerItem(
                  context,
                  icon: FontAwesomeIcons.gear,
                  title: 'Settings',
                  onTap: () => _navigateToSettings(context),
                ),
                _buildDrawerItem(
                  context,
                  icon: FontAwesomeIcons.circleInfo,
                  title: 'About',
                  onTap: () => _navigateToAbout(context),
                ),

                const Spacer(),

                // Logout button with confirmation
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _handleLogout(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 2,
                      ),
                      icon: const Icon(Icons.logout, size: 20),
                      label: const Text(
                        'Logout',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(8),
        ),
        child: FaIcon(icon, color: Colors.green.shade700, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey,
      ),
      onTap: () {
        Navigator.pop(context); // Close drawer first
        onTap();
      },
    );
  }

  // Navigation methods with fallback for direct navigation

  void _navigateToProfile(BuildContext context) {
    try {
      Navigator.pushNamed(context, '/profile');
    } catch (e) {
      debugPrint('Error using named route for profile: $e');
      // Fallback to direct navigation
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ProfilePage()),
      );
    }
  }

  void _navigateToHistory(BuildContext context) {
    try {
      // I-try una ang named route
      Navigator.pushNamed(context, '/history');
    } catch (e) {
      debugPrint('Error using named route for history: $e');
      // Fallback sa direct navigation using import
      try {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const HistoryPage()),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'History page not found. Please check implementation.',
            ),
          ),
        );
      }
    }
  }

  void _navigateToSettings(BuildContext context) {
    try {
      Navigator.pushNamed(context, '/settings');
    } catch (e) {
      debugPrint('Error navigating to settings: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Settings page not available')),
      );
    }
  }

  void _navigateToAbout(BuildContext context) {
    try {
      // I-try una ang named route
      Navigator.pushNamed(context, '/about');
    } catch (e) {
      debugPrint('Error using named route for about: $e');
      // Fallback sa direct navigation using import
      try {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AboutPage()),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('About page not found. Please check implementation.'),
          ),
        );
      }
    }
  }

  // Update logout handling to use UserService
  void _handleLogout(BuildContext context) {
    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Logout'),
          content: const Text('Are you sure you want to logout?'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                _performLogout(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  void _performLogout(BuildContext context) async {
    try {
      await context.read<UserService>().signOut();
      if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/landing',
          (route) => false,
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error sa pag-logout: $e')));
      }
    }
  }
}
