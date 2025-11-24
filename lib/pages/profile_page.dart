// ignore_for_file: deprecated_member_use

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
        SnackBar(content: Text('Error lloading profile: $e')),
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error sa pag-upload: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // I-get ang current theme brightness
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode
        ? Colors.grey.shade900
        : Colors.grey.shade50;
    final cardColor = isDarkMode ? Colors.grey.shade800 : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final subtitleColor = isDarkMode
        ? Colors.grey.shade400
        : Colors.grey.shade700;

    return SafeArea(
      top: true,
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: Consumer<UserService>(
          builder: (context, userService, child) {
            if (_isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return RefreshIndicator(
              onRefresh: _loadAllProfileData,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  // Profile Header - Minimalist design
                  SliverToBoxAdapter(
                    child: Container(
                      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: isDarkMode
                              ? [Colors.green.shade800, Colors.green.shade900]
                              : [Colors.green.shade600, Colors.green.shade700],
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color:
                                (isDarkMode
                                        ? Colors.green.shade900
                                        : Colors.green.shade600)
                                    .withOpacity(0.3),
                            spreadRadius: 0,
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Back button sa top
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.arrow_back_ios_new,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Profile Picture - Mas dako ug elevated
                          Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.3),
                                      spreadRadius: 0,
                                      blurRadius: 20,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: Builder(
                                  builder: (context) {
                                    final String? avatarUrl =
                                        userService.avatarUrl;

                                    if (avatarUrl != null &&
                                        avatarUrl.isNotEmpty) {
                                      return CircleAvatar(
                                        radius: 60,
                                        backgroundColor: Colors.grey[300],
                                        backgroundImage: NetworkImage(
                                          avatarUrl,
                                        ),
                                        onBackgroundImageError: (e, st) {
                                          debugPrint(
                                            "Failed to load image: $e",
                                          );
                                        },
                                      );
                                    } else {
                                      return CircleAvatar(
                                        radius: 60,
                                        backgroundColor: Colors.white
                                            .withOpacity(0.3),
                                        child: const Icon(
                                          Icons.person,
                                          size: 60,
                                          color: Colors.white,
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      spreadRadius: 0,
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: IconButton(
                                  onPressed: _pickImage,
                                  icon: Icon(
                                    Icons.camera_alt,
                                    color: isDarkMode
                                        ? Colors.green.shade700
                                        : Colors.green.shade600,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // User Info - Clean typography
                          Text(
                            userService.userName,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: -0.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              userService.userEmail,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Stats Card - Separated with modern card design
                  SliverToBoxAdapter(
                    child: Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(
                              isDarkMode ? 0.3 : 0.08,
                            ),
                            spreadRadius: 0,
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Statistics',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildModernStatColumn(
                                'Total Scans',
                                Icons.qr_code_scanner_rounded,
                                isDarkMode
                                    ? Colors.green.shade400
                                    : Colors.green.shade600,
                                textColor,
                                subtitleColor,
                                isDarkMode,
                              ),
                              _buildStatDivider(isDarkMode),
                              _buildModernStatColumn(
                                'Challenges',
                                Icons.emoji_events_rounded,
                                isDarkMode
                                    ? Colors.amber.shade400
                                    : Colors.amber.shade600,
                                textColor,
                                subtitleColor,
                                isDarkMode,
                              ),
                              _buildStatDivider(isDarkMode),
                              _buildModernStatColumn(
                                'Points',
                                Icons.stars_rounded,
                                isDarkMode
                                    ? Colors.blue.shade400
                                    : Colors.blue.shade600,
                                textColor,
                                subtitleColor,
                                isDarkMode,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Recent Activity Header
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(32, 8, 32, 16),
                      child: Text(
                        'Recent Activity',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                  ),

                  // Recent Activity List
                  Consumer<ProfileService>(
                    builder: (context, profileService, child) {
                      // I-filter ang activities nga naa pa lang sa 24 hours
                      final activities = _filterRecentActivities(
                        profileService.recentActivity,
                      );

                      if (activities.isEmpty) {
                        return SliverFillRemaining(
                          hasScrollBody: false,
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(32.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(24),
                                    decoration: BoxDecoration(
                                      color: isDarkMode
                                          ? Colors.grey.shade800
                                          : Colors.grey.shade100,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.history_rounded,
                                      size: 64,
                                      color: subtitleColor.withOpacity(0.5),
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  Text(
                                    'No recent activity',
                                    style: TextStyle(
                                      color: textColor,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Your quiz history will appear here',
                                    style: TextStyle(
                                      color: subtitleColor.withOpacity(0.7),
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }

                      return SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            final activity = activities[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _buildModernActivityItem(
                                activity,
                                isDarkMode,
                                textColor,
                                subtitleColor,
                                cardColor,
                              ),
                            );
                          }, childCount: activities.length),
                        ),
                      );
                    },
                  ),

                  // Bottom spacing
                  const SliverToBoxAdapter(child: SizedBox(height: 20)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // I-filter ang activities nga naa pa sa sulod sa 24 hours
  List<Map<String, dynamic>> _filterRecentActivities(
    List<Map<String, dynamic>> activities,
  ) {
    final now = DateTime.now();
    final twentyFourHoursAgo = now.subtract(const Duration(hours: 24));

    return activities.where((activity) {
      try {
        final createdAt = DateTime.parse(
          activity['created_at'] ?? DateTime.now().toIso8601String(),
        );
        // I-return lang kung ang activity kay wala pa mo-abot sa 24 hours
        return createdAt.isAfter(twentyFourHoursAgo);
      } catch (e) {
        debugPrint("Error parsing date: $e");
        return false; // I-exclude ang invalid dates
      }
    }).toList();
  }

  // Modern stat divider
  Widget _buildStatDivider(bool isDarkMode) {
    return Container(
      height: 60,
      width: 1.5,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300,
            Colors.transparent,
          ],
        ),
      ),
    );
  }

  // Modern activity item with card design
  Widget _buildModernActivityItem(
    Map<String, dynamic> activity,
    bool isDarkMode,
    Color textColor,
    Color subtitleColor,
    Color cardColor,
  ) {
    final activityType = activity['activity_type'] as String? ?? 'unknown';
    final title = activity['title'] as String? ?? 'No title';
    final description = activity['description'] as String?;

    DateTime createdAt;
    try {
      createdAt = DateTime.parse(
        activity['created_at'] ?? DateTime.now().toIso8601String(),
      );
    } catch (e) {
      createdAt = DateTime.now();
    }

    final timeAgo = _getTimeAgo(createdAt);

    // I-determine ang icon ug color base sa activity type
    IconData icon;
    Color iconColor;

    switch (activityType) {
      case 'quiz':
        icon = Icons.quiz_rounded;
        iconColor = isDarkMode ? Colors.blue.shade400 : Colors.blue.shade600;
        break;
      case 'scan':
        icon = Icons.camera_alt_rounded;
        iconColor = isDarkMode ? Colors.green.shade400 : Colors.green.shade600;
        break;
      case 'achievement':
        icon = Icons.emoji_events_rounded;
        iconColor = isDarkMode ? Colors.amber.shade400 : Colors.amber.shade600;
        break;
      default:
        icon = Icons.info_rounded;
        iconColor = isDarkMode ? Colors.grey.shade500 : Colors.grey.shade600;
    }

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.2 : 0.05),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor, size: 24),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
            color: textColor,
            letterSpacing: -0.2,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (description != null && description.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(fontSize: 13, color: subtitleColor),
              ),
            ],
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(
                  Icons.access_time_rounded,
                  size: 12,
                  color: subtitleColor.withOpacity(0.6),
                ),
                const SizedBox(width: 4),
                Text(
                  timeAgo,
                  style: TextStyle(
                    fontSize: 12,
                    color: subtitleColor.withOpacity(0.8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
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

  // Modern stat column with improved visual hierarchy
  Widget _buildModernStatColumn(
    String label,
    IconData icon,
    Color color,
    Color textColor,
    Color subtitleColor,
    bool isDarkMode,
  ) {
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
        return Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 28, color: color),
              ),
              const SizedBox(height: 12),
              Text(
                displayValue,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: subtitleColor,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
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
