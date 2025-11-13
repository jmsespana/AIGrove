import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About AIgrove'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Container(
        decoration: AppTheme.getPageGradient(context),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header - friendly branding
                Center(
                  child: Column(
                    children: [
                      const SizedBox(height: 8),
                      Container(
                        height: 120,
                        width: 120,
                        decoration: BoxDecoration(
                          // ignore: deprecated_member_use
                          color: Colors.white.withOpacity(
                            0.25,
                          ), // Same sa login page
                          shape: BoxShape.circle,
                          boxShadow: [
                            // I-add ang shadow para mas nindot (Bisaya)
                            BoxShadow(
                              // ignore: deprecated_member_use
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 12,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: Padding(
                            padding: const EdgeInsets.all(
                              8,
                            ), // Spacing para dili lapaw ang logo (Bisaya)
                            child: Image.asset(
                              'assets/images/logo.png',
                              fit: BoxFit
                                  .contain, // I-change sa contain para klaro ang logo (Bisaya)
                              errorBuilder: (context, error, stackTrace) =>
                                  Icon(
                                    Icons.eco,
                                    size: 70,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'AIgrove',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Smart. Green. Connected to Conservation.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),

                // Card: About (What is AIGrove?)
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle(context, 'What is AIgrove?'),
                        const SizedBox(height: 8),
                        Text(
                          'AIgrove is a mobile application that uses artificial intelligence to identify and provide information about mangrove species in the Caraga Region. By simply taking a photo, users can instantly learn about different mangrove types and their ecological roles. The app also offers real-time geolocation data showing where species are found, interactive quizzes to support environmental learning, and a visual dashboard that highlights mangroves’ impact on carbon reduction, marine life expansion, and coastal protection — making it an easy and engaging tool for education, research, and conservation.',
                          style: const TextStyle(fontSize: 16, height: 1.5),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Card: Our Mission (separate card for clarity)
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle(context, 'Our Mission'),
                        const SizedBox(height: 8),
                        Text(
                          'AIgrove’s mission is to use AI technology to promote mangrove conservation by making species identification, environmental learning, and awareness accessible to everyone. It empowers communities to understand the ecological importance of mangroves and take action to protect them.',
                          style: const TextStyle(fontSize: 16, height: 1.5),
                        ),
                        const SizedBox(height: 12),
                        // Mga konkretong objectives (Tagalog/Bisaya comment)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            _MissionBullet(
                              text:
                                  'Make mangrove ID accessible via simple photo capture.',
                            ),
                            _MissionBullet(
                              text:
                                  'Provide localized geolocation data for research and restoration.',
                            ),
                            _MissionBullet(
                              text:
                                  'Engage communities through quizzes and challenges.',
                            ),
                            _MissionBullet(
                              text:
                                  'Support conservation decisions with easy-to-read dashboards.',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Card: Features
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle(context, 'Key Features'),
                        const SizedBox(height: 8),
                        _buildFeatureRow(
                          context,
                          Icons.search,
                          'Plant Identification',
                          'Identify plants and learn basic care tips.',
                        ),
                        _buildFeatureRow(
                          context,
                          Icons.map,
                          'Eco Map',
                          'Find green spots and community projects nearby.',
                        ),
                        _buildFeatureRow(
                          context,
                          Icons.emoji_events,
                          'Challenges',
                          'Join fun quiz challenges to help you build sustainable habits.',
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Card: Team
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle(context, 'Our Team'),
                        const SizedBox(height: 12),
                        _buildTeamSection(context),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Card: Contact
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle(context, 'Contact Us'),
                        const SizedBox(height: 12),
                        const Text(
                          'Have questions or want to collaborate? Reach out to our team via email. Tap an address to copy it to your clipboard.',
                          style: TextStyle(fontSize: 15, height: 1.4),
                        ),
                        const SizedBox(height: 12),
                        _buildContactTile(
                          context,
                          Icons.email,
                          'James España',
                          'jamesespaña@gmail.com',
                        ),
                        const SizedBox(height: 8),
                        _buildContactTile(
                          context,
                          Icons.email,
                          'Rovannah Delola',
                          'rovannahe.delola@gmail.com',
                        ),
                        const SizedBox(height: 8),
                        _buildContactTile(
                          context,
                          Icons.location_on,
                          'Address',
                          'Ampayon, Butuan City, Philippines',
                          copyLabel: 'Copied address',
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Thank you for using AIgrove! Together, we can make a difference in mangrove conservation.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade700,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Mga helper methods para sa clean na UI components (Tagalog/Bisaya comments)

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildFeatureRow(
    BuildContext context,
    IconData icon,
    String title,
    String desc,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          CircleAvatar(
            // ignore: deprecated_member_use
            backgroundColor: Theme.of(
              context,
            ).colorScheme.primary.withOpacity(0.12),
            child: Icon(icon, color: Theme.of(context).colorScheme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(desc, style: const TextStyle(fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Updated team section with photo placeholders
  Widget _buildTeamSection(BuildContext context) {
    // Team members - simple card layout
    final team = [
      {
        'name': 'James España',
        'role': 'Developer',
        'imagePath': 'assets/images/james_espana.jpeg',
      },
      {
        'name': 'Rovannah Delola',
        'role': 'Designer',
        'imagePath': 'assets/images/rovannah_delola.jpg',
      },
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: team.map((member) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6.0),
            child: Column(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    shape: BoxShape.circle,
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      member['imagePath'] as String,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        // Debugging print para makita nato ang problem (Tagalog/Bisaya)
                        // ignore: avoid_print
                        print(
                          'Error loading image: ${member['imagePath']} - $error',
                        );
                        return Icon(
                          Icons.person,
                          size: 56,
                          color: Colors.grey.shade400,
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  member['name'] as String,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                Text(
                  member['role'] as String,
                  style: TextStyle(color: Colors.grey.shade700),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // Contact tile with copy-to-clipboard behavior
  Widget _buildContactTile(
    BuildContext context,
    IconData icon,
    String label,
    String value, {
    String copyLabel = 'Copied',
  }) {
    return InkWell(
      onTap: () => _copyToClipboard(context, value, copyLabel),
      child: Row(
        children: [
          Icon(icon, size: 22, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Text(value),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(Icons.copy, size: 18, color: Colors.grey.shade600),
        ],
      ),
    );
  }

  // Kopyahon ang text sa clipboard, dayon show SnackBar (Tagalog/Bisaya comment)
  void _copyToClipboard(
    BuildContext context,
    String text,
    String snackbarLabel,
  ) {
    Clipboard.setData(ClipboardData(text: text)).then((_) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$snackbarLabel: $text'),
          duration: const Duration(seconds: 2),
        ),
      );
    });
  }
}

// Small reusable mission bullet widget para consistent spacing (Tagalog/Bisaya)
class _MissionBullet extends StatelessWidget {
  final String text;
  const _MissionBullet({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle,
            size: 18,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 15))),
        ],
      ),
    );
  }
}
