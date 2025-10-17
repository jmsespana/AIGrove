import 'package:aigrove/services/profile_service.dart';
import 'package:aigrove/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:io';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController _bioController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    // I-clear ang image cache sa start
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAllProfileData();
    });
  }

  // I-load ang user profile data
  Future<void> _loadAllProfileData() async {
    setState(() => _isLoading = true);
    try {
      await Future.wait([
        context.read<UserService>().loadUserProfile(),
        context.read<ProfileService>().loadProfileStats(),
        context.read<ProfileService>().loadRecentActivity(limit: 10),
      ]);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sa pag-load sa profile: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // I-upload ang profile picture
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 75,
      );

      if (!mounted) return;

      if (pickedFile != null) {
        setState(() => _isLoading = true);
        final File imageFile = File(pickedFile.path);

        debugPrint("Selected image: ${pickedFile.path}");

        final userService = context.read<UserService>();
        await userService.updateAvatar(imageFile);

        debugPrint("Uploaded avatar URL: ${userService.avatarUrl}");

        PaintingBinding.instance.imageCache.clear();
        PaintingBinding.instance.imageCache.clearLiveImages();

        setState(() {});

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile picture na-update na!')),
        );
      }
    } catch (e) {
      debugPrint("Error uploading image: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sa pag-upload: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // I-get ang current theme brightness
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? Colors.grey.shade900 : Colors.grey.shade50;
    final cardColor = isDarkMode ? Colors.grey.shade800 : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final subtitleColor = isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700;

    return SafeArea(
      top: true,
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: Consumer<UserService>(
          builder: (context, userService, child) {
            if (_isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return Column(
              children: [
                // Fixed Upper Part - Profile Header ug Stats with gradient and border radius
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isDarkMode 
                        ? [
                            Colors.green.shade900,
                            Colors.green.shade800,
                            Colors.green.shade700,
                          ]
                        : [
                            Colors.green.shade600,
                            Colors.green.shade700,
                            Colors.green.shade800,
                          ],
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                    boxShadow: [
                      BoxShadow(
                        // ignore: deprecated_member_use
                        color: Colors.black.withOpacity(0.1),
                        spreadRadius: 2,
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Profile Header
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            // Back button
                            IconButton(
                              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                              onPressed: () => Navigator.pop(context),
                            ),
                            const Spacer(),
                          ],
                        ),
                      ),

                      // Profile Picture ug User Info
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          children: [
                            // Profile Picture
                            Stack(
                              alignment: Alignment.bottomRight,
                              children: [
                                Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 4,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        // ignore: deprecated_member_use
                                        color: Colors.black.withOpacity(0.2),
                                        spreadRadius: 2,
                                        blurRadius: 8,
                                      ),
                                    ],
                                  ),
                                  child: Builder(
                                    builder: (context) {
                                      final String? avatarUrl = userService.avatarUrl;

                                      if (avatarUrl != null && avatarUrl.isNotEmpty) {
                                        return CircleAvatar(
                                          radius: 50,
                                          backgroundColor: Colors.grey[300],
                                          backgroundImage: NetworkImage(avatarUrl),
                                          onBackgroundImageError: (e, st) {
                                            debugPrint("Failed to load image: $e");
                                          },
                                        );
                                      } else {
                                        return const CircleAvatar(
                                          radius: 50,
                                          backgroundColor: Colors.grey,
                                          child: Icon(
                                            Icons.person,
                                            size: 50,
                                            color: Colors.white,
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                ),
                                FloatingActionButton.small(
                                  onPressed: _pickImage,
                                  backgroundColor: Colors.green.shade600,
                                  elevation: 4,
                                  child: const Icon(Icons.camera_alt, size: 16),
                                ),
                              ],
                            ),
                            const SizedBox(width: 16),
                            // User Info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    userService.userName,
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black26,
                                          offset: Offset(0, 2),
                                          blurRadius: 4,
                                        ),
                                      ],
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    userService.userEmail,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black26,
                                          offset: Offset(0, 1),
                                          blurRadius: 2,
                                        ),
                                      ],
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Stats Row
                      Container(
                        margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: cardColor,
                          boxShadow: [
                            BoxShadow(
                              // ignore: deprecated_member_use
                              color: Colors.black.withOpacity(0.15),
                              spreadRadius: 2,
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildStatColumn(
                              'Total Scans',
                              Icons.qr_code_scanner,
                              Colors.green,
                              textColor,
                            ),
                            Container(
                              height: 50,
                              width: 2,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: isDarkMode 
                                    ? [Colors.grey.shade700, Colors.grey.shade600]
                                    : [Colors.grey.shade300, Colors.grey.shade400],
                                ),
                              ),
                            ),
                            _buildStatColumn(
                              'Challenges',
                              Icons.emoji_events,
                              Colors.amber,
                              textColor,
                            ),
                            Container(
                              height: 50,
                              width: 2,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: isDarkMode 
                                    ? [Colors.grey.shade700, Colors.grey.shade600]
                                    : [Colors.grey.shade300, Colors.grey.shade400],
                                ),
                              ),
                            ),
                            _buildStatColumn(
                              'Points',
                              Icons.stars,
                              Colors.blue,
                              textColor,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // I-add ang spacing between profile ug recent activity
                const SizedBox(height: 20),

                // Scrollable Recent Activity Part - Ani lang ang ma-scroll
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _loadAllProfileData,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            // ignore: deprecated_member_use
                            color: Colors.black.withOpacity(0.08),
                            spreadRadius: 1,
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Recent Activity Header (fixed sa top sa container)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Recent Activity',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: textColor,
                                  ),
                                ),
                                // Uncomment ni kung gusto nimo ang View All button
                                // TextButton(
                                //   onPressed: () {
                                //     Navigator.pushNamed(context, '/history');
                                //   },
                                //   child: Text(
                                //     'View All',
                                //     style: TextStyle(
                                //       color: isDarkMode ? Colors.green.shade300 : Colors.green.shade700,
                                //       fontWeight: FontWeight.w600,
                                //     ),
                                //   ),
                                // ),
                              ],
                            ),
                          ),

                          // Scrollable Activity List - Ani lang ang ma-scroll
                          Expanded(
                            child: Consumer<ProfileService>(
                              builder: (context, profileService, child) {
                                final activities = profileService.recentActivity;

                                if (activities.isEmpty) {
                                  return Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(32.0),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.history,
                                            size: 64,
                                            // ignore: deprecated_member_use
                                            color: subtitleColor.withOpacity(0.5),
                                          ),
                                          const SizedBox(height: 16),
                                          Text(
                                            'No recent activity',
                                            style: TextStyle(
                                              color: subtitleColor,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Your quiz history will appear here',
                                            style: TextStyle(
                                              // ignore: deprecated_member_use
                                              color: subtitleColor.withOpacity(0.7),
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }

                                return ListView.separated(
                                  padding: const EdgeInsets.only(bottom: 16, top: 8),
                                  itemCount: activities.length,
                                  separatorBuilder: (context, index) => Divider(
                                    height: 1,
                                    indent: 70,
                                    color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300,
                                  ),
                                  itemBuilder: (context, index) {
                                    final activity = activities[index];
                                    return _buildActivityItem(
                                      activity,
                                      isDarkMode,
                                      textColor,
                                      subtitleColor,
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20), // Bottom spacing
              ],
            );
          },
        ),
      ),
    );
  }

  // I-build ang activity item with theme support
  Widget _buildActivityItem(
    Map<String, dynamic> activity,
    bool isDarkMode,
    Color textColor,
    Color subtitleColor,
  ) {
    final activityType = activity['activity_type'] as String? ?? 'unknown';
    final title = activity['title'] as String? ?? 'No title';
    final description = activity['description'] as String?;

    DateTime createdAt;
    try {
      createdAt = DateTime.parse(activity['created_at'] ?? DateTime.now().toIso8601String());
    } catch (e) {
      createdAt = DateTime.now();
    }

    final timeAgo = _getTimeAgo(createdAt);

    // I-determine ang icon ug color base sa activity type
    IconData icon;
    Color iconColor;

    switch (activityType) {
      case 'quiz':
        icon = Icons.quiz;
        iconColor = isDarkMode ? Colors.blue.shade300 : Colors.blue.shade600;
        break;
      case 'scan':
        icon = Icons.camera_alt;
        iconColor = isDarkMode ? Colors.green.shade300 : Colors.green.shade600;
        break;
      case 'achievement':
        icon = Icons.emoji_events;
        iconColor = isDarkMode ? Colors.amber.shade300 : Colors.amber.shade700;
        break;
      default:
        icon = Icons.info;
        iconColor = isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600;
    }

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          // ignore: deprecated_member_use
          color: iconColor.withOpacity(isDarkMode ? 0.2 : 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: iconColor, size: 24),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          color: textColor,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (description != null && description.isNotEmpty)
            Text(
              description,
              style: TextStyle(
                fontSize: 12,
                color: subtitleColor,
              ),
            ),
          const SizedBox(height: 2),
          Text(
            timeAgo,
            style: TextStyle(
              fontSize: 11,
              // ignore: deprecated_member_use
              color: subtitleColor.withOpacity(0.7),
            ),
          ),
        ],
      ),
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  // Helper method para sa "time ago" format
  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} month${(difference.inDays / 30).floor() > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  // I-build ang stat column with theme support
  Widget _buildStatColumn(String label, IconData icon, Color color, Color textColor) {
    return Consumer<ProfileService>(
      builder: (context, profileService, child) {
        String displayValue = '0';
        switch (label) {
          case 'Total Scans':
            displayValue = profileService.totalScans.toString();
            break;
          case 'Challenges':
            displayValue = profileService.challengesCompleted.toString();
            break;
          case 'Points':
            displayValue = profileService.points.toString();
            break;
        }
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 28, color: color),
            const SizedBox(height: 6),
            Text(
              displayValue,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                // ignore: deprecated_member_use
                color: textColor.withOpacity(0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _bioController.dispose();
    super.dispose();
  }
}
