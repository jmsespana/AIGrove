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

        final userService = context.read<UserService>();
        await userService.updateAvatar(imageFile);

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile picture na-update na!')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error sa pag-upload: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Edit bio
  Future<void> _editBio() async {
    final userService = context.read<UserService>();
    final currentBio = userService.bio ?? '';

    final String? newBio = await showDialog<String>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text('I-edit ang Bio'),
        content: TextField(
          controller: _bioController..text = currentBio,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'I-type imong bio dinhi...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, _bioController.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (!mounted) return;

    if (newBio != null) {
      try {
        await userService.updateBio(newBio);

        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Bio na-update na!')));
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error sa pag-update: $e')));
      }
    }
  }

  // Logout function

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  expandedHeight: 320.0,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Cover Image
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
                        // Profile Picture and Name Container
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Profile Picture
                                Stack(
                                  alignment: Alignment.bottomRight,
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 4,
                                        ),
                                      ),
                                      child: CircleAvatar(
                                        radius: 60,
                                        backgroundColor: Colors.grey[300],
                                        backgroundImage:
                                            userService.avatarUrl != null
                                            ? NetworkImage(
                                                userService.avatarUrl!,
                                              )
                                            : (userService.avatarImage != null
                                                      ? FileImage(
                                                          userService
                                                              .avatarImage!,
                                                        )
                                                      : null)
                                                  as ImageProvider?,
                                        child:
                                            (userService.avatarUrl == null &&
                                                userService.avatarImage == null)
                                            ? const Icon(Icons.person, size: 60)
                                            : null,
                                      ),
                                    ),
                                    FloatingActionButton.small(
                                      onPressed: _pickImage,
                                      backgroundColor: Colors.green.shade600,
                                      child: const Icon(Icons.camera_alt),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                // User's Name (larger and bold)
                                Text(
                                  userService.userName,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                // Email below name
                                Text(
                                  userService.userEmail,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
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
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildStatColumn('Trees Planted', '0'),
                                _buildStatColumn('Challenges', '0'),
                                _buildStatColumn('Points', '0'),
                              ],
                            ),
                          ),

                          // Bio Section
                          Container(
                            margin: const EdgeInsets.all(16),
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
                                ListTile(
                                  title: const Text(
                                    'About',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: _editBio,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    16,
                                    0,
                                    16,
                                    16,
                                  ),
                                  child: Text(
                                    userService.bio ??
                                        'Add something about yourself...',
                                    style: TextStyle(
                                      color: userService.bio?.isEmpty ?? true
                                          ? Colors.grey
                                          : Colors.black87,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Recent Activity Section
                          Container(
                            margin: const EdgeInsets.all(16),
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
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 14),
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
