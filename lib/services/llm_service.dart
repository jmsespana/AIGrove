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
  late final String _apiKey;

  LLMService() {
    _apiKey = dotenv.env['GROQ_API_KEY'] ?? '';
    if (_apiKey.isEmpty) {
      debugPrint('⚠️ GROQ_API_KEY wala sa .env file!');
    } else {
      debugPrint('🔑 Groq API Key initialized: ${_apiKey.substring(0, 20)}...');
    }
  }

  Future<String> getDailyEcoTip() async {
    // ⭐ Check cache una before mag-API call para makatipid
    final prefs = await SharedPreferences.getInstance();
    final cachedTip = prefs.getString(_cacheKey);
    final cachedTimeStr = prefs.getString(_cacheTimeKey);

    if (cachedTip != null && cachedTimeStr != null) {
      final cachedTime = DateTime.parse(cachedTimeStr);
      final timeDifference = DateTime.now().difference(cachedTime);
      debugPrint(
        '⏰ Cached tip age: ${timeDifference.inHours} hours, ${timeDifference.inMinutes % 60} minutes',
      );

      if (timeDifference < _cacheDuration) {
        debugPrint('📦 Gigamit ang cached tip (dili na nag-API call)');
        return cachedTip;
      } else {
        debugPrint('🔄 Cache expired, fetching new tip...');
      }
    } else {
      debugPrint('📭 No cached tip found, fetching new one...');
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
            const Duration(seconds: 15),
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
    double? latitude,
    double? longitude,
    String? locationAddress,
  }) async {
    try {
      debugPrint('🌿 Getting species insight for: $speciesName');

      // Build location context string
      String locationContext = '';
      if (latitude != null && longitude != null) {
        if (locationAddress != null && locationAddress.isNotEmpty) {
          locationContext =
              'The scan was taken at: $locationAddress (coordinates: $latitude, $longitude).';
          debugPrint('📍 Including location in insight: $locationAddress');
        } else {
          locationContext =
              'The scan was taken at coordinates: $latitude, $longitude.';
          debugPrint('📍 Including location in insight: $latitude, $longitude');
        }
      }

      final prompt =
          '''
You are an expert marine biologist specializing in mangrove ecosystems in the Philippines, particularly in the Caraga Region.

A mangrove species has been detected: "$speciesName" with ${(confidence * 100).toStringAsFixed(1)}% confidence.
$locationContext

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
   - ${latitude != null && longitude != null ? (locationAddress != null && locationAddress.isNotEmpty ? 'IMPORTANT: Start with "<div style=\"margin: 12px 0; padding: 16px; background: linear-gradient(135deg, #E8F5E9 0%, #C8E6C9 100%); border-radius: 12px; border: 2px solid #4CAF50;\"><p style=\"margin: 0 0 12px 0;\"><strong>📍 Scanned at:</strong> $locationAddress</p><a id=\"view-on-map-btn\" href=\"#map\" style=\"display: inline-flex; align-items: center; gap: 8px; background: linear-gradient(135deg, #2E7D32 0%, #1B5E20 100%); color: white; text-decoration: none; padding: 12px 24px; border-radius: 8px; font-size: 14px; font-weight: bold; box-shadow: 0 2px 8px rgba(46, 125, 50, 0.3);\"><span style=\"font-size: 16px;\">🗺️</span>View Scan Location on Map</a></div>" BEFORE listing other distribution info' : 'IMPORTANT: Start with "<div style=\"margin: 12px 0; padding: 16px; background: linear-gradient(135deg, #E8F5E9 0%, #C8E6C9 100%); border-radius: 12px; border: 2px solid #4CAF50;\"><p style=\"margin: 0 0 12px 0;\"><strong>📍 Scanned at:</strong> [approximate location based on coordinates $latitude, $longitude]</p><a id=\"view-on-map-btn\" href=\"#map\" style=\"display: inline-flex; align-items: center; gap: 8px; background: linear-gradient(135deg, #2E7D32 0%, #1B5E20 100%); color: white; text-decoration: none; padding: 12px 24px; border-radius: 8px; font-size: 14px; font-weight: bold; box-shadow: 0 2px 8px rgba(46, 125, 50, 0.3);\"><span style=\"font-size: 16px;\">🗺️</span>View Scan Location on Map</a></div>" BEFORE listing other distribution info') : 'General distribution in Caraga'}
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
          .timeout(const Duration(seconds: 30));

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
      return _getFallbackSpeciesInsight(
        speciesName,
        confidence,
        latitude,
        longitude,
        locationAddress,
      );
    }
  }

  /// Fallback HTML kung mag-fail ang API (Offline Mode)
  /// Nag-provide og detailed static information para sa kada mangrove species
  String _getFallbackSpeciesInsight(
    String speciesName,
    double confidence, [
    double? latitude,
    double? longitude,
    String? locationAddress,
  ]) {
    final locationHtml = (latitude != null && longitude != null)
        ? '''
  <div style="margin: 12px 0; padding: 16px; background: linear-gradient(135deg, #E8F5E9 0%, #C8E6C9 100%); border-radius: 12px; border: 2px solid #4CAF50;">
    <p style="margin: 0 0 12px 0;"><strong>📍 Scanned at:</strong> ${locationAddress ?? '$latitude, $longitude'}</p>
    <a id="view-on-map-btn" href="#map" style="display: inline-flex; align-items: center; gap: 8px; background: linear-gradient(135deg, #2E7D32 0%, #1B5E20 100%); color: white; text-decoration: none; padding: 12px 24px; border-radius: 8px; font-size: 14px; font-weight: bold; box-shadow: 0 2px 8px rgba(46, 125, 50, 0.3);">
      <span style="font-size: 16px;">🗺️</span>View Scan Location on Map
    </a>
  </div>
'''
        : '';

    // I-kuha ang static data based sa species name
    final speciesData = _getStaticSpeciesData(speciesName);

    return '''
<div style="padding: 12px;">
  <h3 style="color: #2E7D32; margin-bottom: 8px;">${speciesData['scientificName']}</h3>
  
  <h4 style="color: #388E3C; margin-top: 12px; margin-bottom: 6px;">Species Identification</h4>
  <p style="margin: 4px 0; line-height: 1.5;"><strong>Scientific Name:</strong> <em>${speciesData['scientificName']}</em></p>
  <p style="margin: 4px 0; line-height: 1.5;"><strong>Common Name:</strong> ${speciesData['commonName']}</p>
  <p style="margin: 4px 0; line-height: 1.5;"><strong>Local Name:</strong> ${speciesData['localName']}</p>
  <p style="margin: 4px 0; line-height: 1.5;"><strong>Detection Confidence:</strong> ${(confidence * 100).toStringAsFixed(1)}%</p>
  
  <h4 style="color: #388E3C; margin-top: 12px; margin-bottom: 6px;">Physical Characteristics</h4>
  <p style="margin: 4px 0; line-height: 1.5;">${speciesData['characteristics']}</p>
  
  <h4 style="color: #388E3C; margin-top: 12px; margin-bottom: 6px;">Ecological Role</h4>
  <p style="margin: 4px 0; line-height: 1.5;">${speciesData['ecologicalRole']}</p>
  
  <h4 style="color: #388E3C; margin-top: 12px; margin-bottom: 6px;">Distribution in Caraga Region</h4>
  $locationHtml
  <p style="margin: 4px 0; line-height: 1.5;">${speciesData['distribution']}</p>
  
  <h4 style="color: #388E3C; margin-top: 12px; margin-bottom: 6px;">Conservation & Uses</h4>
  <p style="margin: 4px 0; line-height: 1.5;">${speciesData['conservation']}</p>
  
  <p style="margin: 12px 0 4px 0; font-size: 12px; color: #999; font-style: italic;">
    ℹ️ Offline Mode: Showing stored species information
  </p>
</div>
''';
  }

  /// I-return ang static data para sa specific mangrove species
  Map<String, String> _getStaticSpeciesData(String speciesName) {
    final data = {
      'Avicennia Marina': {
        'scientificName': 'Avicennia marina',
        'commonName': 'Gray Mangrove',
        'localName': 'Miyapi, Piapi',
        'characteristics':
            'Features gray-green leaves with silver undersides, pneumatophores (breathing roots) protruding from mud, small yellow-orange flowers, and flat, bean-shaped fruits. Grows 3-10 meters tall.',
        'ecologicalRole':
            'Thrives in high salinity environments, provides coastal protection, supports crab and mollusc populations, and sequesters significant carbon. Often found in the high intertidal zone.',
        'distribution':
            'Common throughout Caraga Region coastlines, particularly in Surigao del Norte, Surigao del Sur, and Dinagat Islands. Tolerates high salinity and temperature extremes.',
        'conservation':
            'Least Concern status. Used traditionally for firewood and tannins. Threatened by coastal development and aquaculture expansion. Active replanting programs in several Caraga municipalities.',
      },
      'Avicennia Officinalis': {
        'scientificName': 'Avicennia officinalis',
        'commonName': 'Indian Mangrove',
        'localName': 'Miyapi, Bungalon',
        'characteristics':
            'Distinct elliptical leaves with bright green upper surface and gray-green underside, numerous pencil-like pneumatophores, bright orange flowers, and heart-shaped fruits. Reaches 8-12 meters in height.',
        'ecologicalRole':
            'Prefers muddy substrates in mid to high tidal zones, excellent for soil stabilization, provides habitat for mudskippers and crabs, and supports honey production from its nectar-rich flowers.',
        'distribution':
            'Widespread in Agusan del Norte and Agusan del Sur coastal areas, particularly in Butuan Bay. Also found in Surigao provinces in mixed mangrove stands.',
        'conservation':
            'Least Concern. Valued for honey production and traditional medicine. Facing pressure from urban expansion. Protected in several mangrove sanctuaries across Caraga.',
      },
      'Bruguiera Cylindrica': {
        'scientificName': 'Bruguiera cylindrica',
        'commonName': 'Cylindrical-Fruited Mangrove',
        'localName': 'Pototan, Busain',
        'characteristics':
            'Characterized by glossy, elliptical leaves with prominent midribs, distinctive knee-shaped roots, pinkish-red flowers with 8-13 petals, and cylindrical propagules. Grows 5-15 meters tall.',
        'ecologicalRole':
            'Inhabits mid-tidal zones with muddy substrates, provides nesting sites for birds, supports diverse invertebrate communities, and contributes to sediment accretion and shoreline stabilization.',
        'distribution':
            'Present in all Caraga provinces, especially abundant in Surigao del Sur. Common in relatively undisturbed mangrove forests with good freshwater influence.',
        'conservation':
            'Least Concern. Bark used for tanning and traditional medicine. Wood valued for construction. Threatened by overexploitation and habitat conversion.',
      },
      'Bruguiera Gymnorhiza': {
        'scientificName': 'Bruguiera gymnorhiza',
        'commonName': 'Large-Leafed Orange Mangrove',
        'localName': 'Pototan, Busain',
        'characteristics':
            'Large, leathery leaves up to 20cm long with wavy margins, prominent buttress roots, large reddish flowers, and long propagules (20-40cm). One of the tallest mangroves, reaching 25-30 meters.',
        'ecologicalRole':
            'Dominant in mature mangrove forests, provides extensive canopy cover, supports diverse epiphyte communities, excellent for carbon storage, and creates complex root systems for marine life.',
        'distribution':
            'Found in pristine mangrove areas throughout Caraga, particularly in Agusan provinces. Indicates healthy, mature mangrove ecosystems with stable conditions.',
        'conservation':
            'Least Concern globally but declining locally. Highly valued timber species, used in construction and boat-building. Priority species for conservation in Caraga Region.',
      },
      'Ceriops Tagal': {
        'scientificName': 'Ceriops tagal',
        'commonName': 'Yellow Mangrove, Spurred Mangrove',
        'localName': 'Tangal, Malatangal',
        'characteristics':
            'Small elliptical leaves with rounded tips, smooth gray bark, aerial roots from lower branches, white to cream flowers with distinctive spurs, and cigar-shaped propagules. Grows 6-15 meters.',
        'ecologicalRole':
            'Thrives in mid to high intertidal zones, highly tolerant of high salinity, provides habitat for tree-climbing crabs, and important for sediment binding in transitional zones.',
        'distribution':
            'Widespread across Caraga coastlines, particularly in Dinagat Islands and Surigao del Norte. Often forms pure stands in hypersaline conditions.',
        'conservation':
            'Least Concern. Bark rich in tannins for leather processing. Wood used for charcoal and fuel. Relatively resistant to disturbance but affected by coastal development.',
      },
      'Excoecaria Agallocha': {
        'scientificName': 'Excoecaria agallocha',
        'commonName': 'Blind-Your-Eye Mangrove, Milky Mangrove',
        'localName': 'Buta-buta, Alipata',
        'characteristics':
            'Smooth, glossy leaves that turn red before falling, contains toxic milky latex, small greenish flowers in catkins, and three-lobed capsule fruits. Grows 6-15 meters tall.',
        'ecologicalRole':
            'Occupies landward fringes and high tidal zones, provides shelter for small animals, contributes to nutrient cycling, and acts as buffer zone between mangroves and terrestrial vegetation.',
        'distribution':
            'Found in all Caraga provinces, particularly along riverbanks and upper tidal areas in Agusan del Norte and Surigao del Sur. Prefers less saline conditions.',
        'conservation':
            'Least Concern. Used traditionally despite toxicity. Wood used for small implements. Important indicator species for landward mangrove boundaries. Relatively stable populations.',
      },
      'Lumnitzera Littorea': {
        'scientificName': 'Lumnitzera littorea',
        'commonName': 'Black Mangrove',
        'localName': 'Kulasi, Tabau',
        'characteristics':
            'Small, thick succulent leaves clustered at branch tips, dark fissured bark, showy red or white flowers with long stamens, and oval fruits. Compact tree or shrub, 3-8 meters tall.',
        'ecologicalRole':
            'Pioneer species in harsh conditions, highly salt-tolerant, attracts pollinators with colorful flowers, stabilizes sandy and rocky substrates, and withstands strong wave action.',
        'distribution':
            'Less common in Caraga, found mainly in Dinagat Islands and Surigao del Norte coastal areas. Prefers rocky shores and coral rubble substrates.',
        'conservation':
            'Near Threatened. Declining due to habitat specificity and limited distribution. Protected in marine sanctuaries. Important for biodiversity in unique mangrove habitats.',
      },
      'Nypa Fruticans': {
        'scientificName': 'Nypa fruticans',
        'commonName': 'Nipa Palm',
        'localName': 'Nipa, Sasa',
        'characteristics':
            'Stemless palm with long feathery fronds emerging from underground rhizomes, large globular fruit heads containing angular nuts, and can form dense stands. Fronds reach 6-9 meters.',
        'ecologicalRole':
            'Dominates brackish water areas along rivers and estuaries, prevents erosion with extensive root systems, provides materials for traditional housing, and supports unique wildlife communities.',
        'distribution':
            'Extremely abundant throughout Caraga, especially in Agusan provinces along river deltas. Forms extensive pure stands in low salinity areas with freshwater influence.',
        'conservation':
            'Least Concern. Economically important for sap (vinegar, sugar), fronds (roofing), and young shoots (food). Sustainably harvested. Some areas threatened by reclamation.',
      },
      'Rhizophora Apiculata': {
        'scientificName': 'Rhizophora apiculata',
        'commonName': 'Tall-Stilt Mangrove',
        'localName': 'Bakauan Babae, Bakawan',
        'characteristics':
            'Large, thick oval leaves with pointed tips, extensive prop root systems forming stilt-like arches, cream-colored flowers, and long cigar-shaped propagules (20-40cm). Grows 20-30 meters tall.',
        'ecologicalRole':
            'Dominates seaward zones, provides crucial nursery habitat for fish and crustaceans, extensive carbon sequestration, creates complex 3D habitat structure, and excellent wave energy dissipation.',
        'distribution':
            'One of the most common mangroves in Caraga, found in all coastal provinces. Forms dense forests in Agusan and Surigao areas, particularly in protected bays.',
        'conservation':
            'Least Concern but heavily exploited. Premium timber for construction, poles, and charcoal. Focus of major replanting efforts throughout Caraga Region.',
      },
      'Rhizophora Mucronata': {
        'scientificName': 'Rhizophora mucronata',
        'commonName': 'Red Mangrove',
        'localName': 'Bakauan Lalaki, Bakawan',
        'characteristics':
            'Similar to R. apiculata but with broader leaves lacking pointed tips, more robust prop roots, larger flowers, and thicker, club-shaped propagules (30-60cm). Can reach 25-35 meters.',
        'ecologicalRole':
            'Pioneer species in coastal colonization, creates new land through sediment trapping, critical fish nursery, supports oyster attachment, and forms protective coastal barriers.',
        'distribution':
            'Abundant throughout Caraga coastlines, particularly in Surigao provinces and Dinagat Islands. Thrives in wave-exposed areas and open coastlines.',
        'conservation':
            'Least Concern. Highly valued timber species. Extensively planted in restoration projects. Faces pressure from overharvesting and conversion to fishponds.',
      },
      'Rhizophora Stylosa': {
        'scientificName': 'Rhizophora stylosa',
        'commonName': 'Spotted Mangrove, Red Mangrove',
        'localName': 'Bakauan Bato',
        'characteristics':
            'Smaller than other Rhizophora species, elliptical leaves often with dark spots underneath, slender prop roots, white flowers becoming cream with age, and curved propagules (15-25cm). Grows 5-15 meters.',
        'ecologicalRole':
            'Tolerates rocky substrates and higher salinity, colonizes disturbed areas quickly, provides shelter in lagoons and coves, and supports specialized crab species.',
        'distribution':
            'Present in all Caraga provinces, particularly common in Dinagat Islands. Prefers sheltered bays, lagoons, and areas with coral rubble or rocky substrates.',
        'conservation':
            'Least Concern. Used for poles and firewood. More resistant to some environmental stresses. Important for mangrove diversity and habitat complexity.',
      },
      'Sonneratia Alba': {
        'scientificName': 'Sonneratia alba',
        'commonName': 'White Mangrove, Mangrove Apple',
        'localName': 'Pagatpat Puti, Pedada Puti',
        'characteristics':
            'Broad oval leaves, smooth light gray bark, cone-shaped pneumatophores, large showy white flowers that open at night, and flattened apple-like fruits. Grows 10-20 meters tall.',
        'ecologicalRole':
            'Pioneer species in seaward colonization, bat-pollinated flowers support flying fox populations, fruits eaten by wildlife, excellent for erosion control in exposed areas.',
        'distribution':
            'Common in Caraga coastal areas, especially in Surigao del Norte and Dinagat Islands. Occupies seaward fringes and exposed coastlines with sandy substrates.',
        'conservation':
            'Least Concern. Fruits edible but sour, used in local cuisines. Important for coastal protection. Included in rehabilitation programs for exposed coastlines.',
      },
      'Sonneratia Caseolaris': {
        'scientificName': 'Sonneratia caseolaris',
        'commonName': 'Cork Mangrove, Mangrove Apple',
        'localName': 'Pagatpat Pula, Pedada Pula',
        'characteristics':
            'Similar to S. alba but with red flowers, corky bark, larger fruits up to 5cm diameter, and often growing larger. Reaches 15-25 meters in favorable conditions.',
        'ecologicalRole':
            'Prefers estuarine areas with freshwater influence, important for bat conservation through pollination, contributes to sediment building, and provides food source for wildlife.',
        'distribution':
            'Found along major river mouths in Caraga, particularly in Agusan River delta and coastal Surigao del Sur. Requires lower salinity than other mangroves.',
        'conservation':
            'Least Concern. Fruits more palatable than S. alba, used in traditional food. Bark used for cork substitute. Declining in some areas due to river modification.',
      },
      'Sonneratia Ovata': {
        'scientificName': 'Sonneratia ovata',
        'commonName': 'Ovate-Leafed Mangrove',
        'localName': 'Pagatpat, Pedada',
        'characteristics':
            'Distinctive ovate to elliptical leaves broader than other Sonneratia, pink to red flowers, rounded fruits, and prominent breathing roots. Medium-sized tree, 8-15 meters.',
        'ecologicalRole':
            'Occupies transitional zones between true marine and freshwater-influenced areas, supports diverse pollinator communities, and contributes to habitat diversity in mixed forests.',
        'distribution':
            'Less common in Caraga, found primarily in Agusan provinces in brackish water areas. Often grows with Nypa in river-influenced locations.',
        'conservation':
            'Least Concern but less abundant. Important for ecosystem diversity. Faces habitat loss from agricultural expansion. Protected in some river-mouth sanctuaries.',
      },
      'Xylocarpus Granatum': {
        'scientificName': 'Xylocarpus granatum',
        'commonName': 'Cannonball Mangrove, Puzzle Nut Tree',
        'localName': 'Tabigi, Piagau',
        'characteristics':
            'Large compound leaves with 4-6 leaflets, buttressed trunk, small white-green flowers, and distinctive large round fruits (8-15cm) resembling cannonballs. Grows 10-20 meters tall.',
        'ecologicalRole':
            'Inhabits landward zones and creek banks, provides canopy cover, seeds eaten by crabs and wildlife, contributes to nutrient cycling, and indicates mature forest conditions.',
        'distribution':
            'Scattered throughout Caraga mangrove forests, more common in Agusan del Norte and Surigao del Sur. Prefers less saline conditions along tidal creeks.',
        'conservation':
            'Least Concern. Valued for durable termite-resistant timber used in boat-building and construction. Seeds have medicinal properties. Declining due to selective logging.',
      },
    };

    // I-return ang data, kung wala sa map, generic data
    return data[speciesName] ??
        {
          'scientificName': speciesName,
          'commonName': 'Mangrove Species',
          'localName': 'Bakawan',
          'characteristics':
              'This mangrove species exhibits characteristics typical of Philippine coastal flora, adapted to brackish water environments.',
          'ecologicalRole':
              'Plays a vital role in coastal protection, provides habitat for marine life, and contributes to carbon sequestration.',
          'distribution':
              'Found in coastal areas throughout the Caraga Region, including Agusan del Norte, Agusan del Sur, Surigao del Norte, Surigao del Sur, and Dinagat Islands.',
          'conservation':
              'Part of ongoing conservation efforts in the Philippines. Faces threats from coastal development and climate change.',
        };
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
