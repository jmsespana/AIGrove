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
  List<Map<String, dynamic>> _userScans = [];

  // Getters
  String get userName => _userName;
  String get userEmail => _userEmail;
  File? get avatarImage => _avatarImage;
  String? get avatarUrl => _avatarUrl;
  String? get userId => _userId;
  String get userRole => _userRole;
  bool get isAuthenticated => _isAuthenticated;
  String? get bio => _bio;
  List<Map<String, dynamic>> get userScans => _userScans;

  // Login method
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

        // Check kung naa bay profile
        final profile = await _supabase
            .from('profiles')
            .select()
            .eq('id', _userId!)
            .maybeSingle();

        if (profile == null) {
          // I-create ang initial profile kung wala pa
          await _supabase.from('profiles').upsert({
            'id': _userId,
            'email': email,
            'first_name': '',
            'last_name': '',
            'role': 'user',
          });
        }

        await loadUserProfile();
        await loadUserScans();
        notifyListeners();
      } else {
        throw Exception('Login failed');
      }
    } catch (e) {
      debugPrint('Error during login: $e');
      rethrow;
    }
  }

  // Initialize method para sa session persistence
  Future<bool> initialize() async {
    try {
      final Session? session = _supabase.auth.currentSession;
      _isAuthenticated = session != null;
      _userId = session?.user.id;

      if (_isAuthenticated && _userId != null) {
        await loadUserProfile();
        await loadUserScans();
        debugPrint('User session restored: $_userName');
      } else {
        debugPrint('No active session found');
      }

      _supabase.auth.onAuthStateChange.listen((data) async {
        final Session? session = data.session;
        _isAuthenticated = session != null;
        _userId = session?.user.id;

        if (_isAuthenticated && _userId != null) {
          await loadUserProfile();
          await loadUserScans();
          debugPrint('Auth state changed: User logged in');
        } else {
          _clear();
          debugPrint('Auth state changed: User logged out');
        }
        notifyListeners();
      });

      return _isAuthenticated;
    } catch (e) {
      debugPrint('Error initializing user service: $e');
      return false;
    }
  }

  bool checkAuthenticated() {
    return _supabase.auth.currentSession != null;
  }

  Future<void> loadUserProfile() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      final profile = await _supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (profile == null) {
        await _supabase.from('profiles').insert({
          'id': user.id,
          'email': user.email,
          'first_name': '',
          'last_name': '',
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });

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

  void _updateProfileData(Map<String, dynamic> profile) {
    _userName = '${profile['first_name'] ?? ''} ${profile['last_name'] ?? ''}'
        .trim();
    _userEmail = profile['email'] ?? '';
    _avatarUrl = profile['avatar_url'];
    _bio = profile['bio'];
  }

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

  Future<void> updateAvatar(File image) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      debugPrint("Nag-update sa avatar para sa user: ${user.id}");

      final fileExt = image.path.split('.').last;
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final fileName = 'avatar_${user.id.substring(0, 8)}_$timestamp.$fileExt';

      debugPrint("Generated filename: $fileName");

      await _supabase.storage
          .from('avatars')
          .upload(
            fileName,
            image,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
          );

      final String imageUrl = _supabase.storage
          .from('avatars')
          .getPublicUrl(fileName);

      debugPrint("Generated image URL: $imageUrl");

      await _supabase
          .from('profiles')
          .update({'avatar_url': imageUrl})
          .eq('id', user.id);

      _avatarUrl = imageUrl;
      _avatarImage = image;

      notifyListeners();
    } catch (e) {
      debugPrint("Error sa pag-update sa avatar: $e");
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
    _clear();
  }

  void _clear() {
    _userId = null;
    _userName = '';
    _userEmail = '';
    _avatarImage = null;
    _avatarUrl = null;
    _userRole = 'user';
    _isAuthenticated = false;
    _bio = null;
    _userScans = [];
    notifyListeners();
  }

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
      debugPrint('Error sa pag-update sa bio: $e');
      rethrow;
    }
  }

  // ========== SCAN METHODS ==========

  /// I-save ang scan result sa database
  Future<void> saveScan({
    required String speciesName,
    String? imageUrl,
    double? latitude,
    double? longitude,
    String? notes,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('User wala naka-login');
      }

      debugPrint('🔍 === SAVING SCAN ===');
      debugPrint('🔍 User ID: ${user.id}');
      debugPrint('🔍 Species: $speciesName');
      debugPrint('🔍 Image URL: $imageUrl');

      // I-insert ang scan data
      // Kung wala latitude/longitude, gamit default values (0.0) or remove the fields
      final scanData = {
        'user_id': user.id,
        'species_name': speciesName,
        'image_url': imageUrl,
        // I-include lang kung naa value, otherwise skip
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
        if (notes != null) 'notes': notes,
      };

      debugPrint('🔍 Scan data: $scanData');

      final result = await _supabase
          .from('scans')
          .insert(scanData)
          .select()
          .single();

      debugPrint('✅ Insert successful: $result');

      // I-reload ang scans
      await loadUserScans();

      debugPrint('✅ Scan na-save successfully: $speciesName');
    } catch (e, stackTrace) {
      debugPrint('❌ Error sa pag-save sa scan: $e');
      debugPrint('❌ Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// I-load ang user's scan history
  Future<void> loadUserScans() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        debugPrint('⚠️ Wala naka-login ang user');
        _userScans = [];
        notifyListeners();
        return;
      }

      debugPrint('🔍 === LOADING SCANS ===');
      debugPrint('🔍 User ID: ${user.id}');

      // Query: user_id sa scans naka-FK sa profiles.id
      final response = await _supabase
          .from('scans')
          .select('*')
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      debugPrint('🔍 Query response type: ${response.runtimeType}');
      debugPrint('🔍 Query response: $response');

      _userScans = List<Map<String, dynamic>>.from(response);
      debugPrint('✅ Na-load ang ${_userScans.length} scans');

      if (_userScans.isNotEmpty) {
        debugPrint('🔍 First scan: ${_userScans.first}');
      } else {
        debugPrint('⚠️ Walay scans na-load pero wala error');
      }

      notifyListeners();
    } catch (e, stackTrace) {
      debugPrint('❌ Error sa pag-load sa scans: $e');
      debugPrint('❌ Stack trace: $stackTrace');
      _userScans = [];
      notifyListeners();
    }
  }

  /// I-update ang scan
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
      };

      await _supabase.from('scans').update(updates).eq('id', scanId);

      await loadUserScans();
      debugPrint('✅ Scan na-update successfully');
    } catch (e) {
      debugPrint('❌ Error sa pag-update sa scan: $e');
      rethrow;
    }
  }

  /// I-delete ang scan
  Future<void> deleteScan(String scanId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      await _supabase.from('scans').delete().eq('id', scanId);

      await loadUserScans();
      debugPrint('✅ Scan na-delete successfully');
    } catch (e) {
      debugPrint('❌ Error sa pag-delete sa scan: $e');
      rethrow;
    }
  }
}
