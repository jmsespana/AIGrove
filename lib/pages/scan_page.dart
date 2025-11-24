import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import '../services/ml_service.dart';
import '../services/user_service.dart';
import '../services/location_service.dart'; // I-add ni
import '../services/llm_service.dart'; // I-add para sa AI insights
import '../services/chatbot_service.dart'; // I-add para sa image explanation
import '../services/profile_service.dart';
import '../models/detection_result.dart';
import '../widgets/detection_overlay.dart';
import '../theme/app_theme.dart';
import 'species_info_page.dart';

/// Scan Page with YOLOv8 Integration ug LLM insights
///
/// Kini ang page para mag-scan ug detect og mangroves with AI-powered insights
class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  final MLService _mlService = MLService();
  final ImagePicker _picker = ImagePicker();
  final LocationService _locationService = LocationService(); // I-add ni
  final LLMService _llmService = LLMService(); // I-add para sa LLM integration
  final ChatbotService _chatbotService =
      ChatbotService(); // I-add para sa image explanation

  File? _selectedImage;
  File? _processedImage; // Para sa fixed orientation ug resized image
  Size? _imageSize; // Store actual image dimensions
  List<DetectionResult>? _detections;
  bool _isLoading = false;
  String? _errorMessage;
  bool _nonMangroveResult = false;
  String?
  _lastSelectedSource; // Track which button was last pressed ('camera' or 'gallery')
  double? _currentLatitude; // Current scan location latitude
  double? _currentLongitude; // Current scan location longitude
  String?
  _currentLocationAddress; // Current location address (barangay/municipality)

  static const Color _mintGreen = Color(
    0xFFB9F6CA,
  ); // Mint green para sa loading

  static const List<String> _defaultLabels = [
    'Avicennia Marina',
    'Avicennia Officinalis',
    'Bruguiera Cylindrica',
    'Bruguiera Gymnorhiza',
    'Ceriops Tagal',
    'Excoecaria Agallocha',
    'Lumnitzera Littorea',
    'Nypa Fruticans',
    'Rhizophora Apiculata',
    'Rhizophora Mucronata',
    'Rhizophora Stylosa',
    'Sonneratia Alba',
    'Sonneratia Caseolaris',
    'Sonneratia Ovata',
    'Xylocarpus Granatum',
  ];

  List<String> _labels = [];

  @override
  void initState() {
    super.initState();
    _labels = List.from(_defaultLabels); // I-load ang default labels
    _initializeModel();
  }

  /// Initialize ang ML model
  Future<void> _initializeModel() async {
    try {
      setState(() => _isLoading = true);
      await _mlService.loadModel();
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading model: $e';
        _isLoading = false;
      });
    }
  }

  /// Pick image from gallery
  Future<void> _pickImageFromGallery() async {
    try {
      setState(() => _lastSelectedSource = 'gallery');
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        await _processImage(File(image.path));
      }
    } catch (e) {
      _showError('Error picking image: $e');
    }
  }

  /// Take photo using camera
  Future<void> _takePhoto() async {
    try {
      setState(() => _lastSelectedSource = 'camera');
      final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
      if (photo != null) {
        await _processImage(File(photo.path));
      }
    } catch (e) {
      _showError('Error taking photo: $e');
    }
  }

  /// Fix image orientation ug resize para sa model (640x640)
  Future<File> _fixImageOrientation(File imageFile) async {
    // Basaha ang original image
    final imageBytes = await imageFile.readAsBytes();
    img.Image? originalImage = img.decodeImage(imageBytes);

    if (originalImage == null) {
      throw Exception('Failed to decode image');
    }

    // I-fix ang EXIF orientation (common issue sa camera captures)
    // Kini mo-rotate sa image based sa EXIF data
    originalImage = img.bakeOrientation(originalImage);

    // Resize to 640x640 maintaining aspect ratio
    // Gamit square crop para match sa model training
    final int size = 640;
    img.Image resizedImage;

    if (originalImage.width > originalImage.height) {
      // Landscape: resize based on height, then crop width
      final scaleFactor = size / originalImage.height;
      final newWidth = (originalImage.width * scaleFactor).round();
      resizedImage = img.copyResize(
        originalImage,
        width: newWidth,
        height: size,
      );
      // Center crop
      final cropX = (newWidth - size) ~/ 2;
      resizedImage = img.copyCrop(
        resizedImage,
        x: cropX,
        y: 0,
        width: size,
        height: size,
      );
    } else {
      // Portrait: resize based on width, then crop height
      final scaleFactor = size / originalImage.width;
      final newHeight = (originalImage.height * scaleFactor).round();
      resizedImage = img.copyResize(
        originalImage,
        width: size,
        height: newHeight,
      );
      // Center crop
      final cropY = (newHeight - size) ~/ 2;
      resizedImage = img.copyCrop(
        resizedImage,
        x: 0,
        y: cropY,
        width: size,
        height: size,
      );
    }

    // Save ang processed image
    final tempDir = await Directory.systemTemp.createTemp('aigrove_processed_');
    final processedFile = File('${tempDir.path}/processed_image.jpg');
    await processedFile.writeAsBytes(img.encodeJpg(resizedImage, quality: 95));

    return processedFile;
  }

  /// I-save ang scan result sa history WITH location
  Future<void> _saveScanToHistory(DetectionResult detection) async {
    try {
      // Kuha ang current location gamit ang LocationService
      debugPrint('🔍 Getting location for scan...');
      final location = await _locationService.getLocationCoordinates();

      final latitude = location['latitude'];
      final longitude = location['longitude'];

      if (latitude != null && longitude != null) {
        debugPrint('✅ Location captured: $latitude, $longitude');
      } else {
        debugPrint(
          '⚠️ Location not available, saving scan without coordinates',
        );
      }

      // Kuha sa user service para ma-sync ang datos sa Supabase
      if (!mounted) return;
      final userService = context.read<UserService>();

      if (userService.isAuthenticated) {
        final capturedAt = DateTime.now().toUtc();
        final double confToSave = detection.confidence;

        await userService.saveScan(
          speciesName: detection.label,
          imageUrl: _selectedImage?.path,
          latitude: latitude,
          longitude: longitude,
          capturedAt: capturedAt,
          confidence: confToSave,
        );

        // I-refresh ang profile stats ug activity
        if (!mounted) return;
        final profileService = context.read<ProfileService>();
        try {
          await Future.wait([
            profileService.loadProfileStats(),
            profileService.loadRecentActivity(limit: 10),
          ]);
        } catch (e) {
          debugPrint('⚠️ Failed to refresh profile stats: $e');
        }

        debugPrint('✅ Supabase scan stored @ $capturedAt');
      } else {
        debugPrint('⚠️ Supabase sync skipped: walay naka-login nga user');
      }

      if (!mounted) return;

      final localTime = DateTime.now();
      final formattedTime = DateFormat(
        'MMM d, yyyy • h:mm a',
      ).format(localTime);

      final locationLabel = (latitude != null && longitude != null)
          ? 'Location: ${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}'
          : 'Location data unavailable';

      // Ipakita ang timestamp aron klaro ang oras nga na-save ang scan
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Scan saved ($formattedTime)\n$locationLabel'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      debugPrint('❌ Error saving scan to history: $e');
      // Dili na nako i-show ang error sa user para dili ma-interrupt ang flow
    }
  }

  /// Process ang image using YOLOv8
  Future<void> _processImage(File imageFile) async {
    setState(() {
      _isLoading = true;
      _selectedImage = imageFile;
      _processedImage = null;
      _detections = null;
      _errorMessage = null;
      _imageSize = null;
      _nonMangroveResult = false;
    });

    try {
      // Kuha ang current location (parallel with image processing)
      debugPrint('📍 Fetching scan location...');
      final locationFuture = _locationService.getLocationCoordinates();

      // I-fix ang orientation ug i-resize to 640x640
      final processedFile = await _fixImageOrientation(imageFile);

      // I-store ang processed image
      setState(() {
        _processedImage = processedFile;
      });

      // Kuha ang processed image dimensions (dapat 640x640 na ni)
      final imageBytes = await processedFile.readAsBytes();
      final decodedImage = img.decodeImage(imageBytes);

      if (decodedImage != null) {
        _imageSize = Size(
          decodedImage.width.toDouble(),
          decodedImage.height.toDouble(),
        );
      }

      // I-run ang detection sa processed image
      final detections = await _mlService.detectObjects(processedFile);

      // ⭐ Mas strict nga thresholds para dili mu-accept og random plants
      const double highConfidenceThreshold =
          0.60; // 60% - Sure kaayo nga mangrove

      // Kuha lang ang best detection
      final bestDetection = detections.isNotEmpty
          ? detections.reduce((a, b) => a.confidence > b.confidence ? a : b)
          : null;

      // I-validate kung legit ba ang detection
      // Kung below 60%, i-treat as non-mangrove and show AI explanation
      if (bestDetection == null ||
          bestDetection.confidence < highConfidenceThreshold) {
        setState(() {
          _detections = null;
          _isLoading = false;
        });

        // Get AI explanation kung unsa ang na-scan
        if (bestDetection != null) {
          _showNonMangroveExplanation(bestDetection, processedFile);
        } else {
          _showError(
            'No objects detected. Please scan a valid mangrove leaf with good lighting and focus.',
          );
        }
        return;
      }

      // I-update ang state with detection (only for >= 60% confidence)
      setState(() {
        _detections = [bestDetection];
        _isLoading = false;
      });

      // Kuha ang location result
      final location = await locationFuture;
      setState(() {
        _currentLatitude = location['latitude'];
        _currentLongitude = location['longitude'];
      });

      if (_currentLatitude != null && _currentLongitude != null) {
        debugPrint(
          '✅ Location captured: $_currentLatitude, $_currentLongitude',
        );

        // I-convert ang coordinates to barangay/municipality address
        try {
          List<Placemark> placemarks = await placemarkFromCoordinates(
            _currentLatitude!,
            _currentLongitude!,
          );

          if (placemarks.isNotEmpty) {
            final place = placemarks.first;
            // I-prioritize ang barangay, kung wala locality (municipality)
            setState(() {
              _currentLocationAddress =
                  place.subLocality ??
                  place.locality ??
                  '${place.locality}, ${place.administrativeArea}';
            });
            debugPrint('📍 Address: $_currentLocationAddress');
          }
        } catch (e) {
          debugPrint('⚠️ Failed to get address: $e');
        }
      } else {
        debugPrint('⚠️ Location not available for this scan');
      }

      // ⭐ Fetch LLM insight asynchronously (dili mag-block sa UI)
      _fetchLLMInsight(bestDetection);

      // I-show ang appropriate feedback based sa confidence level
      if (!mounted) return;

      // High confidence - Sure kaayo (60% and above)
      debugPrint(
        '✅ High confidence detection: ${bestDetection.label} (${(bestDetection.confidence * 100).toStringAsFixed(1)}%)',
      );
      await _saveScanToHistory(bestDetection);
    } catch (e) {
      setState(() {
        _errorMessage = 'Detection failed: $e';
        _isLoading = false;
      });
    }
  }

  /// Fetch LLM insight para sa detected species (async, dili mag-block sa UI)
  Future<void> _fetchLLMInsight(DetectionResult detection) async {
    try {
      debugPrint('🤖 Fetching LLM insight for: ${detection.label}');

      // Call LLM service para kuha ang HTML insight
      final htmlInsight = await _llmService.getSpeciesInsight(
        speciesName: detection.label,
        confidence: detection.confidence,
        latitude: _currentLatitude,
        longitude: _currentLongitude,
        locationAddress: _currentLocationAddress,
      );

      // Update ang detection result with HTML content
      detection.llmInsightHtml = htmlInsight;

      // Refresh ang UI para ma-display ang LLM insight
      if (mounted) {
        setState(() {
          // Force rebuild para ma-update ang DetectionOverlay
          _detections = [detection];
        });
        debugPrint('✅ LLM insight loaded and displayed!');
      }
    } catch (e) {
      debugPrint('❌ Error fetching LLM insight: $e');
      // Dili na i-show ang error sa user, fallback HTML na lang i-use
    }
  }

  /// Show AI-powered explanation kung non-mangrove ang na-scan
  Future<void> _showNonMangroveExplanation(
    DetectionResult detection,
    File imageFile,
  ) async {
    try {
      // Show loading dialog
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Analyzing your image with AI...'),
                ],
              ),
            ),
          ),
        ),
      );

      // Get AI explanation ng actual image
      final explanation = await _chatbotService.explainNonMangroveImage(
        detectedLabel: detection.label,
        confidence: detection.confidence,
        imagePath: imageFile.path,
      );

      // Close loading dialog
      if (!mounted) return;
      Navigator.pop(context);

      // Show explanation in a dialog
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.orange[700]),
              const SizedBox(width: 12),
              const Expanded(
                child: Text('Not a Mangrove', style: TextStyle(fontSize: 20)),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.auto_awesome,
                        color: Colors.orange[700],
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'AI Analysis',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  explanation,
                  style: const TextStyle(fontSize: 15, height: 1.5),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Got it'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                // Trigger new scan
                _pickImageFromGallery();
              },
              icon: const Icon(Icons.camera_alt, size: 18),
              label: const Text('Scan Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    } catch (e) {
      debugPrint('❌ Error showing non-mangrove explanation: $e');
      // Fallback to simple error message
      if (mounted) {
        Navigator.pop(context); // Close loading dialog if open
        _showError(
          'Not a mangrove species! Detected: ${detection.label} (${(detection.confidence * 100).toStringAsFixed(1)}%). Please scan actual mangrove leaves.',
        );
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showNonMangroveInfo(String? assistantMessage) {
    // Inform ang user nga walay match ang model sa mangrove species
    final String message =
        (assistantMessage != null && assistantMessage.trim().isNotEmpty)
        ? assistantMessage.trim()
        : 'No mangrove detected. This likely is not a mangrove.';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.orange[700],
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  void dispose() {
    _mlService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mangrove Scanner',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: Container(
        decoration: AppTheme.getPageGradient(context),
        child: SafeArea(
          child: Column(
            children: [
              // Image display area with card
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _buildImageCard(),
                ),
              ),

              // Results area - Show detection card kung naay resulta
              if (_detections != null && _detections!.isNotEmpty) ...[
                _buildResultsCard(),
              ] else if (_nonMangroveResult) ...[
                _buildNonMangroveCard(),
              ],

              // Action buttons
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageCard() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: 8,
      color: isDarkMode ? Colors.grey[850] : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: _buildImageContent(),
      ),
    );
  }

  Widget _buildImageContent() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDarkMode ? Colors.grey[850]! : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.grey[800]!;
    final subtextColor = isDarkMode ? Colors.grey[400]! : Colors.grey[600]!;

    if (_isLoading) {
      return Container(
        color: Colors.black,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Show the image being analyzed
            if (_selectedImage != null)
              Image.file(_selectedImage!, fit: BoxFit.cover),
            // Semi-transparent overlay with loading indicator
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(
                          color: Colors.green[700],
                          strokeWidth: 3,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Analyzing image...',
                          style: TextStyle(
                            color: Colors.green[700],
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Container(
        color: bgColor,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 80, color: Colors.red[400]),
            const SizedBox(height: 20),
            Text(
              'Oops!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.red[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: subtextColor),
            ),
          ],
        ),
      );
    }

    if (_selectedImage == null) {
      return Container(
        color: bgColor,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.green[900] : Colors.green[50],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.camera_alt_rounded,
                size: 80,
                color: Colors.green[700],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Image Selected',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Choose a photo from gallery or take a new one to identify mangrove species',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: subtextColor,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Display ang PROCESSED image (640x640) para match sa detection coordinates
    final imageToDisplay = _processedImage ?? _selectedImage!;

    return Container(
      color: Colors.black,
      child: ClipRect(
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Fill the entire space without black bars
            Image.file(imageToDisplay, fit: BoxFit.cover),
            if (_detections != null && _imageSize != null)
              DetectionOverlay(
                detections: _detections!,
                imageSize: _imageSize!,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsCard() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDarkMode ? Colors.grey[850]! : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.grey[900]!;
    final subtextColor = isDarkMode ? Colors.grey[400]! : Colors.grey[600]!;

    // Get the single best detection
    final detection = _detections!.first;
    final confidencePercent = (detection.confidence * 100).toStringAsFixed(1);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green[700],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.check_circle_outline,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Detected Species',
                        style: TextStyle(
                          fontSize: 12,
                          color: subtextColor,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        detection.label,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // ⭐ I-update ang confidence indicator with color coding
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: _getConfidenceColor(detection.confidence),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        _getConfidenceIcon(detection.confidence),
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Confidence',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '$confidencePercent%',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // View Details Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // Debug: Print what label we're sending
                  debugPrint('🔍 Navigating with label: "${detection.label}"');
                  debugPrint('🔍 Label length: ${detection.label.length}');
                  debugPrint('🔍 Label bytes: ${detection.label.codeUnits}');

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SpeciesInfoPage(
                        scientificName: detection.label,
                        confidence: detection.confidence,
                        imagePath: _selectedImage?.path,
                        llmInsightHtml:
                            detection.llmInsightHtml, // Pass LLM insight
                        latitude: _currentLatitude, // Pass scan location
                        longitude: _currentLongitude, // Pass scan location
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.info_outline, size: 20),
                label: const Text(
                  'View Detailed Information',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: Colors.green[700],
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ⭐ Helper method para sa confidence color
  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.75) return Colors.green[700]!;
    if (confidence >= 0.55) return Colors.orange[700]!;
    return Colors.red[700]!;
  }

  // ⭐ Helper method para sa confidence icon
  IconData _getConfidenceIcon(double confidence) {
    if (confidence >= 0.75) return Icons.verified;
    if (confidence >= 0.55) return Icons.warning_amber_rounded;
    return Icons.error_outline;
  }

  Widget _buildNonMangroveCard() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDarkMode ? Colors.grey[850]! : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.grey[900]!;
    final subtextColor = isDarkMode ? Colors.grey[400]! : Colors.grey[600]!;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange[700],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.info_outline,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Inference Result',
                        style: TextStyle(
                          fontSize: 12,
                          color: subtextColor,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Not a mangrove',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'No class matched the model output. Try another angle or take a clearer photo.',
              style: TextStyle(fontSize: 14, color: subtextColor, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProcessingIcon({double iconSize = 64}) {
    // Gamit og spinner nga klaro kaayo nga nag-process
    return SizedBox(
      width: iconSize,
      height: iconSize,
      child: CircularProgressIndicator(
        strokeWidth: 6,
        valueColor: const AlwaysStoppedAnimation<Color>(Colors.black),
        // ignore: deprecated_member_use
        backgroundColor: Colors.white.withOpacity(0.4),
      ),
    );
  }

  Widget _buildProcessingStatus() {
    // Pakita og klarong status text samtang nag-scan
    const Color accent = Colors.black;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildProcessingIcon(),
        const SizedBox(height: 12),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.travel_explore_rounded, color: accent, size: 20),
            const SizedBox(width: 6),
            Text(
              'Searching mangroves...',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: accent,
                letterSpacing: 0.4,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                'Please wait while analyzing the image.',
                // ignore: deprecated_member_use
                style: TextStyle(fontSize: 13, color: accent.withOpacity(0.8)),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final containerColor = isDarkMode ? Colors.grey[850]! : Colors.white;

    // Determine which button should be highlighted
    final bool isGallerySelected = _lastSelectedSource == 'gallery';
    final bool isCameraSelected = _lastSelectedSource == 'camera';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: containerColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _pickImageFromGallery,
              icon: const Icon(Icons.photo_library_rounded, size: 24),
              label: const Text(
                'Gallery',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: isGallerySelected
                    ? Colors.green[700]
                    : (isDarkMode ? Colors.grey[800] : Colors.white),
                foregroundColor: isGallerySelected
                    ? Colors.white
                    : Colors.green[700],
                elevation: isGallerySelected ? 4 : 0,
                // ignore: deprecated_member_use
                shadowColor: isGallerySelected
                    // ignore: deprecated_member_use
                    ? Colors.green[700]!.withOpacity(0.5)
                    : null,
                side: isGallerySelected
                    ? null
                    : BorderSide(color: Colors.green[700]!, width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _takePhoto,
              icon: const Icon(Icons.camera_alt_rounded, size: 24),
              label: const Text(
                'Camera',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: isCameraSelected
                    ? Colors.green[700]
                    : (isDarkMode ? Colors.grey[800] : Colors.white),
                foregroundColor: isCameraSelected
                    ? Colors.white
                    : Colors.green[700],
                elevation: isCameraSelected ? 4 : 0,
                // ignore: deprecated_member_use
                shadowColor: isCameraSelected
                    // ignore: deprecated_member_use
                    ? Colors.green[700]!.withOpacity(0.5)
                    : null,
                side: isCameraSelected
                    ? null
                    : BorderSide(color: Colors.green[700]!, width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
