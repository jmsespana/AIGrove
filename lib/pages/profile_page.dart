import 'package:aigrove/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Kailangan i-add sa pubspec.yaml
import 'dart:io';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
// Para sa profile picture
  final TextEditingController _bioController = TextEditingController();
  String _bio = ""; // Bio text

  // Para ma-upload ang picture
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
      );

      if (!mounted) {
        return; // Check if widget is still mounted right after await
      }

      if (pickedFile != null) {
        final File imageFile = File(pickedFile.path);
        UserService().updateUserInfo(avatarImage: imageFile);
        setState(() {
        });
      }
    } catch (e) {
      if (!mounted) {
        return; // Check if widget is still mounted before using context
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error sa pag-upload sa image')),
      );
    }
  }

  // Para ma-edit ang bio
  void _editBio() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('I-edit ang Bio'),
        content: TextField(
          controller: _bioController..text = _bio,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'I-type imong bio dinhi...',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _bio = _bioController.text;
              });
              Navigator.pop(context);
              // to do Save bio to backend
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Profile Picture Section
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: UserService().avatarImage != null
                      ? FileImage(UserService().avatarImage!)
                      : null,
                  child: UserService().avatarImage == null
                      ? const Icon(Icons.person, size: 60)
                      : null,
                ),
                FloatingActionButton.small(
                  onPressed: _pickImage,
                  child: const Icon(Icons.camera_alt),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Name Section
            Text(
              UserService().userName,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),

            // Bio Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Bio',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: _editBio,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _bio.isEmpty ? 'Add your bio...' : _bio,
                      style: TextStyle(
                        color: _bio.isEmpty ? Colors.grey : Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _bioController.dispose();
    super.dispose();
  }
}
