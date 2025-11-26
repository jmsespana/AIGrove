import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:aigrove/services/user_service.dart';
import 'package:aigrove/services/profile_service.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import '../theme/app_theme.dart';

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

  // Sample scan history - dapat gikan ni sa database later

  // Cache para sa place names para dili na mag-convert pag balik-balik
  final Map<String, String> _placeNameCache = {};

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
      debugPrint('Error loading history: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('May problema sa pag-load sa history: $e')),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  // Method para kuhaon ang place name gikan sa coordinates
  // BAG-O: I-fix ang _getPlaceName para dili mag-error kung null ang values
  Future<String> _getPlaceName(LatLng location) async {
    // I-check sa una kung naa na sa cache
    final cacheKey = '${location.latitude},${location.longitude}';
    if (_placeNameCache.containsKey(cacheKey)) {
      return _placeNameCache[cacheKey]!;
    }

    try {
      // I-convert ang coordinates to place name
      List<Placemark> placemarks = await placemarkFromCoordinates(
        location.latitude,
        location.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;

        // I-format ang place name - SAFE nga way, walay null check operator
        String placeName = '';

        // Prioritize locality (city/municipality) and subadministrativeArea (province)
        if (place.locality?.isNotEmpty ?? false) {
          placeName = place.locality!;
        } else if (place.subLocality?.isNotEmpty ?? false) {
          placeName = place.subLocality!;
        } else if (place.thoroughfare?.isNotEmpty ?? false) {
          placeName = place.thoroughfare!;
        }

        // I-add ang province kung available
        if (place.subAdministrativeArea?.isNotEmpty ?? false) {
          if (placeName.isNotEmpty) {
            placeName += ', ${place.subAdministrativeArea}';
          } else {
            placeName = place.subAdministrativeArea!;
          }
        }

        // Kung wala gihapon, gamiton ang administrative area or country
        if (placeName.isEmpty) {
          if (place.administrativeArea?.isNotEmpty ?? false) {
            placeName = place.administrativeArea!;
          } else if (place.country?.isNotEmpty ?? false) {
            placeName = place.country!;
          }
        }

        // I-save sa cache kung naay value
        if (placeName.isNotEmpty) {
          _placeNameCache[cacheKey] = placeName;
          return placeName;
        }
      }
    } catch (e) {
      debugPrint('Error getting place name: $e');
    }

    // Fallback: ibalik ang coordinates kung dili makuha ang place name
    final fallback =
        '${location.latitude.toStringAsFixed(4)}, ${location.longitude.toStringAsFixed(4)}';
    _placeNameCache[cacheKey] = fallback; // I-cache pud ang fallback
    return fallback;
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
      body: Container(
        decoration: AppTheme.getPageGradient(context),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _loadHistory,
                child: TabBarView(
                  controller: _tabController,
                  children: [_buildScanHistory(), _buildQuizHistory()],
                ),
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
        'You haven\'t scanned any mangroves yet. Start scanning to see them here.',
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
          margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            onTap: () => _showScanDetails(scan),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Photo thumbnail
                  _buildScanThumbnail(scan['image_url']),
                  const SizedBox(width: 12),

                  // Content area
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Species name
                        Text(
                          scan['species_name'] ?? 'Unknown Species',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),

                        // Date with icon
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 14,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              formattedDate,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),

                        // Location with place name (kung naa coordinates)
                        if (scan['latitude'] != null &&
                            scan['longitude'] != null)
                          FutureBuilder<String>(
                            future: _getPlaceName(
                              LatLng(
                                scan['latitude'].toDouble(),
                                scan['longitude'].toDouble(),
                              ),
                            ),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Row(
                                  children: [
                                    Icon(
                                      Icons.location_on,
                                      size: 14,
                                      color: Colors.grey[600],
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Loading location...',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                );
                              }

                              return Row(
                                children: [
                                  Icon(
                                    Icons.location_on,
                                    size: 14,
                                    color: Colors.red[700],
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      snapshot.data ?? 'Unknown location',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),

                        // Notes preview (kung naa)
                        if (scan['notes'] != null &&
                            scan['notes'].toString().isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.notes,
                                size: 14,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  scan['notes'],
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontStyle: FontStyle.italic,
                                    color: Colors.grey[600],
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Arrow icon
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey[400],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// BAG-O: Mas nindot nga thumbnail para sa scan photos
  Widget _buildScanThumbnail(String? imageUrl) {
    return Container(
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: imageUrl != null && imageUrl.isNotEmpty
            ? _buildImage(imageUrl)
            : _buildPlaceholder(),
      ),
    );
  }

  /// BAG-O: Image widget with proper error handling
  Widget _buildImage(String imageUrl) {
    // Kung file path gikan sa local storage
    if (imageUrl.startsWith('/')) {
      return Image.file(
        File(imageUrl),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          debugPrint('Error loading local image: $error');
          return _buildPlaceholder();
        },
      );
    }

    // Kung URL gikan sa network (Supabase storage)
    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Center(
          child: CircularProgressIndicator(
            value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                : null,
            strokeWidth: 2,
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        debugPrint('Error loading network image: $error');
        return _buildPlaceholder();
      },
    );
  }

  /// BAG-O: Placeholder para kung walay image
  Widget _buildPlaceholder() {
    return Container(
      color: Colors.green.shade50,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.eco, size: 40, color: Colors.green.shade300),
          const SizedBox(height: 4),
          Text(
            'No Photo',
            style: TextStyle(fontSize: 10, color: Colors.green.shade300),
          ),
        ],
      ),
    );
  }

  void _showScanDetails(Map<String, dynamic> scan) {
    final date = DateTime.parse(scan['created_at']);
    final formattedDate = DateFormat('MMMM d, yyyy • h:mm a').format(date);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  // Full-width image
                  if (scan['image_url'] != null && scan['image_url'].isNotEmpty)
                    Container(
                      width: double.infinity,
                      height: 250,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            // ignore: deprecated_member_use
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: _buildImage(scan['image_url']),
                      ),
                    ),

                  // Species name header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.forest,
                          color: Colors.green.shade700,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          scan['species_name'] ?? 'Unknown Species',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Date
                  _buildDetailRow(
                    Icons.calendar_today,
                    'Date & Time',
                    formattedDate,
                  ),
                  const SizedBox(height: 12),

                  // Location with place name (kung naa coordinates)
                  if (scan['latitude'] != null && scan['longitude'] != null)
                    FutureBuilder<String>(
                      future: _getPlaceName(
                        LatLng(
                          scan['latitude'].toDouble(),
                          scan['longitude'].toDouble(),
                        ),
                      ),
                      builder: (context, snapshot) {
                        return _buildDetailRow(
                          Icons.location_on,
                          'Location',
                          snapshot.data ??
                              '${scan['latitude'].toStringAsFixed(6)}, ${scan['longitude'].toStringAsFixed(6)}',
                        );
                      },
                    ),
                  const SizedBox(height: 12),

                  // Notes section
                  const Divider(),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.notes, color: Colors.grey[700], size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Notes',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      scan['notes']?.toString().isNotEmpty == true
                          ? scan['notes']
                          : 'No notes added',
                      style: TextStyle(
                        fontStyle: scan['notes']?.toString().isEmpty ?? true
                            ? FontStyle.italic
                            : FontStyle.normal,
                        color: scan['notes']?.toString().isEmpty ?? true
                            ? Colors.grey[600]
                            : Colors.black87,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // BAG-O: Action buttons (Close ug Delete)
                  Row(
                    children: [
                      // Close button
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close),
                          label: const Text('Close'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            backgroundColor: Colors.grey.shade600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Delete button
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context); // I-close ang bottom sheet
                            _confirmDeleteScan(
                              scan,
                            ); // I-confirm ang pag-delete
                          },
                          icon: const Icon(Icons.delete),
                          label: const Text('Delete'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            backgroundColor: Colors.red.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// BAG-O: Helper widget para sa detail rows
  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.green.shade700, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ...existing code para sa quiz history...
  Widget _buildQuizHistory() {
    if (_quizHistory.isEmpty) {
      return _buildEmptyState(
        'No Quiz History',
        'You haven\'t completed any quizzes yet. Try the quizzes in the Challenge page.',
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
                      '${percentage}/100',
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

              const SizedBox(height: 24),

              // BAG-O: Action buttons para sa quiz
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                      label: const Text('Close'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        backgroundColor: Colors.grey.shade600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _confirmDeleteQuiz(quiz);
                      },
                      icon: const Icon(Icons.delete),
                      label: const Text('Delete'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        backgroundColor: Colors.red.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // BAG-O: Method para mag-confirm sa pag-delete ng scan
  Future<void> _confirmDeleteScan(Map<String, dynamic> scan) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Scan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Are you sure you want to delete this scan?'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.eco, color: Colors.red.shade700),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      scan['species_name'] ?? 'Unknown Species',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.red.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'This action cannot be undone.',
              style: TextStyle(
                fontStyle: FontStyle.italic,
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context, true),
            icon: const Icon(Icons.delete),
            label: const Text('Delete'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
            ),
          ),
        ],
      ),
    );

    // Kung gi-confirm ang delete
    if (confirm == true) {
      await _deleteScan(scan);
    }
  }

  // BAG-O: Method para mag-delete ng scan sa database
  Future<void> _deleteScan(Map<String, dynamic> scan) async {
    try {
      // I-show ang loading indicator
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              SizedBox(width: 12),
              Text('Deleting scan...'),
            ],
          ),
          duration: Duration(seconds: 2),
        ),
      );

      // I-delete gikan sa UserService
      final userService = context.read<UserService>();
      await userService.deleteScan(scan['id']);

      // I-reload ang history
      await _loadHistory();

      // I-show success message
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Successfully deleted ${scan['species_name'] ?? 'scan'}',
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green.shade700,
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      debugPrint('Error deleting scan: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete scan: $e'),
          backgroundColor: Colors.red.shade700,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  // BAG-O: Method para mag-confirm sa pag-delete ng quiz
  Future<void> _confirmDeleteQuiz(Map<String, dynamic> quiz) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Quiz Result'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Are you sure you want to delete this quiz result?'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.quiz, color: Colors.red.shade700),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      quiz['category_name'],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.red.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'This will also remove the points earned from this quiz.',
              style: TextStyle(
                fontStyle: FontStyle.italic,
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context, true),
            icon: const Icon(Icons.delete),
            label: const Text('Delete'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
            ),
          ),
        ],
      ),
    );

    // Kung gi-confirm ang delete
    if (confirm == true) {
      await _deleteQuiz(quiz);
    }
  }

  // BAG-O: Method para mag-delete ng quiz sa database
  Future<void> _deleteQuiz(Map<String, dynamic> quiz) async {
    try {
      // I-show ang loading indicator
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              SizedBox(width: 12),
              Text('Deleting quiz result...'),
            ],
          ),
          duration: Duration(seconds: 2),
        ),
      );

      // I-delete gikan sa ProfileService
      final profileService = context.read<ProfileService>();
      final quizId = quiz['id'].toString(); // I-ensure nga string

      debugPrint('Deleting quiz with ID: $quizId');
      debugPrint('Quiz data: $quiz');

      await profileService.deleteQuizResult(quizId);

      // I-reload ang history para makita ang updated data
      await _loadHistory();

      // I-show success message
      if (!mounted) return;
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Successfully deleted ${quiz['category_name']} quiz result',
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green.shade700,
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      debugPrint('Error deleting quiz: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete quiz result: ${e.toString()}'),
          backgroundColor: Colors.red.shade700,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  /// BAG-O: Helper widget para sa quiz statistics
  Widget _buildQuizStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.green.shade700, size: 24),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
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

// Model class para sa scan history
class ScanHistory {
  final String species;
  final LatLng location;
  final DateTime dateScanned;
  final double confidence;

  ScanHistory({
    required this.species,
    required this.location,
    required this.dateScanned,
    required this.confidence,
  });
}
