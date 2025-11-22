import 'dart:io';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import '../models/detection_result.dart';

/// Service para handle ang YOLOv8 model operations
///
/// Kini ang nag-manage sa model loading ug inference
class MLService {
  Interpreter? _interpreter;
  List<String>? _labels;
  int? _inputSize;

  // Classification thresholds - RELAXED FOR DEMO
  static const double confidenceThreshold = 0.55; // Minimum 55% confidence

  /// Load ang TFLite model - UPDATED PARA SA last_float32.tflite
  Future<void> loadModel() async {
    try {
      // Load ang bag-ong model: last_float32.tflite
      _interpreter = await Interpreter.fromAsset(
        'assets/models/last_float32.tflite',
      );

      // Get input size from model
      final inputShape = _interpreter!.getInputTensor(0).shape;
      _inputSize = inputShape[1];
      print('🔍 Model input: ${_inputSize}x${_inputSize}');

      // Load ang labels kung naa
      _labels = await _loadLabels();

      print('✅ Model ready: ${_labels?.length} classes');
    } catch (e) {
      rethrow;
    }
  }

  /// Load ang class labels
  Future<List<String>> _loadLabels() async {
    try {
      final labelData = await rootBundle.loadString('assets/models/labels.txt');
      return labelData.split('\n').where((label) => label.isNotEmpty).toList();
    } catch (e) {
      return ['mangrove']; // Default label
    }
  }

  /// Run classification sa image
  Future<List<DetectionResult>> detectObjects(File imageFile) async {
    if (_interpreter == null || _inputSize == null) {
      throw Exception('Model wala pa na-load. Tawag una ang loadModel()');
    }

    try {
      // 1. Load ug preprocess ang image
      final image = img.decodeImage(await imageFile.readAsBytes());
      if (image == null) throw Exception('Cannot decode image');

      // PRE-CHECK: Validate kung naa green content (mangroves kay green!)
      final greenPercentage = _calculateGreenPercentage(image);
      final greenDensity = _calculateGreenDensity(image);
      final edgeDensity = _calculateEdgeDensity(image);
      final skinTonePercentage = _calculateSkinTonePercentage(image);

      print(
        '🌿 Green: ${(greenPercentage * 100).toStringAsFixed(1)}%, Density: ${(greenDensity * 100).toStringAsFixed(1)}%',
      );
      print('🔍 Edge density: ${(edgeDensity * 100).toStringAsFixed(1)}%');
      print('👤 Skin tone: ${(skinTonePercentage * 100).toStringAsFixed(1)}%');

      // Check for obvious non-plant images
      // Kun daghan skin tone, human/animal ni, dili mangrove
      if (skinTonePercentage > 0.15) {
        print(
          '❌ High skin tone detected (${(skinTonePercentage * 100).toStringAsFixed(1)}%) - Not a plant!',
        );
        return [];
      }

      // Check if may green content
      if (greenPercentage < 0.10) {
        print(
          '❌ Insufficient green (${(greenPercentage * 100).toStringAsFixed(1)}%) - Not a plant!',
        );
        return [];
      }

      // Store metrics for later validation
      final imageMetrics = {
        'green': greenPercentage,
        'density': greenDensity,
        'edges': edgeDensity,
      };

      final inputImage = _preprocessImage(image);

      // 2. Prepare input tensor
      var input = inputImage.reshape([1, _inputSize!, _inputSize!, 3]);

      // 3. Get output shape from model
      final outputShape = _interpreter!.getOutputTensor(0).shape;
      var outputSize = outputShape.reduce((a, b) => a * b);
      var output = List.filled(outputSize, 0.0).reshape(outputShape);

      // 4. Run inference
      _interpreter!.run(input, output);

      // 5. Process results based on output shape
      // Check if detection model [1, 19, 8400] or classification [1, 15]
      final detections = outputShape.length == 3 && outputShape[1] == 19
          ? _processYOLOv8Output(output, _inputSize!, _inputSize!)
          : _processClassificationOutput(
              output,
              image.width,
              image.height,
              imageMetrics,
            );

      return detections;
    } catch (e) {
      rethrow;
    }
  }

  /// Preprocess image para sa model input
  List<List<List<List<double>>>> _preprocessImage(img.Image image) {
    // Resize to model input size
    final resized = img.copyResize(
      image,
      width: _inputSize!,
      height: _inputSize!,
    );

    // Create 4D tensor [1, height, width, channels]
    var inputImage = List.generate(
      1,
      (_) => List.generate(
        _inputSize!,
        (y) => List.generate(_inputSize!, (x) {
          final pixel = resized.getPixel(x, y);
          return [pixel.r / 255.0, pixel.g / 255.0, pixel.b / 255.0];
        }),
      ),
    );

    return inputImage;
  }

  /// Process classification output - [1, 15] class probabilities
  List<DetectionResult> _processClassificationOutput(
    List<dynamic> output,
    int imageWidth,
    int imageHeight,
    Map<String, double> metrics,
  ) {
    List<DetectionResult> detections = [];

    // Classification output: [1, 15]
    final classProbabilities = output[0] as List<double>;

    // Find best prediction
    double maxConfidence = 0.0;
    int bestClassId = 0;

    for (int i = 0; i < classProbabilities.length; i++) {
      if (classProbabilities[i] > maxConfidence) {
        maxConfidence = classProbabilities[i];
        bestClassId = i;
      }
    }

    print(
      '✅ Best: Class $bestClassId, Confidence: ${(maxConfidence * 100).toStringAsFixed(1)}%',
    );

    // SMART VALIDATION: Apply to ALL predictions above confidence threshold
    // Gi-apply ni sa tanan predictions para dili mu-lusot ang fake detections
    if (maxConfidence > confidenceThreshold) {
      final greenDensity = metrics['density']!;
      final edgeDensity = metrics['edges']!;

      // Check if prediction has good leaf characteristics
      // Kung kulang og green density or sobra ka-smooth/chaotic ang edges, reject
      if (greenDensity < 0.15 || edgeDensity > 0.40 || edgeDensity < 0.03) {
        print(
          '⚠️ ML detected mangrove BUT poor leaf metrics - likely NOT mangrove!',
        );
        print(
          '   Density: ${(greenDensity * 100).toStringAsFixed(1)}%, Edges: ${(edgeDensity * 100).toStringAsFixed(1)}%',
        );
        return detections; // Return empty
      }
    }

    if (maxConfidence > confidenceThreshold) {
      final label = _labels != null && bestClassId < _labels!.length
          ? _labels![bestClassId]
          : 'Class $bestClassId';

      // Whole image classification
      detections.add(
        DetectionResult(
          label: label,
          confidence: maxConfidence,
          boundingBox: Rect.fromLTRB(
            0,
            0,
            imageWidth.toDouble(),
            imageHeight.toDouble(),
          ),
        ),
      );
    } else {
      print('⚠️ Low confidence: ${(maxConfidence * 100).toStringAsFixed(1)}%');
    }

    return detections;
  }

  /// Dispose ang interpreter
  void dispose() {
    _interpreter?.close();
    _interpreter = null;
  }

  /// Check kung naa green content ang image (mangroves kay green!)
  double _calculateGreenPercentage(img.Image image) {
    int greenPixels = 0;
    int totalPixels = image.width * image.height;

    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        final pixel = image.getPixel(x, y);
        final r = pixel.r.toInt();
        final g = pixel.g.toInt();
        final b = pixel.b.toInt();

        // Check kung green dominant: G > R ug G > B
        // Plus minimum green value para dili mka-detect og gray/dark
        if (g > r && g > b && g > 40) {
          greenPixels++;
        }
      }
    }

    return greenPixels / totalPixels;
  }

  /// Check kung strong/vibrant ang green (mangrove leaves kay bright green!)
  double _calculateGreenDensity(img.Image image) {
    int strongGreenPixels = 0;
    int totalPixels = image.width * image.height;

    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        final pixel = image.getPixel(x, y);
        final r = pixel.r.toInt();
        final g = pixel.g.toInt();
        final b = pixel.b.toInt();

        // Strong green: G >> R AND G >> B, AND green is vibrant (>80)
        // This filters out dull/dark greens from backgrounds
        if (g > r + 20 && g > b + 20 && g > 80) {
          strongGreenPixels++;
        }
      }
    }

    return strongGreenPixels / totalPixels;
  }

  /// Calculate edge density para detect leaf veins ug texture
  double _calculateEdgeDensity(img.Image image) {
    int edgePixels = 0;
    int totalPixels = (image.width - 1) * (image.height - 1);

    // Simple edge detection using pixel differences
    for (int y = 0; y < image.height - 1; y++) {
      for (int x = 0; x < image.width - 1; x++) {
        final current = image.getPixel(x, y);
        final right = image.getPixel(x + 1, y);
        final below = image.getPixel(x, y + 1);

        // Calculate intensity difference
        final currentGray = (current.r + current.g + current.b) / 3;
        final rightGray = (right.r + right.g + right.b) / 3;
        final belowGray = (below.r + below.g + below.b) / 3;

        final diffRight = (currentGray - rightGray).abs();
        final diffBelow = (currentGray - belowGray).abs();

        // If significant difference, it's an edge
        if (diffRight > 30 || diffBelow > 30) {
          edgePixels++;
        }
      }
    }

    return edgePixels / totalPixels;
  }

  /// Detect skin tones para ma-reject ang humans/animals
  /// Skin tone detection based on RGB ranges common to human skin
  double _calculateSkinTonePercentage(img.Image image) {
    int skinPixels = 0;
    int totalPixels = image.width * image.height;

    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        final pixel = image.getPixel(x, y);
        final r = pixel.r.toInt();
        final g = pixel.g.toInt();
        final b = pixel.b.toInt();

        // Skin tone ranges (covers light to dark skin)
        // R > G > B pattern with specific ratios
        // Reference: Common skin tone detection in computer vision
        if (r > 95 &&
            g > 40 &&
            b > 20 &&
            r > g &&
            g > b &&
            (r - g) > 15 &&
            (r - b) > 15 &&
            r < 250 &&
            g < 200 &&
            b < 170) {
          skinPixels++;
        }
      }
    }

    return skinPixels / totalPixels;
  }

  /// Process ang YOLOv8 output to detection results
  List<DetectionResult> _processYOLOv8Output(
    List<dynamic> output,
    int imageWidth,
    int imageHeight,
  ) {
    List<DetectionResult> detections = [];

    // YOLOv8 output shape: [1, 19, 8400]
    // 19 = 4 (bbox: center_x, center_y, width, height) + 15 (class scores)
    final predictions = output[0] as List; // [19, 8400]
    final numDetections = predictions[0].length; // 8400

    // Debug: Print para makita nimo ang actual values
    print('🔍 Processing $numDetections detections');

    for (int i = 0; i < numDetections; i++) {
      // Get bounding box coordinates (normalized 0-640)
      final centerX = predictions[0][i] as double;
      final centerY = predictions[1][i] as double;
      final width = predictions[2][i] as double;
      final height = predictions[3][i] as double;

      // Get class scores (indices 4-18 para sa 15 classes)
      double maxClassScore = 0.0;
      int classId = 0;

      for (int c = 0; c < 15; c++) {
        final classScore = predictions[4 + c][i] as double;
        if (classScore > maxClassScore) {
          maxClassScore = classScore;
          classId = c;
        }
      }

      // Use class score as confidence
      final confidence = maxClassScore;

      if (confidence > confidenceThreshold) {
        // 🔧 FIX: YOLOv8 outputs are already in pixel coordinates (0-640)
        // We need to scale them to match the ORIGINAL image size (before preprocessing)
        // Pero since you're using 640x640 processed images, scale to that size

        // Convert center coordinates to corner coordinates
        final left = (centerX - width / 2).clamp(0.0, _inputSize!.toDouble());
        final top = (centerY - height / 2).clamp(0.0, _inputSize!.toDouble());
        final right = (centerX + width / 2).clamp(0.0, _inputSize!.toDouble());
        final bottom = (centerY + height / 2).clamp(
          0.0,
          _inputSize!.toDouble(),
        );

        // Get label
        final label = _labels != null && classId < _labels!.length
            ? _labels![classId]
            : 'Unknown';

        // Debug: Print detection info
        print(
          '✅ Detection $i: $label (${(confidence * 100).toStringAsFixed(1)}%)',
        );
        print('   Box: [$left, $top, $right, $bottom]');

        detections.add(
          DetectionResult(
            label: label,
            confidence: confidence,
            boundingBox: Rect.fromLTRB(left, top, right, bottom),
          ),
        );
      }
    }

    print('📦 Total valid detections: ${detections.length}');

    // Apply non-maximum suppression
    return _nonMaxSuppression(detections);
  }

  /// Non-Maximum Suppression para remove overlapping detections
  List<DetectionResult> _nonMaxSuppression(
    List<DetectionResult> detections, {
    double iouThreshold = 0.5,
  }) {
    if (detections.isEmpty) return [];

    // Sort by confidence (descending)
    detections.sort((a, b) => b.confidence.compareTo(a.confidence));

    List<DetectionResult> keep = [];

    while (detections.isNotEmpty) {
      // Keep ang highest confidence detection
      final best = detections.removeAt(0);
      keep.add(best);

      // Remove overlapping detections
      detections.removeWhere((detection) {
        final iou = _calculateIoU(best.boundingBox, detection.boundingBox);
        return iou > iouThreshold;
      });
    }

    return keep;
  }

  /// Calculate Intersection over Union (IoU) between two boxes
  double _calculateIoU(Rect box1, Rect box2) {
    // Calculate intersection area
    final x1 = box1.left > box2.left ? box1.left : box2.left;
    final y1 = box1.top > box2.top ? box1.top : box2.top;
    final x2 = box1.right < box2.right ? box1.right : box2.right;
    final y2 = box1.bottom < box2.bottom ? box1.bottom : box2.bottom;

    if (x2 < x1 || y2 < y1) return 0.0;

    final intersectionArea = (x2 - x1) * (y2 - y1);

    // Calculate union area
    final box1Area = box1.width * box1.height;
    final box2Area = box2.width * box2.height;
    final unionArea = box1Area + box2Area - intersectionArea;

    return intersectionArea / unionArea;
  }
}
