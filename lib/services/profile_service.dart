import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileService extends ChangeNotifier {
  static final ProfileService _instance = ProfileService._internal();
  factory ProfileService() => _instance;
  ProfileService._internal();

  final _supabase = Supabase.instance.client;

  // Profile stats - mga stats sa user
  int _treesPlanted = 0;
  int _challengesCompleted = 0;
  int _points = 0;
  List<Map<String, dynamic>> _recentActivity = [];

  // Getters para ma-access ang stats
  int get treesPlanted => _treesPlanted;
  int get challengesCompleted => _challengesCompleted;
  int get points => _points;
  List<Map<String, dynamic>> get recentActivity => _recentActivity;

  // Load profile stats - kuhaon ang stats sa database
  Future<void> loadProfileStats() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      // Kuhaon ang stats gikan sa user_stats table
      final stats = await _supabase
          .from('user_stats')
          .select()
          .eq('user_id', user.id)
          .maybeSingle();

      if (stats != null) {
        _treesPlanted = stats['trees_planted'] ?? 0;
        _challengesCompleted = stats['challenges_completed'] ?? 0;
        _points = stats['points'] ?? 0;
      } else {
        // I-create ang default stats kung wala pa
        await _supabase.from('user_stats').upsert({
          'user_id': user.id,
          'trees_planted': 0,
          'challenges_completed': 0,
          'points': 0,
        }, onConflict: 'user_id');

        // I-set ang default values
        _treesPlanted = 0;
        _challengesCompleted = 0;
        _points = 0;
      }

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
      debugPrint('Error sa pag-load ng profile stats: $e');
    }
  }

  // Update trees planted - para sa tree planting feature
  Future<void> updateTreesPlanted(int count) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      await _supabase.from('user_stats').upsert({
        'user_id': user.id,
        'trees_planted': count,
        'updated_at': DateTime.now().toIso8601String(),
      }, onConflict: 'user_id');

      _treesPlanted = count;

      // I-add sa activity log
      await _addActivity('Nagtanom og kahoy');

      notifyListeners();
    } catch (e) {
      debugPrint('Error updating trees planted: $e');
      rethrow;
    }
  }

  // Update challenges count - manual update kung needed
  Future<void> updateChallenges(int count) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      await _supabase.from('user_stats').upsert({
        'user_id': user.id,
        'challenges_completed': count,
        'updated_at': DateTime.now().toIso8601String(),
      }, onConflict: 'user_id');

      _challengesCompleted = count;
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating challenges: $e');
      rethrow;
    }
  }

  // Add points from quiz - para sa quiz feature
  Future<void> addPoints(int points) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        debugPrint('Walang naka-login nga user - dili ma-save ang points');
        throw Exception('User not logged in');
      }

      debugPrint('Nag-add og points para sa user: ${user.id}, Points: $points');

      // I-try ang RPC function muna
      try {
        final response = await _supabase.rpc(
          'add_user_points',
          params: {'user_id_param': user.id, 'points_to_add': points},
        );

        debugPrint('Points na-add na via RPC: $response');

        // I-reload ang stats para ma-update ang local state
        await loadProfileStats();
      } catch (rpcError) {
        debugPrint('RPC failed, using fallback method: $rpcError');
        await _addPointsFallback(points);
      }

      // I-add sa activity log
      await _addActivity('Nakakuha og $points points gikan sa quiz');
    } catch (e) {
      debugPrint('Error sa pag-add og points: $e');
      rethrow;
    }
  }

  // Fallback method kung nag-fail ang RPC
  Future<void> _addPointsFallback(int points) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      // I-get ang current stats
      final currentStats = await _supabase
          .from('user_stats')
          .select()
          .eq('user_id', user.id)
          .maybeSingle();

      if (currentStats == null) {
        // I-create new record
        await _supabase.from('user_stats').insert({
          'user_id': user.id,
          'points': points,
          'challenges_completed': 0,
          'trees_planted': 0,
        });
      } else {
        // I-update existing record
        await _supabase
            .from('user_stats')
            .update({
              'points': (currentStats['points'] ?? 0) + points,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('user_id', user.id);
      }

      // I-update ang local state
      _points = (currentStats?['points'] ?? 0) + points;
      notifyListeners();

      debugPrint('Points na-add na via fallback method');
    } catch (e) {
      debugPrint('Fallback method failed din: $e');
      rethrow;
    }
  }

  // Add completed challenge - para sa quiz completion
  Future<void> addCompletedChallenge() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        debugPrint('Walang naka-login nga user - dili ma-save ang challenge');
        throw Exception('User not logged in');
      }

      debugPrint('Nag-add og completed challenge para sa user: ${user.id}');

      // I-try ang RPC function muna
      try {
        final response = await _supabase.rpc(
          'add_user_challenge',
          params: {'user_id_param': user.id},
        );

        debugPrint('Challenge na-add na via RPC: $response');

        // I-reload ang stats para ma-update ang local state
        await loadProfileStats();
      } catch (rpcError) {
        debugPrint('RPC failed, using fallback method: $rpcError');
        await _addChallengeFallback();
      }

      // I-add sa activity log
      await _addActivity('Natapos ang isang challenge');
    } catch (e) {
      debugPrint('Error sa pag-add og challenge: $e');
      rethrow;
    }
  }

  // Fallback method para sa challenge
  Future<void> _addChallengeFallback() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      final currentStats = await _supabase
          .from('user_stats')
          .select()
          .eq('user_id', user.id)
          .maybeSingle();

      if (currentStats == null) {
        await _supabase.from('user_stats').insert({
          'user_id': user.id,
          'points': 0,
          'challenges_completed': 1,
          'trees_planted': 0,
        });
      } else {
        await _supabase
            .from('user_stats')
            .update({
              'challenges_completed':
                  (currentStats['challenges_completed'] ?? 0) + 1,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('user_id', user.id);
      }

      // I-update ang local state
      _challengesCompleted = (currentStats?['challenges_completed'] ?? 0) + 1;
      notifyListeners();

      debugPrint('Challenge na-add na via fallback method');
    } catch (e) {
      debugPrint('Challenge fallback failed din: $e');
      rethrow;
    }
  }

  // Private method para sa pag-add og activity
  Future<void> _addActivity(String description) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      await _supabase.from('user_activity').insert({
        'user_id': user.id,
        'description': description,
        'created_at': DateTime.now().toIso8601String(),
      });

      debugPrint('Activity na-add na: $description');

      // I-reload ang recent activity
      final activity = await _supabase
          .from('user_activity')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false)
          .limit(5);

      _recentActivity = List<Map<String, dynamic>>.from(activity);
    } catch (e) {
      debugPrint('Error sa pag-add ng activity: $e');
      // Dili na i-rethrow kay activity logging is not critical
    }
  }

  // Add this method to ProfileService class
  Future<List<Map<String, dynamic>>> getQuizHistory() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return [];

      final quizResults = await Supabase.instance.client
          .from('quiz_results')
          .select()
          .eq('user_id', user.id)
          .order('completed_at', ascending: false);

      return List<Map<String, dynamic>>.from(quizResults);
    } catch (e) {
      debugPrint('Error getting quiz history: $e');
      return [];
    }
  }
}
