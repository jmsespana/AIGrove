import 'package:flutter/material.dart';
import 'llm_service.dart';

class ChatbotService {
  final LLMService _llmService = LLMService();

  // Conversation history para sa context
  final List<Map<String, String>> _conversationHistory = [];

  /// System prompt para sa Caraga-specific mangrove assistant
  static const String systemPrompt = '''
explain the image content in simple Filipino.r
''';

  /// Send message ug kuha ang response
  Future<String> sendMessage(String userMessage) async {
    try {
      // I-add ang user message sa history
      _conversationHistory.add({'role': 'user', 'content': userMessage});

      // Prepare messages with system prompt
      final messages = [
        {'role': 'system', 'content': systemPrompt},
        ..._conversationHistory,
      ];

      // Get response from LLM
      final response = await _llmService.generateResponse(
        messages: messages,
        temperature: 0.7,
        maxTokens: 500,
      );

      // Check kung null ang response
      if (response == null || response.isEmpty) {
        throw Exception('Empty response from LLM service');
      }

      // I-add ang AI response sa history
      _conversationHistory.add({'role': 'assistant', 'content': response});

      // Keep only last 10 exchanges para dili sobra ka-taas ang history
      if (_conversationHistory.length > 20) {
        _conversationHistory.removeRange(0, _conversationHistory.length - 20);
      }

      return response;
    } catch (e) {
      debugPrint('❌ Chatbot error: $e');
      throw Exception('Failed to get response from chatbot');
    }
  }

  /// Handle non-mangrove image detection feedback
  /// Gamiton ni kung ang user nag-scan og dili mangrove
  Future<String> explainNonMangroveImage({
    required String detectedLabel,
    required double confidence,
    required String imagePath,
  }) async {
    try {
      debugPrint('🖼️ Explaining non-mangrove image to user...');

      // Get AI explanation of the actual uploaded image
      final explanation = await _llmService.analyzeNonMangroveImage(
        detectedLabel: detectedLabel,
        confidence: confidence,
        imagePath: imagePath,
      );

      // Add to conversation history for context
      _conversationHistory.add({
        'role': 'system',
        'content':
            'User scanned an image that was detected as "$detectedLabel" (not a mangrove).',
      });
      _conversationHistory.add({'role': 'assistant', 'content': explanation});

      return explanation;
    } catch (e) {
      debugPrint('❌ Error explaining image: $e');
      // Fallback message
      return '''
explain the image content in simple Filipino.
''';
    }
  }

  /// Send contextual message about misidentification
  /// Para sa follow-up questions after non-mangrove detection
  Future<String> sendFollowUpMessage(String userMessage) async {
    return await sendMessage(userMessage);
  }

  /// Clear conversation history
  void clearHistory() {
    _conversationHistory.clear();
  }

  /// Get suggested questions para sa users
  List<String> getSuggestedQuestions() {
    return [
      'What mangrove species are commonly found in Caraga Region?',
      'How do mangroves protect our coastlines from storms?',
      'What are the main threats to mangroves in the Philippines?',
      'How can local communities help conserve mangroves?',
      'What is the difference between true mangroves and mangrove associates?',
      'Why are mangroves called "blue carbon" ecosystems?',
      'What wildlife depends on mangrove forests in Caraga?',
      'How do mangroves help combat climate change?',
      'What are the traditional uses of mangroves in Filipino culture?',
      'Which mangrove species have medicinal properties?',
    ];
  }
}
