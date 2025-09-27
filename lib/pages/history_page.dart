import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aigrove/services/user_service.dart';
import 'package:aigrove/services/profile_service.dart';
import 'package:intl/intl.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  List<Map<String, dynamic>> _quizHistory = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadHistory();
  }

  // Mag-load sa history data
  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);

    try {
      // Load scan history from UserService
      await context.read<UserService>().loadUserScans();

      // Load quiz history from database
      // ignore: use_build_context_synchronously
      final profileService = context.read<ProfileService>();
      final quizResults = await profileService.getQuizHistory();

      if (mounted) {
        setState(() {
          _quizHistory = quizResults;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error sa pag-load sa history: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('May problema sa pag-load sa history: $e')),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity History'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.camera_alt), text: 'Scans'),
            Tab(icon: Icon(Icons.quiz), text: 'Quizzes'),
          ],
          indicatorColor: Colors.white,
          labelColor: Colors.white,
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadHistory,
              child: TabBarView(
                controller: _tabController,
                children: [_buildScanHistory(), _buildQuizHistory()],
              ),
            ),
    );
  }

  Widget _buildScanHistory() {
    final userService = context.watch<UserService>();
    final scans = userService.userScans;

    if (scans.isEmpty) {
      return _buildEmptyState(
        'No Scan History',
        'Wala pa kay mga na-scan na mangrove. I-scan para makita diri.',
        Icons.camera,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: scans.length,
      itemBuilder: (context, index) {
        final scan = scans[index];
        final date = DateTime.parse(scan['created_at']);
        final formattedDate = DateFormat('MMM d, yyyy • h:mm a').format(date);

        return Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          child: ListTile(
            leading: _buildScanImage(scan['image_url']),
            title: Text(
              scan['species_name'],
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(formattedDate),
                if (scan['notes'] != null &&
                    scan['notes'].toString().isNotEmpty)
                  Text(
                    'Notes: ${scan['notes']}',
                    style: const TextStyle(fontStyle: FontStyle.italic),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _showScanDetails(scan),
          ),
        );
      },
    );
  }

  Widget _buildScanImage(String? imageUrl) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(4),
      ),
      child: imageUrl != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.eco, color: Colors.green),
              ),
            )
          : const Icon(Icons.eco, color: Colors.green),
    );
  }

  void _showScanDetails(Map<String, dynamic> scan) {
    // Implementasyon sa pag-display sa detalye sa scan
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        final date = DateTime.parse(scan['created_at']);
        final formattedDate = DateFormat('MMMM d, yyyy • h:mm a').format(date);

        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Species name header
              Text(
                scan['species_name'],
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              // Date
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 16),
                  const SizedBox(width: 8),
                  Text(formattedDate),
                ],
              ),
              const SizedBox(height: 8),

              // Location
              Row(
                children: [
                  const Icon(Icons.location_on, size: 16),
                  const SizedBox(width: 8),
                  Text('Lat: ${scan['latitude']}, Long: ${scan['longitude']}'),
                ],
              ),
              const SizedBox(height: 16),

              // Image if available
              if (scan['image_url'] != null)
                Center(
                  child: Container(
                    constraints: const BoxConstraints(maxHeight: 200),
                    child: Image.network(
                      scan['image_url'],
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: 150,
                        color: Colors.grey.shade200,
                        child: const Center(
                          child: Icon(Icons.broken_image, size: 64),
                        ),
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 16),

              // Notes
              Text('Notes:', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(
                scan['notes'] ?? 'No notes added',
                style: TextStyle(
                  fontStyle: scan['notes'] == null
                      ? FontStyle.italic
                      : FontStyle.normal,
                  color: scan['notes'] == null
                      ? Colors.grey.shade600
                      : Colors.black,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuizHistory() {
    if (_quizHistory.isEmpty) {
      return _buildEmptyState(
        'No Quiz History',
        'Wala pa kay completed quizzes. Suwayi ang mga quiz sa Challenge page.',
        Icons.quiz,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: _quizHistory.length,
      itemBuilder: (context, index) {
        final quiz = _quizHistory[index];
        final date = DateTime.parse(quiz['completed_at']);
        final formattedDate = DateFormat('MMM d, yyyy • h:mm a').format(date);
        final score = quiz['score'];
        final totalQuestions = quiz['total_questions'];
        final percentage = (score / totalQuestions * 100).round();

        Color scoreColor;
        if (percentage >= 80) {
          scoreColor = Colors.green;
        } else if (percentage >= 60) {
          scoreColor = Colors.orange;
        } else {
          scoreColor = Colors.red;
        }

        return Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          child: ListTile(
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                // ignore: deprecated_member_use
                color: scoreColor.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '$percentage%',
                  style: TextStyle(
                    color: scoreColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            title: Text(
              quiz['category_name'],
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(formattedDate),
                Text('Score: $score/$totalQuestions'),
              ],
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _showQuizDetails(quiz),
          ),
        );
      },
    );
  }

  void _showQuizDetails(Map<String, dynamic> quiz) {
    final date = DateTime.parse(quiz['completed_at']);
    final formattedDate = DateFormat('MMMM d, yyyy • h:mm a').format(date);
    final score = quiz['score'];
    final totalQuestions = quiz['total_questions'];
    final percentage = (score / totalQuestions * 100).round();

    Color scoreColor;
    String performance;
    if (percentage >= 90) {
      scoreColor = Colors.green.shade700;
      performance = 'Excellent! 🌟';
    } else if (percentage >= 80) {
      scoreColor = Colors.green;
      performance = 'Great job! 👍';
    } else if (percentage >= 70) {
      scoreColor = Colors.lightGreen;
      performance = 'Good work! 👌';
    } else if (percentage >= 60) {
      scoreColor = Colors.orange;
      performance = 'Not bad! 🙂';
    } else {
      scoreColor = Colors.red;
      performance = 'Keep practicing! 💪';
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                quiz['category_name'],
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Score circle
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  // ignore: deprecated_member_use
                  color: scoreColor.withOpacity(0.1),
                  border: Border.all(color: scoreColor, width: 3),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$percentage%',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: scoreColor,
                      ),
                    ),
                    Text(
                      '$score/$totalQuestions',
                      style: TextStyle(
                        color: scoreColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              Text(
                performance,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),

              // Stats
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildQuizStat('Date', formattedDate, Icons.calendar_today),
                  _buildQuizStat(
                    'Time Spent',
                    '${quiz['time_spent'] ~/ 60}:${(quiz['time_spent'] % 60).toString().padLeft(2, '0')}',
                    Icons.timer,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              if (quiz['difficulty'] != null)
                _buildQuizStat(
                  'Difficulty',
                  quiz['difficulty'].toString().toUpperCase(),
                  Icons.trending_up,
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuizStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.grey.shade700),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        Text(
          label,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildEmptyState(String title, String message, IconData icon) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade700),
            ),
          ],
        ),
      ),
    );
  }
}
