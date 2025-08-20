import 'package:flutter/material.dart';
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserService extends ChangeNotifier {
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal();

  final _supabase = Supabase.instance.client;

  String _userName = '';
  String _userEmail = '';
  File? _avatarImage;
  String? _avatarUrl;
  String? _userId;
  String _userRole = 'user';
  bool _isAuthenticated = false;
  String? _bio;

  // Getters remain the same
  String get userName => _userName;
  String get userEmail => _userEmail;
  File? get avatarImage => _avatarImage;
  String? get avatarUrl => _avatarUrl;
  String? get userId => _userId;
  String get userRole => _userRole;
  bool get isAuthenticated => _isAuthenticated;
  String? get bio => _bio;

  // Add login method
  Future<void> login(String email, String password) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email.trim(),
        password: password.trim(),
      );

      if (response.session != null) {
        _isAuthenticated = true;
        _userId = response.user?.id;

        if (_userId == null) throw Exception('User ID is null');

        // Check if profile exists
        final profile = await _supabase
            .from('profiles')
            .select()
            .eq('id', _userId!)
            .maybeSingle();

        if (profile == null) {
          // Create initial profile
          await _supabase.from('profiles').upsert({
            'id': _userId,
            'email': email,
            'first_name': '',
            'last_name': '',
            'role': 'user',
          });
        }

        await loadUserProfile();
        notifyListeners();
      } else {
        throw Exception('Login failed');
      }
    } catch (e) {
      debugPrint('Error during login: $e');
      rethrow;
    }
  }

  // Initialize auth state
  Future<void> initialize() async {
    // Check if there's an existing session
    final Session? session = _supabase.auth.currentSession;
    _isAuthenticated = session != null;
    _userId = session?.user.id;

    if (_isAuthenticated) {
      await loadUserProfile();
    }

    // Listen to auth state changes
    _supabase.auth.onAuthStateChange.listen((data) async {
      final Session? session = data.session;
      _isAuthenticated = session != null;
      _userId = session?.user.id;

      if (_isAuthenticated) {
        await loadUserProfile();
      } else {
        _clear();
      }
      notifyListeners();
    });
  }

  // Enhanced load user profile
  Future<void> loadUserProfile() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      // Check if profile exists
      final profile = await _supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (profile == null) {
        // Create profile if it doesn't exist
        await _supabase.from('profiles').insert({
          'id': user.id,
          'email': user.email,
          'first_name': '',
          'last_name': '',
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });

        // Fetch the newly created profile
        final newProfile = await _supabase
            .from('profiles')
            .select()
            .eq('id', user.id)
            .single();

        _updateProfileData(newProfile);
      } else {
        _updateProfileData(profile);
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error loading profile: $e');
      rethrow;
    }
  }

  // Helper method to update profile data
  void _updateProfileData(Map<String, dynamic> profile) {
    _userName = '${profile['first_name'] ?? ''} ${profile['last_name'] ?? ''}'
        .trim();
    _userEmail = profile['email'] ?? '';
    _avatarUrl = profile['avatar_url'];
    _bio = profile['bio'];
  }

  // Update profile method
  Future<void> updateProfile({
    String? firstName,
    String? lastName,
    String? bio,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      final updates = {
        'first_name': firstName,
        'last_name': lastName,
        'bio': bio,
        'updated_at': DateTime.now().toIso8601String(),
      }..removeWhere((key, value) => value == null);

      await _supabase.from('profiles').update(updates).eq('id', user.id);

      await loadUserProfile();
    } catch (e) {
      debugPrint('Error updating profile: $e');
      rethrow;
    }
  }

  // Update avatar method
  Future<void> updateAvatar(File image) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      // Debug: Print user info
      debugPrint("Updating avatar for user: ${user.id}");

      // Generate SIMPLER filename - walay special characters
      final fileExt = image.path.split('.').last;
      // Simplified filename format
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final fileName = 'avatar_${user.id.substring(0, 8)}_$timestamp.$fileExt';

      // Debug: Print filename
      debugPrint("Generated filename: $fileName");

      // Upload file to Supabase Storage
      await _supabase.storage
          .from('avatars')
          .upload(
            fileName,
            image,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
          );

      // Get public URL
      final String imageUrl = _supabase.storage
          .from('avatars')
          .getPublicUrl(fileName);

      // Debug: Print URL
      debugPrint("Generated image URL: $imageUrl");

      // Update profile in database
      await _supabase
          .from('profiles')
          .update({'avatar_url': imageUrl})
          .eq('id', user.id);

      // Update local state
      _avatarUrl = imageUrl;
      _avatarImage = image;

      notifyListeners();
    } catch (e) {
      debugPrint("Error updating avatar: $e");
      rethrow;
    }
  }

  // Add sign out method
  Future<void> signOut() async {
    await _supabase.auth.signOut();
    _clear();
  }

  // Clear user data
  void _clear() {
    _userId = null;
    _userName = '';
    _userEmail = '';
    _avatarImage = null;
    _avatarUrl = null;
    _userRole = 'user';
    _isAuthenticated = false;
    _bio = null;
    notifyListeners();
  }

  // Add this method
  Future<void> updateBio(String newBio) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      await _supabase
          .from('profiles')
          .update({
            'bio': newBio,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', user.id);

      _bio = newBio;
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating bio: $e');
      rethrow;
    }
  }

  // Add these properties
  List<Map<String, dynamic>> _userScans = [];
  List<Map<String, dynamic>> get userScans => _userScans;

  // Add method to load user's scans
  Future<void> loadUserScans() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      final scans = await _supabase
          .from('scans')
          .select('''
            *,
            profiles (
              first_name,
              last_name,
              avatar_url
            )
          ''')
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      _userScans = List<Map<String, dynamic>>.from(scans);
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading scans: $e');
      rethrow;
    }
  }

  // Add method to create new scan
  Future<void> createScan({
    required String speciesName,
    required double latitude,
    required double longitude,
    String? imageUrl,
    String? notes,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      await _supabase.from('scans').insert({
        'user_id': user.id,
        'species_name': speciesName,
        'latitude': latitude,
        'longitude': longitude,
        'image_url': imageUrl,
        'notes': notes,
      });

      await loadUserScans(); // Reload scans after creating new one
    } catch (e) {
      debugPrint('Error creating scan: $e');
      rethrow;
    }
  }

  // Add method to update scan
  Future<void> updateScan({
    required String scanId,
    String? speciesName,
    String? notes,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      final updates = {
        if (speciesName != null) 'species_name': speciesName,
        if (notes != null) 'notes': notes,
        'updated_at': DateTime.now().toIso8601String(),
      };

      await _supabase.from('scans').update(updates).eq('id', scanId);

      await loadUserScans(); // Reload scans after update
    } catch (e) {
      debugPrint('Error updating scan: $e');
      rethrow;
    }
  }

  // Add method to delete scan
  Future<void> deleteScan(String scanId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      await _supabase.from('scans').delete().eq('id', scanId);

      await loadUserScans(); // Reload scans after deletion
    } catch (e) {
      debugPrint('Error deleting scan: $e');
      rethrow;
    }
  }
}
