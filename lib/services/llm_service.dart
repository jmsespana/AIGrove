import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Service para sa Llama AI integration via Groq API
/// Gamit ni ang llama-3.3-70b-versatile model
class LLMService {
  static const String _baseUrl = 'https://api.groq.com/openai/v1';
  // ⭐ Gamit ang Llama 3.3 70B model (available sa Groq)
  static const String defaultModel =
      'meta-llama/llama-4-scout-17b-16e-instruct';
  static const String fallbackModel =
      'meta-llama/llama-4-scout-17b-16e-instruct'; // Fallback kung dili available ang 70B

  // Cache settings para dili permi mag-call (24 hours)
  static const String _cacheKey = 'daily_eco_tip';
  static const String _cacheTimeKey = 'daily_eco_tip_time';
  static const Duration _cacheDuration = Duration(hours: 24);

  // Hardcoded API key
  final String _apiKey =
      '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';

  LLMService() {
    debugPrint('🔑 Groq API Key initialized: ${_apiKey.substring(0, 20)}...');
  }

  Future<String> getDailyEcoTip() async {
    // ⭐ Check cache una before mag-API call para makatipid
    final prefs = await SharedPreferences.getInstance();
    final cachedTip = prefs.getString(_cacheKey);
    final cachedTimeStr = prefs.getString(_cacheTimeKey);

    if (cachedTip != null && cachedTimeStr != null) {
      final cachedTime = DateTime.parse(cachedTimeStr);
      if (DateTime.now().difference(cachedTime) < _cacheDuration) {
        debugPrint('📦 Gigamit ang cached tip (dili na nag-API call)');
        return cachedTip;
      }
    }

    // ⭐ I-try ang API call with fallback model
    String? tip = await _callGroqAPI(defaultModel, _getEcoTipPrompt());

    if (tip == null) {
      debugPrint('⚠️ Nag-try sa fallback model...');
      tip = await _callGroqAPI(fallbackModel, _getEcoTipPrompt());
    }

    // Kung wala gihapon, gamiton ang default message
    if (tip == null) {
      debugPrint('⚠️ Gigamit ang default eco tip');
      return _getDefaultTip();
    }

    // ⭐ I-save sa cache ang na-generate na tip
    await prefs.setString(_cacheKey, tip);
    await prefs.setString(_cacheTimeKey, DateTime.now().toIso8601String());

    return tip;
  }

  /// Helper method para sa API call
  Future<String?> _callGroqAPI(String model, String prompt) async {
    try {
      debugPrint('🤖 Nag-call sa Llama API via Groq...');
      debugPrint('📊 Model: $model');

      final response = await http
          .post(
            Uri.parse('$_baseUrl/chat/completions'),
            headers: {
              'Authorization': 'Bearer $_apiKey',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'model': model,
              'messages': [
                {'role': 'user', 'content': prompt},
              ],
              'temperature': 0.9,
              'max_tokens': 150,
            }),
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw Exception('Request timeout');
            },
          );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'] as String;

        debugPrint('✅ Llama response received!');
        return content.trim();
      } else {
        debugPrint('❌ API Error: ${response.statusCode}');
        debugPrint('Response body: ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('❌ Error sa _callGroqAPI: $e');
      return null;
    }
  }

  String _getEcoTipPrompt() {
    return '''Generate ONE actionable eco-friendly tip for today related to mangrove conservation in Caraga Region, Philippines.

Requirements:
- Keep it short (2-3 sentences)
- Make it practical and achievable
- Relate it to Philippine context
- Make it inspiring
- Include a relevant emoji at the start

Example: 🌊 Did you know? Mangroves prevent coastal erosion by stabilizing shorelines. Visit a local mangrove area this weekend!''';
  }

  /// Default fallback tips kung mag-fail ang API
  String _getDefaultTip() {
    final tips = [
      '🌱 Mangroves absorb 5x more carbon than rainforests! Plant a seedling today and help fight climate change.',
      '🌊 Mangroves protect our coastlines from storms and erosion. Support local conservation efforts in Caraga Region!',
      '🐟 Mangrove forests are nurseries for fish. By protecting them, you help local fishing communities thrive.',
      '♻️ Reduce plastic use near coastal areas. Plastics harm mangrove ecosystems and marine life.',
      '🌿 Join a mangrove planting activity in your community. One tree can make a difference!',
      '🦀 Mangroves are home to crabs, birds, and other wildlife. Preserve their habitat by avoiding illegal logging.',
    ];

    final random = DateTime.now().millisecondsSinceEpoch % tips.length;
    return tips[random];
  }

  /// Generate response para sa chatbot conversations
  Future<String?> generateResponse({
    required List<Map<String, String>> messages,
    required double temperature,
    required int maxTokens,
  }) async {
    try {
      debugPrint('🤖 Nag-generate ug chatbot response...');
      debugPrint('📊 Model: $defaultModel');
      debugPrint('💬 Messages count: ${messages.length}');

      final formattedMessages = [
        {
          'role': 'system',
          'content':
              'You are an AI assistant specialized in mangrove conservation and environmental education in the Caraga Region, Philippines. Always respond in English only. Be helpful, informative, and encouraging.',
        },
        ...messages.map((msg) {
          return {'role': msg['role'], 'content': msg['content']};
        }).toList(),
      ];

      debugPrint('📤 Padala na sa API...');

      final response = await http
          .post(
            Uri.parse('$_baseUrl/chat/completions'),
            headers: {
              'Authorization': 'Bearer $_apiKey',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'model': defaultModel,
              'messages': formattedMessages,
              'temperature': temperature,
              'max_tokens': maxTokens,
            }),
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              debugPrint('⏱️ Request timeout after 30 seconds');
              throw Exception('Request timeout');
            },
          );

      debugPrint('📥 Response received! Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['choices'] == null || data['choices'].isEmpty) {
          debugPrint('❌ Invalid response structure: ${response.body}');
          return await _generateWithFallback(
            formattedMessages,
            temperature,
            maxTokens,
          );
        }

        final content = data['choices'][0]['message']['content'] as String;
        debugPrint('✅ Chatbot response received! Length: ${content.length}');
        return content.trim();
      } else {
        debugPrint('❌ API Error: ${response.statusCode}');
        debugPrint('📄 Response body: ${response.body}');

        return await _generateWithFallback(
          formattedMessages,
          temperature,
          maxTokens,
        );
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Error sa generateResponse: $e');
      debugPrint('📚 Stack trace: $stackTrace');

      try {
        final formattedMessages = messages
            .map((msg) => {'role': msg['role'], 'content': msg['content']})
            .toList();

        return await _generateWithFallback(
          formattedMessages,
          temperature,
          maxTokens,
        );
      } catch (fallbackError) {
        debugPrint('❌ Fallback failed pud: $fallbackError');
        return null;
      }
    }
  }

  /// Generate species insight with HTML formatting
  /// Para sa detection results sa scan page
  Future<String> getSpeciesInsight({
    required String speciesName,
    required double confidence,
  }) async {
    try {
      debugPrint('🌿 Getting species insight for: $speciesName');

      final prompt =
          '''
You are an expert marine biologist specializing in mangrove ecosystems in the Philippines, particularly in the Caraga Region.

A mangrove species has been detected: "$speciesName" with ${(confidence * 100).toStringAsFixed(1)}% confidence.

Provide a comprehensive, informative response in HTML format with the following sections:

1. **Species Identification**
   - Scientific name (in italics)
   - Common English name
   - Local Filipino/Bisaya name (if known)

2. **Physical Characteristics**
   - Distinctive features (leaves, bark, roots, flowers, fruits)
   - Average height and size
   - Unique identifying marks

3. **Ecological Role**
   - Habitat preferences (tidal zones, substrate type)
   - Ecological importance (coastal protection, carbon storage, nursery habitat)
   - Associated wildlife

4. **Distribution in Caraga Region**
   - Specific locations in Caraga (Agusan del Norte, Agusan del Sur, Surigao del Norte, Surigao del Sur, Dinagat Islands)
   - Common coastal areas where found
   - Abundance status in the region

5. **Conservation & Uses**
   - Conservation status
   - Traditional/economic uses
   - Threats and protection efforts

Use proper HTML formatting:
- <h3 style="color: #2E7D32; margin-bottom: 8px;"> for main headings
- <h4 style="color: #388E3C; margin-top: 12px; margin-bottom: 6px;"> for subheadings
- <p style="margin: 4px 0; line-height: 1.5;"> for paragraphs
- <ul style="margin-left: 20px; margin-bottom: 8px;"> and <li style="margin-bottom: 4px;"> for lists
- <strong> for emphasis
- <em> for scientific names

Be specific to Philippine context and Caraga Region. Keep total response under 400 words but make it comprehensive and educational.
''';

      final response = await http
          .post(
            Uri.parse('$_baseUrl/chat/completions'),
            headers: {
              'Authorization': 'Bearer $_apiKey',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'model': defaultModel,
              'messages': [
                {
                  'role': 'system',
                  'content':
                      'You are a marine biology expert specializing in Philippine mangrove ecosystems. Provide accurate, detailed, and well-structured information. Always respond in well-formatted HTML with proper styling.',
                },
                {'role': 'user', 'content': prompt},
              ],
              'temperature': 0.7,
              'max_tokens': 1200,
            }),
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'] as String;
        debugPrint('✅ Species insight generated!');
        return content;
      } else {
        throw Exception('API Error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Error getting species insight: $e');
      return _getFallbackSpeciesInsight(speciesName, confidence);
    }
  }

  /// Fallback HTML kung mag-fail ang API
  String _getFallbackSpeciesInsight(String speciesName, double confidence) {
    return '''
<div style="padding: 12px;">
  <h3 style="color: #2E7D32; margin: 0 0 12px 0;">$speciesName</h3>
  
  <p style="margin: 8px 0;"><strong>Detection Confidence:</strong> ${(confidence * 100).toStringAsFixed(1)}%</p>
  
  <h4 style="color: #388E3C; margin-top: 12px; margin-bottom: 6px;">About This Species</h4>
  <p style="margin: 4px 0; line-height: 1.5; color: #666;">
    This mangrove species is found in the coastal ecosystems of the Philippines, particularly in the Caraga Region. 
    Mangroves play a vital role in protecting our coastlines from erosion and storm surges while supporting marine biodiversity.
  </p>
  
  <h4 style="color: #388E3C; margin-top: 12px; margin-bottom: 6px;">Ecological Importance</h4>
  <ul style="margin-left: 20px; margin-bottom: 8px; color: #666;">
    <li style="margin-bottom: 4px;">Coastal protection and erosion control</li>
    <li style="margin-bottom: 4px;">Carbon sequestration and climate change mitigation</li>
    <li style="margin-bottom: 4px;">Nursery habitat for fish and crustaceans</li>
    <li style="margin-bottom: 4px;">Support for local fishing communities</li>
  </ul>
  
  <h4 style="color: #388E3C; margin-top: 12px; margin-bottom: 6px;">Caraga Region Distribution</h4>
  <p style="margin: 4px 0; line-height: 1.5; color: #666;">
    Found in coastal areas of Agusan del Norte, Agusan del Sur, Surigao del Norte, Surigao del Sur, and Dinagat Islands.
  </p>
  
  <p style="margin: 12px 0 4px 0; font-size: 13px; color: #999; font-style: italic;">
    Detailed species information unavailable at this time. For more information, consult with local environmental offices or marine biology experts.
  </p>
</div>
''';
  }

  /// Analyze image ug provide description (para sa non-mangrove images)
  /// Returns a user-friendly explanation of what's in the image
  Future<String> analyzeNonMangroveImage({
    required String detectedLabel,
    required double confidence,
    required String imagePath,
  }) async {
    try {
      debugPrint('🖼️ Analyzing uploaded image: $imagePath');
      debugPrint(
        '📊 Detection: $detectedLabel (${(confidence * 100).toStringAsFixed(1)}%)',
      );

      final prompt =
          '''
The user uploaded an image and our AI detection system analyzed it as "$detectedLabel" with ${(confidence * 100).toStringAsFixed(1)}% confidence.

However, this confidence level is below our threshold for mangrove species identification.

Please provide a helpful, educational explanation:

1. **What the image likely contains**: Based on the detection "$detectedLabel", explain in simple terms what might be in the photo (e.g., if it detected a leaf type, flower, tree bark, or other plant/object).

2. **Why it's not identified as a mangrove**: Briefly explain what makes this different from mangrove species typically found in Caraga Region, Philippines.

3. **Helpful guidance**: Provide friendly advice on:
   - What mangrove leaves look like (thick, waxy, oval-shaped)
   - Where to find mangroves (coastal areas, brackish water)
   - How to get better scan results (good lighting, focus on leaf)

4. **Encouragement**: Add a positive note encouraging them to try scanning actual mangrove leaves.

Use a friendly, conversational tone suitable for students and eco-enthusiasts. Write 4-5 sentences total. Be specific about the "$detectedLabel" detection.
''';

      final response = await http
          .post(
            Uri.parse('$_baseUrl/chat/completions'),
            headers: {
              'Authorization': 'Bearer $_apiKey',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'model': defaultModel,
              'messages': [
                {
                  'role': 'system',
                  'content':
                      'You are a helpful environmental education assistant. Be friendly and encouraging.',
                },
                {'role': 'user', 'content': prompt},
              ],
              'temperature': 0.7,
              'max_tokens': 350,
            }),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'] as String;
        debugPrint('✅ Image analysis complete!');
        return content;
      } else {
        throw Exception('API Error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Error analyzing image: $e');
      // Return fallback message
      return '''
It looks like this image shows "$detectedLabel" rather than a mangrove species. 

For this app to work properly, please scan actual mangrove leaves found in coastal areas. Mangroves have distinctive features like thick, waxy leaves and visible prop roots.

Try visiting a mangrove forest or coastal area in the Caraga Region to scan real mangrove specimens! 🌿
''';
    }
  }

  /// Helper method para sa fallback model
  Future<String?> _generateWithFallback(
    List<Map<String, dynamic>> messages,
    double temperature,
    int maxTokens,
  ) async {
    try {
      debugPrint('⚠️ Nag-try sa fallback model: $fallbackModel');

      final response = await http
          .post(
            Uri.parse('$_baseUrl/chat/completions'),
            headers: {
              'Authorization': 'Bearer $_apiKey',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'model': fallbackModel,
              'messages': messages,
              'temperature': temperature,
              'max_tokens': maxTokens,
            }),
          )
          .timeout(const Duration(seconds: 30));

      debugPrint('📥 Fallback response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['choices'] == null || data['choices'].isEmpty) {
          debugPrint('❌ Invalid fallback response structure');
          return null;
        }

        final content = data['choices'][0]['message']['content'] as String;
        debugPrint('✅ Fallback model success! Length: ${content.length}');
        return content.trim();
      } else {
        debugPrint('❌ Fallback model failed: ${response.statusCode}');
        debugPrint('📄 Fallback response body: ${response.body}');
        return null;
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Fallback model error: $e');
      debugPrint('📚 Fallback stack trace: $stackTrace');
      return null;
    }
  }
}
