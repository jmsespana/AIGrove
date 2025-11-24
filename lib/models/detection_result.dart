import 'dart:ui';

/// Model para sa detection results
///
/// Kini ang data structure para sa tanang nakita sa YOLOv8
class DetectionResult {
  final String label; // Klase sa object (e.g., "mangrove")
  final double confidence; // Kasigurohan (0.0 to 1.0)
  final Rect? boundingBox; // Optional kung detection, null kung classification
  String?
  llmInsightHtml; // LLM-generated HTML insight (nullable, loaded asynchronously)

  DetectionResult({
    required this.label,
    required this.confidence,
    this.boundingBox,
    this.llmInsightHtml,
  });

  @override
  String toString() {
    final boxLabel = boundingBox != null ? '$boundingBox' : 'none';
    return 'DetectionResult(label: $label, confidence: ${(confidence * 100).toStringAsFixed(1)}%, box: $boxLabel)';
  }
}

/// Para sa image dimensions
class ImageDimensions {
  final int width;
  final int height;

  ImageDimensions(this.width, this.height);
}
