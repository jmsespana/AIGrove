import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About AIGrove'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with custom logo - ready for your image
              Center(
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    // Logo container - i-place ang inyong logo diri
                    Container(
                      height: 120,
                      width: 120,
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        shape: BoxShape.circle,
                      ),
                      // Replaced Icon with Image.asset for custom logo
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/aigrove_logo.png', // I-place ang inyong logo sa assets folder
                          fit: BoxFit.cover,
                          // Error handler kung wala pa ang logo
                          errorBuilder: (context, error, stackTrace) => Icon(
                            Icons.eco,
                            size: 70,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'AIGrove',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Version 1.0.0',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),

              // Mission section
              _buildSectionTitle(context, 'Our Mission'),
              const SizedBox(height: 8),
              _buildSectionContent(
                'AIGrove aims to promote ecological awareness and sustainable practices through AI-powered assistance. We help users identify plants, track their environmental impact, and join eco-friendly challenges to make a positive difference in our world.',
              ),
              const SizedBox(height: 24),

              // Features section
              _buildSectionTitle(context, 'Key Features'),
              const SizedBox(height: 8),
              _buildFeaturesList(context),
              const SizedBox(height: 24),

              // Team section - updated for two members with photos
              _buildSectionTitle(context, 'Our Team'),
              const SizedBox(height: 16),
              _buildTeamSection(context),
              const SizedBox(height: 24),

              // Contact section
              _buildSectionTitle(context, 'Contact Us'),
              const SizedBox(height: 8),
              _buildContactInfo(context),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  // Mga helper methods para sa clean na UI components
  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildSectionContent(String content) {
    return Text(content, style: const TextStyle(fontSize: 16, height: 1.5));
  }

  Widget _buildFeaturesList(BuildContext context) {
    final features = [
      {
        'icon': Icons.search,
        'title': 'Plant Identification',
        'desc': 'Identify plants using AI-powered image recognition',
      },
      {
        'icon': Icons.map,
        'title': 'Eco Map',
        'desc': 'Discover green spaces and eco-friendly locations near you',
      },
      {
        'icon': Icons.emoji_events,
        'title': 'Challenges',
        'desc': 'Participate in eco-friendly challenges to earn rewards',
      },
      {
        'icon': Icons.analytics,
        'title': 'Impact Tracking',
        'desc': 'Monitor your environmental impact over time',
      },
    ];

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: features.length,
      itemBuilder: (context, index) {
        final feature = features[index];
        return Card(
          elevation: 1,
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            leading: Icon(
              feature['icon'] as IconData,
              color: Theme.of(context).colorScheme.secondary,
            ),
            title: Text(feature['title'] as String),
            subtitle: Text(feature['desc'] as String),
          ),
        );
      },
    );
  }

  // Updated team section with photo placeholders
  Widget _buildTeamSection(BuildContext context) {
    // Updated for two team members lang
    final team = [
      {
        'name': 'James España',
        'role': 'Developer',
        'imagePath':
            'assets/images/james_espana.jpeg', // Direct path without subfolder
      },
      {
        'name': 'Rovannah Delola',
        'role': 'Designer',
        'imagePath': 'assets/images/rovannah_delola.jpg', // Note .jpg extension
      },
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: team.map((member) {
        return Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Photo placeholder with direct path
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        // ignore: deprecated_member_use
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      // Use direct path from the map
                      member['imagePath'] as String,
                      fit: BoxFit.cover,
                      // Add debugging print
                      errorBuilder: (context, error, stackTrace) {
                        // Print error para makita nato ang problem
                        // ignore: avoid_print
                        print(
                          'Error loading image: ${member['imagePath']} - $error',
                        );
                        return Icon(
                          Icons.person,
                          size: 60,
                          color: Colors.grey.shade400,
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  member['name'] as String,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  member['role'] as String,
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 15),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildContactInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildContactItem(Icons.email, 'Email', 'contact@aigrove.com'),
        const SizedBox(height: 8),
        _buildContactItem(Icons.public, 'Website', 'www.aigrove.com'),
        const SizedBox(height: 8),
        _buildContactItem(
          Icons.location_on,
          'Address',
          'Green Building, Eco Street, Sustainable City',
        ),
      ],
    );
  }

  Widget _buildContactItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(value),
          ],
        ),
      ],
    );
  }
}
