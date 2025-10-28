import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileService extends ChangeNotifier {
  final _supabase = Supabase.instance.client;

  int _points = 0;
  int _challengesCompleted = 0;
  int _totalScans = 0;
  List<Map<String, dynamic>> _recentActivity = [];

  int get points => _points;
  int get challengesCompleted => _challengesCompleted;
  int get totalScans => _totalScans;
  List<Map<String, dynamic>> get recentActivity => _recentActivity;

  // I-load ang profile stats gikan sa user_stats table
  Future<void> loadProfileStats() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not logged in');

      debugPrint('Loading profile stats para sa user: $userId');

      // I-load ang stats gikan sa user_stats table
      final statsResponse = await _supabase
          .from('user_stats')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      debugPrint('Stats response: $statsResponse');

      if (statsResponse != null) {
        _points = statsResponse['total_points'] ?? 0;
        _challengesCompleted = statsResponse['challenges_completed'] ?? 0;
        debugPrint('Loaded points: $_points, challenges: $_challengesCompleted');
      } else {
        // Kung wala pa entry, i-create!
        debugPrint('Walay user_stats entry, gi-create karon...');
        await _supabase.from('user_stats').insert({
          'user_id': userId,
          'total_points': 0,
          'challenges_completed': 0,
          'trees_planted': 0,
        });
        _points = 0;
        _challengesCompleted = 0;
        debugPrint('User stats entry created!');
      }

      // I-count ang total scans gikan sa scans table
      final scansResponse = await _supabase
          .from('scans')
          .select()
          .eq('user_id', userId)
          .count();
      
      _totalScans = scansResponse.count;
      debugPrint('Total scans: $_totalScans');

      notifyListeners();
    } catch (e) {
      debugPrint('Error loading profile stats: $e');
      // Set default values kung naa error
      _points = 0;
      _challengesCompleted = 0;
      _totalScans = 0;
      notifyListeners();
    }
  }

  // I-load ang recent activity gikan sa quiz_history ug scans
  Future<void> loadRecentActivity({int limit = 10}) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      List<Map<String, dynamic>> activities = [];

      // I-load ang quiz history
      final quizHistory = await _supabase
          .from('quiz_history')
          .select()
          .eq('user_id', userId)
          .order('completed_at', ascending: false)
          .limit(limit);

      // I-convert ang quiz history to activity format
      for (var quiz in quizHistory) {
        activities.add({
          'activity_type': 'quiz',
          'title': 'Completed ${quiz['category_name']} Quiz',
          'description': 'Scored ${quiz['correct_answers']}/${quiz['total_questions']} correct • ${((quiz['correct_answers'] / quiz['total_questions']) * 100).round()}%',
          'created_at': quiz['completed_at'],
          'metadata': {
            'score': quiz['score'],
            'difficulty': quiz['difficulty'],
            'is_passing': quiz['is_passing'] ?? false,
          },
        });
      }

      // I-load pud ang recent scans (optional, kung gusto nimo i-include)
      try {
        final recentScans = await _supabase
            .from('scans')
            .select('species_name, scientific_name, created_at')
            .eq('user_id', userId)
            .order('created_at', ascending: false)
            .limit(5);

        // I-add ang scans sa activities
        for (var scan in recentScans) {
          activities.add({
            'activity_type': 'scan',
            'title': 'Scanned ${scan['species_name']}',
            'description': scan['scientific_name'] ?? '',
            'created_at': scan['created_at'],
            'metadata': {},
          });
        }
      } catch (e) {
        debugPrint('Error loading scans: $e');
      }

      // I-sort ang activities by created_at
      activities.sort((a, b) {
        final aDate = DateTime.parse(a['created_at']);
        final bDate = DateTime.parse(b['created_at']);
        return bDate.compareTo(aDate);
      });

      // I-limit ang results
      _recentActivity = activities.take(limit).toList();
      
      debugPrint('Loaded ${_recentActivity.length} recent activities');
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading recent activity: $e');
      _recentActivity = [];
      notifyListeners();
    }
  }

  // BAG-O: Method para mag-delete ng quiz result
  Future<void> deleteQuizResult(String quizResultId) async {
    try {
      await _supabase
          .from('quiz_history') // I-change pud ang table name to quiz_history
          .delete()
          .eq('id', quizResultId);

      debugPrint('Quiz result deleted successfully: $quizResultId');
    } catch (e) {
      debugPrint('Error deleting quiz result: $e');
      rethrow;
    }
  }

  // I-get ang quiz history (same as before)
  Future<List<Map<String, dynamic>>> getQuizHistory() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return [];

      final response = await _supabase
          .from('quiz_history')
          .select()
          .eq('user_id', userId)
          .order('completed_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error getting quiz history: $e');
      return [];
    }
  }

  // I-mark ang category as completed
  Future<void> markCategoryAsCompleted(String categoryId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not logged in');

      // I-use ang upsert with onConflict parameter para i-handle ang duplicate
      await _supabase.from('completed_categories').upsert(
        {
          'user_id': userId,
          'category_id': categoryId,
          'completed_at': DateTime.now().toIso8601String(),
        },
        onConflict: 'user_id,category_id',
      );
      
      debugPrint('Category $categoryId na-mark/update as completed');
    } catch (e) {
      debugPrint('Error marking category as completed: $e');
    }
  }

  // I-get ang completed categories
  Future<Set<String>> getCompletedCategories() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return {};

      final response = await _supabase
          .from('completed_categories')
          .select('category_id')
          .eq('user_id', userId);

      return (response as List)
          .map((item) => item['category_id'] as String)
          .toSet();
    } catch (e) {
      debugPrint('Error getting completed categories: $e');
      return {};
    }
  }

  // I-save ang quiz history - simplified, wala na ang user_activity insert
  Future<void> saveQuizHistory({
    required String categoryId,
    required String categoryName,
    required int score,
    required int totalQuestions,
    required int correctAnswers,
    required int timeSpent,
    required String difficulty,
    required bool isPassing,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not logged in');

      // I-save sa quiz_history table lang
      await _supabase.from('quiz_history').insert({
        'user_id': userId,
        'category_id': categoryId,
        'category_name': categoryName,
        'score': score,
        'total_questions': totalQuestions,
        'correct_answers': correctAnswers,
        'time_spent': timeSpent,
        'difficulty': difficulty,
        'is_passing': isPassing,
        'completed_at': DateTime.now().toIso8601String(),
      });
      
      debugPrint('Quiz history saved successfully');
      
      // I-reload ang recent activity after saving
      await loadRecentActivity();
    } catch (e) {
      debugPrint('Error saving quiz history: $e');
      rethrow;
    }
  }

  // I-add ang points
  Future<void> addPoints(int points) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      debugPrint('Adding $points points para sa user $userId');

      // Check first kung naa na ba ang user_stats entry
      final existing = await _supabase
          .from('user_stats')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (existing == null) {
        // I-create ang entry kung wala pa
        await _supabase.from('user_stats').insert({
          'user_id': userId,
          'total_points': points,
          'challenges_completed': 0,
          'trees_planted': 0,
        });
        _points = points;
      } else {
        // I-update ang existing entry
        await _supabase
            .from('user_stats')
            .update({'total_points': (existing['total_points'] ?? 0) + points})
            .eq('user_id', userId);
        _points = (existing['total_points'] ?? 0) + points;
      }

      debugPrint('Points updated successfully! New total: $_points');
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding points: $e');
    }
  }

  // I-add ang completed challenge count
  Future<void> addCompletedChallenge() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      debugPrint('Adding completed challenge para sa user $userId');

      // Check first kung naa na ba ang user_stats entry
      final existing = await _supabase
          .from('user_stats')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (existing == null) {
        // I-create ang entry kung wala pa
        await _supabase.from('user_stats').insert({
          'user_id': userId,
          'total_points': 0,
          'challenges_completed': 1,
          'trees_planted': 0,
        });
        _challengesCompleted = 1;
      } else {
        // I-update ang existing entry
        await _supabase
            .from('user_stats')
            .update({
              'challenges_completed': (existing['challenges_completed'] ?? 0) + 1,
            })
            .eq('user_id', userId);
        _challengesCompleted = (existing['challenges_completed'] ?? 0) + 1;
      }

      debugPrint('Challenges updated successfully! New total: $_challengesCompleted');
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding completed challenge: $e');
    }
  }
}
