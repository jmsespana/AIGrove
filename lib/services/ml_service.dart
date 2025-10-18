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
  
  // YOLOv8 640x640 input size
  static const int inputSize = 640;
  static const double confidenceThreshold = 0.5; // Minimum confidence
  static const double iouThreshold = 0.5;        // Non-max suppression
  
  /// Load ang TFLite model - UPDATED PARA SA last_float32.tflite
  Future<void> loadModel() async {
    try {
      
      // Load ang bag-ong model: last_float32.tflite
      _interpreter = await Interpreter.fromAsset('assets/models/last_float32.tflite');
      
      // Load ang labels kung naa
      _labels = await _loadLabels();
      
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
  
  /// Run detection sa image
  Future<List<DetectionResult>> detectObjects(File imageFile) async {
    if (_interpreter == null) {
      throw Exception('Model wala pa na-load. Tawag una ang loadModel()');
    }
    
    try {
      // 1. Load ug preprocess ang image
      final image = img.decodeImage(await imageFile.readAsBytes());
      if (image == null) throw Exception('Cannot decode image');
      
      final inputImage = _preprocessImage(image);
      
      // 2. Prepare input tensor [1, 640, 640, 3]
      var input = inputImage.reshape([1, inputSize, inputSize, 3]);
      
      // 3. Prepare output tensor - YOLOv8 format for 15 classes
      // Output shape: [1, 19, 8400] -> 4 bbox + 15 class scores
      var output = List.filled(1 * 19 * 8400, 0.0).reshape([1, 19, 8400]);
      
      // 4. Run inference
      _interpreter!.run(input, output);
      
      // 5. Process results
      final detections = _processYOLOv8Output(
        output,
        image.width,
        image.height,
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
      width: inputSize,
      height: inputSize,
    );
    
    // Create 4D tensor [1, height, width, channels]
    var inputImage = List.generate(
      1,
      (_) => List.generate(
        inputSize,
        (y) => List.generate(
          inputSize,
          (x) {
            final pixel = resized.getPixel(x, y);
            return [
              pixel.r / 255.0,
              pixel.g / 255.0,
              pixel.b / 255.0,
            ];
          },
        ),
      ),
    );
    
    return inputImage;
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
    
    for (int i = 0; i < numDetections; i++) {
      // Get bounding box coordinates (YOLO format: center_x, center_y, width, height)
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
        // Convert from normalized coordinates to actual pixel coordinates
        // YOLO gives coordinates relative to input size (640x640)
        final left = (centerX - width / 2) * imageWidth / inputSize;
        final top = (centerY - height / 2) * imageHeight / inputSize;
        final right = (centerX + width / 2) * imageWidth / inputSize;
        final bottom = (centerY + height / 2) * imageHeight / inputSize;
        
        // Get label
        final label = _labels != null && classId < _labels!.length
            ? _labels![classId]
            : 'Unknown';
        
        detections.add(DetectionResult(
          label: label,
          confidence: confidence,
          boundingBox: Rect.fromLTRB(
            left.clamp(0, imageWidth.toDouble()),
            top.clamp(0, imageHeight.toDouble()),
            right.clamp(0, imageWidth.toDouble()),
            bottom.clamp(0, imageHeight.toDouble()),
          ),
        ));
      }
    }
    
    // Apply non-maximum suppression
    return _nonMaxSuppression(detections);
  }
  
  /// Non-maximum suppression para remove duplicate detections
  List<DetectionResult> _nonMaxSuppression(List<DetectionResult> detections) {
    // Sort by confidence
    detections.sort((a, b) => b.confidence.compareTo(a.confidence));
    
    List<DetectionResult> results = [];
    
    for (var detection in detections) {
      bool keep = true;
      
      for (var kept in results) {
        if (_calculateIoU(detection.boundingBox, kept.boundingBox) > iouThreshold) {
          keep = false;
          break;
        }
      }
      
      if (keep) results.add(detection);
    }
    
    return results;
  }
  
  /// Calculate Intersection over Union
  double _calculateIoU(Rect box1, Rect box2) {
    final intersection = box1.intersect(box2);
    if (intersection.width <= 0 || intersection.height <= 0) return 0.0;
    
    final intersectionArea = intersection.width * intersection.height;
    final union = box1.width * box1.height + box2.width * box2.height - intersectionArea;
    
    return intersectionArea / union;
  }
  
  /// Dispose ang interpreter
  void dispose() {
    _interpreter?.close();
    _interpreter = null;
  }
}