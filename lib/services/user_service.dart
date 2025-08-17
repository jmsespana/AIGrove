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
        await loadUserProfile(); // Load user profile after successful login
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

      // First check if profile exists
      final profileExists = await _supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (profileExists == null) {
        // Create default profile if it doesn't exist
        await _supabase.from('profiles').insert({
          'id': user.id,
          'email': user.email,
          'first_name': '',
          'last_name': '',
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });
      }

      // Now load the profile
      final profile = await _supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .single();

      _userName = '${profile['first_name']} ${profile['last_name']}'.trim();
      _userEmail = profile['email'] ?? user.email ?? '';
      _avatarUrl = profile['avatar_url'];
      _userRole = profile['role'] ?? 'user';
      _bio = profile['bio'];

      notifyListeners();
    } catch (e) {
      debugPrint('Error loading profile: $e');
      // Don't rethrow here, just log the error
    }
  }

  // Enhanced avatar update method
  Future<void> updateAvatar(File image) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      final fileName =
          '${user.id}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      await _supabase.storage.from('avatars').upload(fileName, image);

      final String publicUrl = _supabase.storage
          .from('avatars')
          .getPublicUrl(fileName);

      _avatarImage = image;
      _avatarUrl = publicUrl;

      // Update profile in database
      await _supabase
          .from('profiles')
          .update({
            'avatar_url': publicUrl,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', user.id);

      notifyListeners();
    } catch (e) {
      debugPrint('Error updating avatar: $e');
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
}
