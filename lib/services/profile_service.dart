import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


class ProfileService extends ChangeNotifier {
  static final ProfileService _instance = ProfileService._internal();
  factory ProfileService() => _instance;
  ProfileService._internal();

  final _supabase = Supabase.instance.client;

  // Profile stats
  int _treesPlanted = 0;
  int _challengesCompleted = 0;
  int _points = 0;
  List<Map<String, dynamic>> _recentActivity = [];

  // Getters
  int get treesPlanted => _treesPlanted;
  int get challengesCompleted => _challengesCompleted;
  int get points => _points;
  List<Map<String, dynamic>> get recentActivity => _recentActivity;

  // Load profile stats
  Future<void> loadProfileStats() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      final stats = await _supabase
          .from('user_stats')
          .select()
          .eq('user_id', user.id)
          .single();

      _treesPlanted = stats['trees_planted'] ?? 0;
      _challengesCompleted = stats['challenges_completed'] ?? 0;
      _points = stats['points'] ?? 0;

      // Load recent activity
      final activity = await _supabase
          .from('user_activity')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false)
          .limit(5);

      _recentActivity = List<Map<String, dynamic>>.from(activity);

      notifyListeners();
    } catch (e) {
      debugPrint('Error loading profile stats: $e');
    }
  }

  // Update trees planted
  Future<void> updateTreesPlanted(int count) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      await _supabase.from('user_stats').upsert({
        'user_id': user.id,
        'trees_planted': count,
        'updated_at': DateTime.now().toIso8601String(),
      });

      _treesPlanted = count;

      // Add to activity
      await _addActivity('Planted a tree');

      notifyListeners();
    } catch (e) {
      debugPrint('Error updating trees planted: $e');
      rethrow;
    }
  }

  // Update challenges
  Future<void> updateChallenges(int count) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      await _supabase.from('user_stats').upsert({
        'user_id': user.id,
        'challenges_completed': count,
        'updated_at': DateTime.now().toIso8601String(),
      });

      _challengesCompleted = count;
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating challenges: $e');
      rethrow;
    }
  }

  // Add activity
  Future<void> _addActivity(String description) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      await _supabase.from('user_activity').insert({
        'user_id': user.id,
        'description': description,
        'created_at': DateTime.now().toIso8601String(),
      });

      await loadProfileStats(); // Reload activities
    } catch (e) {
      debugPrint('Error adding activity: $e');
      rethrow;
    }
  }
}

// UI code removed: Ang UI block na ito ay hindi dapat nasa service file.
// Inilipat ang UI sa isang widget file (hal. lib/widgets/profile_header.dart) at dapat gumamit ng tamang UserService o provider para sa user data.
// Service file na ito ay para sa business logic lang (Supabase interaction) at hindi dapat maglaman ng direktang widget code.
