import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart'; // Add this import
import '../pages/profile_page.dart';
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
                        padding: const EdgeInsets.all(
                          16,
                        ), // I-adjust ang padding kay naa na'y SafeArea
                        child: Row(
                          children: [
                            // Updated Avatar handling
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
                                  // User name lang, wala na'y email
                                  Text(
                                    userService.userName,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 8),
                                  // View Profile button
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

                // Divider
                const Divider(height: 1),

                // List items with improved styling
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

  // Default navigation methods (you can customize these)
  void _navigateToProfile(BuildContext context) {
    Navigator.pop(context); // Close the drawer first
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProfilePage()),
    );
  }

  void _navigateToHistory(BuildContext context) {
    Navigator.pushNamed(context, '/history');
  }

  void _navigateToSettings(BuildContext context) {
    Navigator.pushNamed(context, '/settings');
  }

  void _navigateToAbout(BuildContext context) {
    Navigator.pushNamed(context, '/about');
  }

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
                // Add your actual logout logic here
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

  // Update logout handling to use UserService
  void _performLogout(BuildContext context) async {
    try {
      await context.read<UserService>().signOut();
      if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
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

// Example usage in your app:
/*
AppDrawer(
  userName: 'John Doe',
  userEmail: 'john.doe@example.com',
  avatarImagePath: 'assets/user_avatar.png',
  onProfileTap: () {
    // Custom profile navigation
  },
  onHistoryTap: () {
    // Custom history navigation
  },
  // ... other callbacks
)
*/
