import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

/// Gikan sa assistant kung ni-uyon ba nga mangrove ang hulagway.
class MangroveAssessment {
  final bool isMangrove;
  final double? confidence;
  final String? message;
  final String rawAssistantContent;
  final dynamic reasoningDetails;
  final bool
  allowLocalFallback; // Pasignalan kung pwede ra ta mo-default sa local model

  const MangroveAssessment({
    required this.isMangrove,
    this.confidence,
    this.message,
    required this.rawAssistantContent,
    this.reasoningDetails,
    this.allowLocalFallback = false,
  });

  bool get assistantUnavailable =>
      rawAssistantContent.startsWith('assistant_unavailable');
}

/// Gamay nga helper service nga mo-konsulta lang sa Imagga image tagging API
/// aron makakuha ug paspas nga validation kung posibleng mangrove ba ang hulagway.
class PredictionService {
  final String imaggaApiKey;
  final String imaggaApiSecret;

  PredictionService({
    required this.imaggaApiKey,
    required this.imaggaApiSecret,
  });

  /// Public method nga gamiton sa UI aron i-validate ang hulagway sa Imagga.
  Future<MangroveAssessment> assessMangrove(Uint8List imageData) async {
    return _safeAssessMangrove(imageData);
  }

  Future<MangroveAssessment> _safeAssessMangrove(Uint8List imageData) async {
    if (imaggaApiKey.trim().isEmpty || imaggaApiSecret.trim().isEmpty) {
      return const MangroveAssessment(
        isMangrove: true,
        confidence: null,
        message: 'Assistant unavailable, defaulting to local model.',
        rawAssistantContent: 'assistant_unavailable: missing_api_credentials',
        reasoningDetails: null,
      );
    }

    try {
      return await _checkMangroveWithImagga(imageData);
    } catch (e, stack) {
      developer.log(
        '[PredictionService] Mangrove check failed: $e',
        name: 'PredictionService',
        error: e,
        stackTrace: stack,
      );
      return MangroveAssessment(
        isMangrove: true,
        confidence: null,
        message: 'Assistant check failed, defaulting to local model.',
        rawAssistantContent:
            'assistant_unavailable: exception_${e.runtimeType}',
        reasoningDetails: null,
      );
    }
  }

  Future<MangroveAssessment> _checkMangroveWithImagga(
    Uint8List imageData,
  ) async {
    final String authHeader = _buildBasicAuthHeader();

    final http.MultipartRequest uploadRequest =
        http.MultipartRequest(
            'POST',
            Uri.parse('https://api.imagga.com/v2/uploads'),
          )
          ..headers['Authorization'] = authHeader
          ..files.add(
            http.MultipartFile.fromBytes(
              'image',
              imageData,
              filename: 'scan.jpg',
            ),
          );

    http.StreamedResponse uploadStream;
    try {
      uploadStream = await uploadRequest.send().timeout(
        const Duration(seconds: 12),
      );
    } on SocketException catch (e) {
      developer.log(
        '[PredictionService] Imagga upload socket error: $e',
        name: 'PredictionService',
      );
      return const MangroveAssessment(
        isMangrove: true,
        confidence: null,
        message: 'Assistant unavailable (socket), defaulting to local model.',
        rawAssistantContent: 'assistant_unavailable: socket_exception_upload',
        reasoningDetails: null,
      );
    } on TimeoutException catch (e) {
      developer.log(
        '[PredictionService] Imagga upload timeout: $e',
        name: 'PredictionService',
      );
      return const MangroveAssessment(
        isMangrove: true,
        confidence: null,
        message: 'Assistant timeout, defaulting to local model.',
        rawAssistantContent: 'assistant_unavailable: timeout_upload',
        reasoningDetails: null,
      );
    } catch (e, stack) {
      developer.log(
        '[PredictionService] Imagga upload failed: $e',
        name: 'PredictionService',
        error: e,
        stackTrace: stack,
      );
      return MangroveAssessment(
        isMangrove: true,
        confidence: null,
        message: 'Assistant upload failed, defaulting to local model.',
        rawAssistantContent:
            'assistant_unavailable: upload_exception_${e.runtimeType}',
        reasoningDetails: null,
      );
    }

    final http.Response uploadResponse = await http.Response.fromStream(
      uploadStream,
    );

    if (uploadResponse.statusCode != 200) {
      developer.log(
        '[PredictionService] Imagga upload HTTP ${uploadResponse.statusCode}: ${uploadResponse.body}',
        name: 'PredictionService',
      );
      final bool unauthorized =
          uploadResponse.statusCode == 401 || uploadResponse.statusCode == 403;
      final String message = unauthorized
          ? 'Assistant unauthorized (Imagga HTTP ${uploadResponse.statusCode}). Please double-check your Imagga credentials.'
          : 'Assistant upload HTTP ${uploadResponse.statusCode}, defaulting to local model.';
      return MangroveAssessment(
        isMangrove: true,
        confidence: null,
        message: message,
        rawAssistantContent:
            'assistant_unavailable: upload_http_${uploadResponse.statusCode}',
        reasoningDetails: null,
      );
    }

    Map<String, dynamic> uploadJson;
    try {
      uploadJson = jsonDecode(uploadResponse.body) as Map<String, dynamic>;
    } catch (e) {
      developer.log(
        '[PredictionService] Imagga upload parse error: ${uploadResponse.body}',
        name: 'PredictionService',
      );
      return const MangroveAssessment(
        isMangrove: true,
        confidence: null,
        message: 'Assistant upload parse error, defaulting to local model.',
        rawAssistantContent: 'assistant_unavailable: upload_parse_error',
        reasoningDetails: null,
      );
    }

    final dynamic resultPayload = uploadJson['result'];
    final String? uploadId = resultPayload is Map<String, dynamic>
        ? resultPayload['upload_id'] as String?
        : null;
    if (uploadId == null || uploadId.isEmpty) {
      developer.log(
        '[PredictionService] Imagga upload missing upload_id: ${uploadResponse.body}',
        name: 'PredictionService',
      );
      return const MangroveAssessment(
        isMangrove: true,
        confidence: null,
        message: 'Assistant upload missing id, defaulting to local model.',
        rawAssistantContent: 'assistant_unavailable: missing_upload_id',
        reasoningDetails: null,
      );
    }

    http.Response tagsResponse;
    try {
      tagsResponse = await http
          .get(
            Uri.parse(
              'https://api.imagga.com/v2/tags?image_upload_id=$uploadId',
            ),
            headers: {'Authorization': authHeader},
          )
          .timeout(const Duration(seconds: 12));
    } on SocketException catch (e) {
      developer.log(
        '[PredictionService] Imagga tags socket error: $e',
        name: 'PredictionService',
      );
      return const MangroveAssessment(
        isMangrove: true,
        confidence: null,
        message: 'Assistant unavailable (socket), defaulting to local model.',
        rawAssistantContent: 'assistant_unavailable: socket_exception_tags',
        reasoningDetails: null,
      );
    } on TimeoutException catch (e) {
      developer.log(
        '[PredictionService] Imagga tags timeout: $e',
        name: 'PredictionService',
      );
      return const MangroveAssessment(
        isMangrove: true,
        confidence: null,
        message: 'Assistant timeout, defaulting to local model.',
        rawAssistantContent: 'assistant_unavailable: timeout_tags',
        reasoningDetails: null,
      );
    } catch (e, stack) {
      developer.log(
        '[PredictionService] Imagga tags request failed: $e',
        name: 'PredictionService',
        error: e,
        stackTrace: stack,
      );
      return MangroveAssessment(
        isMangrove: true,
        confidence: null,
        message: 'Assistant request failed, defaulting to local model.',
        rawAssistantContent:
            'assistant_unavailable: tags_exception_${e.runtimeType}',
        reasoningDetails: null,
      );
    }

    if (tagsResponse.statusCode != 200) {
      developer.log(
        '[PredictionService] Imagga tags HTTP ${tagsResponse.statusCode}: ${tagsResponse.body}',
        name: 'PredictionService',
      );
      final bool unauthorized =
          tagsResponse.statusCode == 401 || tagsResponse.statusCode == 403;
      final String message = unauthorized
          ? 'Assistant unauthorized (Imagga HTTP ${tagsResponse.statusCode}). Please double-check your Imagga credentials.'
          : 'Assistant HTTP ${tagsResponse.statusCode}, defaulting to local model.';
      return MangroveAssessment(
        isMangrove: true,
        confidence: null,
        message: message,
        rawAssistantContent:
            'assistant_unavailable: tags_http_${tagsResponse.statusCode}',
        reasoningDetails: null,
      );
    }

    Map<String, dynamic> tagsJson;
    try {
      tagsJson = jsonDecode(tagsResponse.body) as Map<String, dynamic>;
    } catch (e) {
      developer.log(
        '[PredictionService] Imagga tags parse error: ${tagsResponse.body}',
        name: 'PredictionService',
      );
      return const MangroveAssessment(
        isMangrove: true,
        confidence: null,
        message: 'Assistant tags parse error, defaulting to local model.',
        rawAssistantContent: 'assistant_unavailable: tags_parse_error',
        reasoningDetails: null,
      );
    }

    final dynamic tagsResult = tagsJson['result'];
    final List<dynamic> tags =
        tagsResult is Map<String, dynamic> && tagsResult['tags'] is List
        ? List<dynamic>.from(tagsResult['tags'] as List)
        : const [];

    if (tags.isEmpty) {
      developer.log(
        '[PredictionService] Imagga returned no tags for upload_id=$uploadId',
        name: 'PredictionService',
      );
      return const MangroveAssessment(
        isMangrove: true,
        confidence: null,
        message: 'Assistant returned no tags, defaulting to local model.',
        rawAssistantContent: 'assistant_unavailable: empty_tags',
        reasoningDetails: null,
      );
    }

    double bestTreeScore = -1;
    double? bestTreeConfidence;
    Map<String, dynamic>? treeEntry;

    double bestLeafScore = -1;
    double? bestLeafConfidence;
    Map<String, dynamic>? leafEntry;

    double bestFlowerScore = -1;
    double? bestFlowerConfidence;
    Map<String, dynamic>? flowerEntry;

    double bestFruitScore = -1;
    double? bestFruitConfidence;
    Map<String, dynamic>? fruitEntry;
    final List<Map<String, dynamic>> topTags = [];

    for (final dynamic entry in tags) {
      if (entry is! Map<String, dynamic>) continue;
      final dynamic tagData = entry['tag'];
      String? label;
      if (tagData is Map<String, dynamic>) {
        final dynamic en = tagData['en'];
        if (en is String) label = en;
      } else if (tagData is String) {
        label = tagData;
      }

      if (label == null || label.isEmpty) continue;
      final String lowerLabel = label.toLowerCase();

      final num? confidenceNum = entry['confidence'] is num
          ? entry['confidence'] as num
          : null;
      final double? confidence = confidenceNum?.toDouble();

      if (topTags.length < 5) {
        topTags.add({
          'label': label,
          'confidence': confidence != null ? confidence / 100.0 : null,
        });
      }

      if (lowerLabel.contains('tree')) {
        final double score = confidence ?? 0.0;
        if (score > bestTreeScore) {
          bestTreeScore = score;
          bestTreeConfidence = confidence;
          treeEntry = entry;
        }
      }

      if (lowerLabel.contains('leaf')) {
        final double score = confidence ?? 0.0;
        if (score > bestLeafScore) {
          bestLeafScore = score;
          bestLeafConfidence = confidence;
          leafEntry = entry;
        }
      }

      if (lowerLabel.contains('flower')) {
        final double score = confidence ?? 0.0;
        if (score > bestFlowerScore) {
          bestFlowerScore = score;
          bestFlowerConfidence = confidence;
          flowerEntry = entry;
        }
      }

      if (lowerLabel.contains('fruit')) {
        final double score = confidence ?? 0.0;
        if (score > bestFruitScore) {
          bestFruitScore = score;
          bestFruitConfidence = confidence;
          fruitEntry = entry;
        }
      }
    }

    final bool hasTree = treeEntry != null;
    final bool hasLeaf = leafEntry != null;
    final bool hasFlower = flowerEntry != null;
    final bool hasFruit = fruitEntry != null;

    if (!hasTree && !hasLeaf && !hasFlower && !hasFruit) {
      final String rawContent = jsonEncode({
        'source': 'imagga',
        'upload_id': uploadId,
        'isMangrove': false,
        'confidence': null,
        'topTags': topTags,
      });
      return MangroveAssessment(
        isMangrove: false,
        confidence: null,
        message:
            'No, this image does not contain a tree, leaf, flower, or fruit cue.',
        rawAssistantContent: rawContent,
        reasoningDetails: tags,
      );
    }

    double chosenConfidence;
    String detectionSource;
    if (hasTree) {
      chosenConfidence = bestTreeConfidence ?? bestTreeScore;
      detectionSource = 'tree';
    } else if (hasLeaf) {
      chosenConfidence = bestLeafConfidence ?? bestLeafScore;
      detectionSource = 'leaf';
    } else if (hasFlower) {
      chosenConfidence = bestFlowerConfidence ?? bestFlowerScore;
      detectionSource = 'flower';
    } else {
      chosenConfidence = bestFruitConfidence ?? bestFruitScore;
      detectionSource = 'fruit';
    }

    final double? normalizedConfidence = chosenConfidence >= 0
        ? chosenConfidence / 100.0
        : null;

    final Map<String, dynamic> payloadBase = {
      'source': 'imagga',
      'upload_id': uploadId,
      'confidence': normalizedConfidence,
      'detection_source': detectionSource,
      'treeTag': treeEntry,
      'leafTag': leafEntry,
      'flowerTag': flowerEntry,
      'fruitTag': fruitEntry,
      'topTags': topTags,
    };

    final Map<String, dynamic> reasoningBase = {
      'detection_source': detectionSource,
      'treeTag': treeEntry,
      'leafTag': leafEntry,
      'flowerTag': flowerEntry,
      'fruitTag': fruitEntry,
    };

    final String rawContent = jsonEncode({...payloadBase, 'isMangrove': true});

    return MangroveAssessment(
      isMangrove: true,
      confidence: normalizedConfidence,
      // Tagalog/Bisaya: Conditional message depende sa detection source
      message: detectionSource == 'flower'
          ? 'Yes, this image contains a flowering mangrove.'
          : detectionSource == 'fruit'
          ? 'Yes, this image contains a fruit-bearing mangrove.'
          : detectionSource == 'tree'
          ? 'Yes, this image contains a mangrove tree.'
          : detectionSource == 'leaf'
          ? 'Yes, this image contains a mangrove leaf.'
          : 'Yes, this image contains a mangrove.', // Default message kung wala sa mga above
      rawAssistantContent: rawContent,
      reasoningDetails: reasoningBase,
    );
  }

  String _buildBasicAuthHeader() {
    final String credentials = '$imaggaApiKey:$imaggaApiSecret';
    final String encoded = base64Encode(utf8.encode(credentials));
    return 'Basic $encoded';
  }
}