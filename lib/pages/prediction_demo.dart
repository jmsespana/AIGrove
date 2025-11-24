import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../models/detection_result.dart';
import '../services/ml_service.dart';
import '../services/prediction_service.dart';

class PredictionDemoPage extends StatefulWidget {
  const PredictionDemoPage({super.key});

  @override
  State<PredictionDemoPage> createState() => _PredictionDemoPageState();
}

class _PredictionDemoPageState extends State<PredictionDemoPage> {
  final MLService _mlService = MLService();
  Uint8List? _imageBytes;
  File? _imageFile;
  DetectionResult? _localDetection;
  MangroveAssessment? _assistant;
  bool _loading = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? file = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );
    if (file == null) return;
    final bytes = await file.readAsBytes();
    if (!mounted) return;
    setState(() {
      _imageBytes = bytes;
      _imageFile = File(file.path);
      _localDetection = null;
      _assistant = null;
    });
  }

  Future<void> _runPrediction() async {
    if (_imageBytes == null) return;
    setState(() => _loading = true);
    try {
      final predictionService = Provider.of<PredictionService>(
        context,
        listen: false,
      );
      final MangroveAssessment assessment = await predictionService
          .assessMangrove(_imageBytes!);

      DetectionResult? detection;
      if (assessment.assistantUnavailable ||
          assessment.allowLocalFallback ||
          assessment.isMangrove) {
        final file = _imageFile;
        if (file != null && await file.exists()) {
          await _mlService.loadModel();
          final List<DetectionResult> detections = await _mlService
              .detectObjects(file);
          if (detections.isNotEmpty) {
            detection = detections.reduce(
              (a, b) => a.confidence > b.confidence ? a : b,
            );
          }
        }
      }

      if (!mounted) return;
      setState(() {
        _assistant = assessment;
        _localDetection = detection;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _mlService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Prediction demo')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Center(
                child: _imageBytes == null
                    ? const Text('No image selected')
                    : Image.memory(_imageBytes!),
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.camera_alt),
              label: const Text('Pick image (camera)'),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: (_imageBytes != null && !_loading)
                  ? _runPrediction
                  : null,
              icon: _loading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.play_arrow),
              label: const Text('Run prediction & verify'),
            ),
            const SizedBox(height: 8),
            if (_localDetection != null)
              Text(
                'Local prediction: ${_localDetection!.label} (${(_localDetection!.confidence * 100).toStringAsFixed(1)}%)',
              ),
            if (_assistant != null) ...[
              const SizedBox(height: 6),
              Text(
                'Assistant check: ${_assistant!.isMangrove ? 'Mangrove' : 'Not a mangrove'}',
              ),
              if (_assistant!.message != null)
                Text('Assistant message: ${_assistant!.message}'),
              if (_assistant!.confidence != null)
                Text(
                  'Assistant confidence: ${(_assistant!.confidence! * 100).toStringAsFixed(1)}%',
                ),
              if (_assistant!.rawAssistantContent.isNotEmpty)
                Text('Raw: ${_assistant!.rawAssistantContent}'),
            ],
          ],
        ),
      ),
    );
  }
}