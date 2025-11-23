import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

/// Species Information Page
///
/// Detailed page na nagpakita sa complete info sa detected mangrove with LLM insights
class SpeciesInfoPage extends StatelessWidget {
  final String scientificName;
  final double confidence;
  final String? imagePath;
  final String? llmInsightHtml; // LLM-generated HTML content

  const SpeciesInfoPage({
    super.key,
    required this.scientificName,
    required this.confidence,
    this.imagePath,
    this.llmInsightHtml,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar with image
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                scientificName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic,
                  shadows: [
                    Shadow(
                      offset: Offset(0, 1),
                      blurRadius: 3,
                      color: Colors.black45,
                    ),
                  ],
                ),
              ),
              background: imagePath != null
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.file(
                          File(imagePath!),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              _buildPlaceholderImage(),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                // ignore: deprecated_member_use
                                Colors.black.withOpacity(0.7),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                  : _buildPlaceholderImage(),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Column(
              children: [
                // Confidence Badge
                _buildConfidenceBadge(),

                // LLM AI Insight (if available) - Display as main content
                if (llmInsightHtml != null) _buildLLMInsightCard(context),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.green[700]!, Colors.green[900]!],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.eco,
          size: 120,
          // ignore: deprecated_member_use
          color: Colors.white.withOpacity(0.3),
        ),
      ),
    );
  }

  Widget _buildConfidenceBadge() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.green[700],
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.green[700]!.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.verified, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Text(
            'Confidence: ${(confidence * 100).toStringAsFixed(1)}%',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// Build LLM AI Insight Card
  /// Displays AI-generated information about the species
  Widget _buildLLMInsightCard(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDarkMode ? Colors.grey[850]! : Colors.white;
    final titleColor = isDarkMode ? Colors.white : Colors.black;
    final accentColor = isDarkMode
        ? const Color.fromARGB(255, 16, 235, 60)
        : const Color(0xFF6A1B9A);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accentColor.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0.15),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(
                    255,
                    179,
                    24,
                    193,
                  ).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: Colors.purple,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'AI-Generated Insight',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: titleColor,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(
                    255,
                    31,
                    176,
                    75,
                  ).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'AI',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 16, 235, 60),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Html(
            data: llmInsightHtml!,
            style: {
              "body": Style(margin: Margins.zero, padding: HtmlPaddings.zero),
              "h3": Style(
                color: accentColor,
                fontSize: FontSize(17),
                fontWeight: FontWeight.bold,
                margin: Margins.only(bottom: 8),
              ),
              "p": Style(
                fontSize: FontSize(14),
                lineHeight: const LineHeight(1.5),
                margin: Margins.only(bottom: 8),
                color: isDarkMode
                    ? const Color(0xFFE0E0E0)
                    : const Color(0xFF424242),
              ),
              "ul": Style(margin: Margins.only(left: 16, bottom: 8)),
              "li": Style(
                fontSize: FontSize(13.5),
                lineHeight: const LineHeight(1.5),
                margin: Margins.only(bottom: 4),
                color: isDarkMode
                    ? const Color(0xFFE0E0E0)
                    : const Color(0xFF424242),
              ),
              "strong": Style(fontWeight: FontWeight.bold, color: accentColor),
            },
          ),
        ],
      ),
    );
  }
}
