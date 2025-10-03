import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileService extends ChangeNotifier {
  static final ProfileService _instance = ProfileService._internal();
  factory ProfileService() => _instance;
  ProfileService._internal();

  final _supabase = Supabase.instance.client;

  // Profile stats - user statistics
  int _treesPlanted = 0;
  int _challengesCompleted = 0;
  int _points = 0;
  List<Map<String, dynamic>> _recentActivity = [];

  // Getters to access stats
  int get treesPlanted => _treesPlanted;
  int get challengesCompleted => _challengesCompleted;
  int get points => _points;
  List<Map<String, dynamic>> get recentActivity => _recentActivity;

  // Load profile stats - fetch stats from database
  Future<void> loadProfileStats() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      // Get stats from user_stats table
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
        // Create default stats if not exists
        await _supabase.from('user_stats').upsert({
          'user_id': user.id,
          'trees_planted': 0,
          'challenges_completed': 0,
          'points': 0,
        }, onConflict: 'user_id');

        // Set default values
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
      debugPrint('Error loading profile stats: $e');
    }
  }

  // Update trees planted - for tree planting feature
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

      // Add to activity log
      await _addActivity('Planted a tree');

      notifyListeners();
    } catch (e) {
      debugPrint('Error updating trees planted: $e');
      rethrow;
    }
  }

  // Update challenges count - manual update if needed
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

  // Add points from quiz - for quiz feature
  Future<void> addPoints(int points) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        debugPrint('No logged in user - cannot save points');
        throw Exception('User not logged in');
      }

      debugPrint('Adding points for user: ${user.id}, Points: $points');

      // Try RPC function first
      try {
        final response = await _supabase.rpc(
          'add_user_points',
          params: {'user_id_param': user.id, 'points_to_add': points},
        );

        debugPrint('Points added via RPC: $response');

        // Reload stats to update local state
        await loadProfileStats();
      } catch (rpcError) {
        debugPrint('RPC failed, using fallback method: $rpcError');
        await _addPointsFallback(points);
      }

      // Add to activity log
      await _addActivity('Earned $points points from quiz');
    } catch (e) {
      debugPrint('Error adding points: $e');
      rethrow;
    }
  }

  // Fallback method if RPC fails
  Future<void> _addPointsFallback(int points) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      // Get current stats
      final currentStats = await _supabase
          .from('user_stats')
          .select()
          .eq('user_id', user.id)
          .maybeSingle();

      if (currentStats == null) {
        // Create new record
        await _supabase.from('user_stats').insert({
          'user_id': user.id,
          'points': points,
          'challenges_completed': 0,
          'trees_planted': 0,
        });
      } else {
        // Update existing record
        await _supabase
            .from('user_stats')
            .update({
              'points': (currentStats['points'] ?? 0) + points,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('user_id', user.id);
      }

      // Update local state
      _points = (currentStats?['points'] ?? 0) + points;
      notifyListeners();

      debugPrint('Points added via fallback method');
    } catch (e) {
      debugPrint('Fallback method also failed: $e');
      rethrow;
    }
  }

  // Add completed challenge - for quiz completion
  Future<void> addCompletedChallenge() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        debugPrint('No logged in user - cannot save challenge');
        throw Exception('User not logged in');
      }

      debugPrint('Adding completed challenge for user: ${user.id}');

      // Try RPC function first
      try {
        final response = await _supabase.rpc(
          'add_user_challenge',
          params: {'user_id_param': user.id},
        );

        debugPrint('Challenge added via RPC: $response');

        // Reload stats to update local state
        await loadProfileStats();
      } catch (rpcError) {
        debugPrint('RPC failed, using fallback method: $rpcError');
        await _addChallengeFallback();
      }

      // Add to activity log
      await _addActivity('Completed a challenge');
    } catch (e) {
      debugPrint('Error adding challenge: $e');
      rethrow;
    }
  }

  // Fallback method for challenge
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

      // Update local state
      _challengesCompleted = (currentStats?['challenges_completed'] ?? 0) + 1;
      notifyListeners();

      debugPrint('Challenge added via fallback method');
    } catch (e) {
      debugPrint('Challenge fallback also failed: $e');
      rethrow;
    }
  }

  // Private method to add activity
  Future<void> _addActivity(String description) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      await _supabase.from('user_activity').insert({
        'user_id': user.id,
        'description': description,
        'created_at': DateTime.now().toIso8601String(),
      });

      debugPrint('Activity added: $description');

      // Reload recent activity
      final activity = await _supabase
          .from('user_activity')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false)
          .limit(5);

      _recentActivity = List<Map<String, dynamic>>.from(activity);
    } catch (e) {
      debugPrint('Error adding activity: $e');
      // Don't rethrow since activity logging is not critical
    }
  }

  // Get quiz history
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

  // Save detailed quiz history
  Future<void> saveQuizHistory({
    required String categoryId,
    required String categoryName,
    required int score,
    required int totalQuestions,
    required int correctAnswers,
    required int timeSpent,
    required String difficulty,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      await _supabase.from('quiz_history').insert({
        'user_id': userId,
        'category_id': categoryId,
        'category_name': categoryName,
        'score': score,
        'total_questions': totalQuestions,
        'correct_answers': correctAnswers,
        'time_spent': timeSpent,
        'difficulty': difficulty,
        'completed_at': DateTime.now().toIso8601String(),
      });

      debugPrint('Quiz history saved successfully');
    } catch (e) {
      debugPrint('Error saving quiz history: $e');
      rethrow;
    }
  }
}
