import 'package:flutter/material.dart';
import '../models/detection_result.dart';

/// Widget para display ang detection results with bounding boxes
/// 
/// Kini ang nagpakita sa boxes sa nakitang objects
class DetectionOverlay extends StatelessWidget {
  final List<DetectionResult> detections;
  final Size imageSize;
  
  const DetectionOverlay({
    super.key,
    required this.detections,
    required this.imageSize,
  });
  
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DetectionPainter(detections, imageSize),
      child: Container(),
    );
  }
}

class _DetectionPainter extends CustomPainter {
  final List<DetectionResult> detections;
  final Size imageSize;
  
  _DetectionPainter(this.detections, this.imageSize);
  
  @override
  void paint(Canvas canvas, Size size) {
    final scaleX = size.width / imageSize.width;
    final scaleY = size.height / imageSize.height;
    
    for (var detection in detections) {
      final box = Rect.fromLTRB(
        detection.boundingBox.left * scaleX,
        detection.boundingBox.top * scaleY,
        detection.boundingBox.right * scaleX,
        detection.boundingBox.bottom * scaleY,
      );
      
      // Draw outer shadow for depth
      final shadowPaint = Paint()
        // ignore: deprecated_member_use
        ..color = Colors.black.withOpacity(0.4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawRect(box.inflate(4), shadowPaint);
      
      // Draw bounding box with gradient effect
      final paint = Paint()
        ..color = Colors.green[400]!
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.0;
      
      canvas.drawRect(box, paint);
      
      // Draw corner accents for modern look
      final cornerPaint = Paint()
        ..color = Colors.green[300]!
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6.0
        ..strokeCap = StrokeCap.round;
      
      final cornerLength = 20.0;
      // Top-left corner
      canvas.drawLine(Offset(box.left, box.top), Offset(box.left + cornerLength, box.top), cornerPaint);
      canvas.drawLine(Offset(box.left, box.top), Offset(box.left, box.top + cornerLength), cornerPaint);
      
      // Top-right corner
      canvas.drawLine(Offset(box.right, box.top), Offset(box.right - cornerLength, box.top), cornerPaint);
      canvas.drawLine(Offset(box.right, box.top), Offset(box.right, box.top + cornerLength), cornerPaint);
      
      // Bottom-left corner
      canvas.drawLine(Offset(box.left, box.bottom), Offset(box.left + cornerLength, box.bottom), cornerPaint);
      canvas.drawLine(Offset(box.left, box.bottom), Offset(box.left, box.bottom - cornerLength), cornerPaint);
      
      // Bottom-right corner
      canvas.drawLine(Offset(box.right, box.bottom), Offset(box.right - cornerLength, box.bottom), cornerPaint);
      canvas.drawLine(Offset(box.right, box.bottom), Offset(box.right, box.bottom - cornerLength), cornerPaint);
      
      // Draw label with better styling
      final textSpan = TextSpan(
        text: '${detection.label}\n${(detection.confidence * 100).toStringAsFixed(1)}%',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
          height: 1.3,
        ),
      );
      
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      );
      textPainter.layout();
      
      // Draw label background with rounded corners
      final labelHeight = textPainter.height + 16;
      final labelWidth = textPainter.width + 24;
      final labelRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          box.left,
          box.top - labelHeight - 8,
          labelWidth,
          labelHeight,
        ),
        const Radius.circular(8),
      );
      
      // Label shadow
      final labelShadow = Paint()
        // ignore: deprecated_member_use
        ..color = Colors.black.withOpacity(0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawRRect(labelRect.inflate(2), labelShadow);
      
      // Label background
      final labelBg = Paint()..color = Colors.green[700]!;
      canvas.drawRRect(labelRect, labelBg);
      
      // Draw text
      textPainter.paint(
        canvas,
        Offset(box.left + 12, box.top - labelHeight - 8 + 8),
      );
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}