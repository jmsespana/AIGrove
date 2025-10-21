import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:provider/provider.dart';
import '../services/ml_service.dart';
import '../services/user_service.dart';
import '../services/location_service.dart'; // I-add ni
import '../models/detection_result.dart';
import '../widgets/detection_overlay.dart';
import '../theme/app_theme.dart';
import 'species_info_page.dart';

/// Scan Page with YOLOv8 Integration
///
/// Kini ang page para mag-scan ug detect og mangroves
class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  final MLService _mlService = MLService();
  final ImagePicker _picker = ImagePicker();
  final LocationService _locationService = LocationService(); // I-add ni

  File? _selectedImage;
  File? _processedImage; // Para sa fixed orientation ug resized image
  Size? _imageSize; // Store actual image dimensions
  List<DetectionResult>? _detections;
  bool _isLoading = false;
  String? _errorMessage;
  String?
  _lastSelectedSource; // Track which button was last pressed ('camera' or 'gallery')

  @override
  void initState() {
    super.initState();
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
      final userService = context.read<UserService>();

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

      // I-save ang scan sa database with location
      await userService.saveScan(
        speciesName: detection.label,
        imageUrl: _selectedImage?.path,
        latitude: latitude,
        longitude: longitude,
        notes: null,
      );

      debugPrint('✅ Scan saved to history: ${detection.label}');

      // I-show ang success message with location info
      if (mounted && latitude != null && longitude != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '✅ Scan saved with location: ${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
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
    });

    try {
      // Get ug fix ang image orientation, then resize to 640x640
      final processedFile = await _fixImageOrientation(imageFile);

      // Get ang processed image dimensions (dapat 640x640 na ni)
      final imageBytes = await processedFile.readAsBytes();
      final decodedImage = img.decodeImage(imageBytes);

      if (decodedImage != null) {
        _imageSize = Size(
          decodedImage.width.toDouble(),
          decodedImage.height.toDouble(),
        );
      }

      // Run detection sa processed image
      final detections = await _mlService.detectObjects(processedFile);

      // Get only the best detection (highest confidence)
      final bestDetection = detections.isNotEmpty
          ? [detections.reduce((a, b) => a.confidence > b.confidence ? a : b)]
          : <DetectionResult>[];

      setState(() {
        _processedImage = processedFile;
        _detections = bestDetection;
        _isLoading = false;
      });

      if (bestDetection.isEmpty) {
        _showError('No mangroves detected!');
      } else {
        // I-save ang successful detection sa history
        if (!mounted) return;
        await _saveScanToHistory(bestDetection.first);
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Detection failed: $e';
        _isLoading = false;
      });
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
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

              // Results area - Show loading card or results card
              if (_isLoading && _selectedImage != null)
                _buildLoadingResultsCard()
              else if (_detections != null && _detections!.isNotEmpty)
                _buildResultsCard(),

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
        color: bgColor,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.green[700], strokeWidth: 3),
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

    // Display ang processed image (640x640 square) kung available na
    final imageToDisplay = _processedImage ?? _selectedImage!;

    return Container(
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Fit contain para mo-maintain ang square aspect ratio
          Image.file(imageToDisplay, fit: BoxFit.contain),
          if (_detections != null && _imageSize != null)
            DetectionOverlay(detections: _detections!, imageSize: _imageSize!),
        ],
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
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.green[900] : Colors.green[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.verified, color: Colors.green[700], size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Confidence',
                        style: TextStyle(
                          fontSize: 14,
                          color: subtextColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '$confidencePercent%',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
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

  Widget _buildLoadingResultsCard() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDarkMode ? Colors.grey[850]! : Colors.white;
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
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green[700],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 3,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Analyzing...',
                        style: TextStyle(
                          fontSize: 12,
                          color: subtextColor,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Identifying species',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.green[900] : Colors.green[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      color: Colors.green[700],
                      strokeWidth: 2,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Processing image...',
                    style: TextStyle(
                      fontSize: 14,
                      color: subtextColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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
