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

    // Clear image cache at start
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAllProfileData();
    });
  }

  // Load user profile data
  Future<void> _loadAllProfileData() async {
    setState(() => _isLoading = true);
    try {
      await Future.wait([
        context.read<UserService>().loadUserProfile(),
        context.read<ProfileService>().loadProfileStats(),
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

  // Upload profile picture
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

        // Debug: Print file info
        debugPrint("Selected image: ${pickedFile.path}");

        // Upload avatar
        final userService = context.read<UserService>();
        await userService.updateAvatar(imageFile);

        // Debug: Print URL after upload
        debugPrint("Uploaded avatar URL: ${userService.avatarUrl}");

        // Clear image cache to force reload
        PaintingBinding.instance.imageCache.clear();
        PaintingBinding.instance.imageCache.clearLiveImages();

        // Force rebuild
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

  // // Edit bio
  // Future<void> _editBio() async {
  //   final userService = context.read<UserService>();
  //   final currentBio = userService.bio ?? '';

  //   final String? newBio = await showDialog<String>(
  //     context: context,
  //     builder: (BuildContext dialogContext) => AlertDialog(
  //       title: const Text('I-edit ang Bio'),
  //       content: TextField(
  //         controller: _bioController..text = currentBio,
  //         maxLines: 3,
  //         decoration: const InputDecoration(
  //           hintText: 'I-type imong bio dinhi...',
  //           border: OutlineInputBorder(),
  //         ),
  //       ),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(dialogContext),
  //           child: const Text('Cancel'),
  //         ),
  //         TextButton(
  //           onPressed: () => Navigator.pop(dialogContext, _bioController.text),
  //           child: const Text('Save'),
  //         ),
  //       ],
  //     ),
  //   );

  //   if (!mounted) return;

  //   if (newBio != null) {
  //     try {
  //       await userService.updateBio(newBio);

  //       if (!mounted) return;
  //       ScaffoldMessenger.of(
  //         context,
  //       ).showSnackBar(const SnackBar(content: Text('Bio na-update na!')));
  //     } catch (e) {
  //       if (!mounted) return;
  //       ScaffoldMessenger.of(
  //         context,
  //       ).showSnackBar(SnackBar(content: Text('Error sa pag-update: $e')));
  //     }
  //   }
  // }

  // Logout function

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: true, // I-add ang SafeArea sa top para dili ma-overlap sa status bar
      child: Scaffold(
        body: Consumer<UserService>(
          builder: (context, userService, child) {
            if (_isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return RefreshIndicator(
              onRefresh: _loadAllProfileData,
              child: CustomScrollView(
                slivers: [
                  // Custom App Bar with Cover Image and Profile Picture
                  SliverAppBar(
                    expandedHeight: 200.0,
                    floating: false,
                    pinned: true,
                    backgroundColor: Colors.green.shade700,
                    // I-customize ang back button
                    leading: IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios, // Mao ni ang '<' style na arrow
                        color: Colors.white,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    flexibleSpace: FlexibleSpaceBar(
                      background: Stack(
                        fit: StackFit.expand,
                        children: [
                          // Cover Image - reduced height na karon
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.green.shade700,
                                  Colors.green.shade900,
                                ],
                              ),
                            ),
                          ),
                          // Profile Info Container
                          Positioned(
                            bottom: 16,
                            left: 16,
                            right: 16,
                            child: Row(
                              children: [
                                // Profile Picture - gi-revert sa original size
                                Stack(
                                  alignment: Alignment.bottomRight,
                                  children: [
                                    Container(
                                      width: 100, // Gi-revert balik sa 100
                                      height: 100, // Gi-revert balik sa 100
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: const Color.fromARGB(
                                            255,
                                            13,
                                            13,
                                            13,
                                          ),
                                          width: 2,
                                        ),
                                      ),
                                      child: Builder(
                                        builder: (context) {
                                          final String? avatarUrl =
                                              userService.avatarUrl;
                                          debugPrint(
                                            "Current avatar URL: $avatarUrl",
                                          );

                                          if (avatarUrl != null &&
                                              avatarUrl.isNotEmpty) {
                                            return CircleAvatar(
                                              radius:
                                                  50, // Gi-revert balik sa 50
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
                                            return const CircleAvatar(
                                              radius:
                                                  50, // Gi-revert balik sa 50
                                              backgroundColor: Colors.grey,
                                              child: Icon(
                                                Icons.person,
                                                size:
                                                    50, // Gi-revert balik sa 50
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
                                      child: const Icon(
                                        Icons.camera_alt,
                                        size: 16,
                                      ), // Original size
                                    ),
                                  ],
                                ),

                                const SizedBox(width: 16), // Original spacing
                                // User Info - gi-maintain ang adjusted text sizes para sa compact container
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      // User's Name
                                      Text(
                                        userService.userName,
                                        style: const TextStyle(
                                          fontSize:
                                              20, // Gi-maintain ang reduced font size
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      // Email
                                      Text(
                                        userService.userEmail,
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 14,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),

                                      // // Bio section
                                      // const SizedBox(height: 6),
                                      // Row(
                                      //   children: [
                                      //     Expanded(
                                      //       child: Text(
                                      //         userService.bio ??
                                      //             'Add something about yourself...',
                                      //         style: TextStyle(
                                      //           // ignore: deprecated_member_use
                                      //           color: Colors.white.withOpacity(
                                      //             0.9,
                                      //           ),
                                      //           fontSize: 12,
                                      //           fontStyle:
                                      //               userService.bio == null ||
                                      //                   userService.bio!.isEmpty
                                      //               ? FontStyle.italic
                                      //               : FontStyle.normal,
                                      //         ),
                                      //         maxLines: 1,
                                      //         overflow: TextOverflow.ellipsis,
                                      //       ),
                                      //     ),
                                      //     IconButton(
                                      //       icon: const Icon(
                                      //         Icons.edit,
                                      //         color: Colors.white70,
                                      //         size: 16,
                                      //       ),
                                      //       onPressed: _editBio,
                                      //       constraints: const BoxConstraints(
                                      //         maxHeight: 20,
                                      //         maxWidth: 20,
                                      //       ),
                                      //       padding: EdgeInsets.zero,
                                      //       tooltip: 'I-edit ang Bio',
                                      //     ),
                                      //   ],
                                      // ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Profile Content
                  SliverToBoxAdapter(
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16.0),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Stats Row
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    // ignore: deprecated_member_use
                                    color: Colors.grey.withOpacity(0.1),
                                    spreadRadius: 1,
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  _buildStatColumn('Total scans', '0'),
                                  _buildStatColumn('Challenges', '0'),
                                  _buildStatColumn('Points', '0'),
                                ],
                              ),
                            ),

                            // Recent Activity Section
                            Container(
                              margin: const EdgeInsets.only(top: 16),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    // ignore: deprecated_member_use
                                    color: Colors.grey.withOpacity(0.1),
                                    spreadRadius: 1,
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const ListTile(
                                    title: Text(
                                      'Recent Activity',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  // Add your activity items here
                                  const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(16.0),
                                      child: Text(
                                        'No recent activity',
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, String value) {
    return Consumer<ProfileService>(
      builder: (context, profileService, child) {
        String displayValue = '0';
        switch (label) {
          case 'Trees Planted':
            displayValue = profileService.treesPlanted.toString();
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
            Text(
              displayValue,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
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
