import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
// I-add ang shared AppTheme para magamit ang parehas na background
import '../theme/app_theme.dart';

// Helper para i-convert opacity (0..1) papuntang alpha (0..255)
int _alpha(double opacity) => (opacity * 255).round();

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // removed unused 'theme' variable

    // compute bottom padding to account for device insets (SafeArea) and add a small buffer
    final double dynamicBottomPadding = MediaQuery.of(context).viewPadding.bottom + 24.0;

    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async => false,
       child: Scaffold(
        backgroundColor: Colors.transparent, // para makita ang custom bg
        body: Container(
          // Gamit ang same theme-aware gradient gaya ng iba pang pages
          decoration: AppTheme.getPageGradient(context),
          child: SafeArea(
            child: SingleChildScrollView(
              // use dynamic bottom padding to avoid tiny overflow (e.g. 2.0 pixels)
              padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, dynamicBottomPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Dashboard welcome header (Tagalog/Bisaya comments ok)
                  const Text(
                    'Welcome to AIgrove Dashboard',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Discover how mangroves protect, sustain, and enrich our environment.',
                    style: TextStyle(
                      fontSize: 14,
                      color: const Color.fromARGB(255, 68, 68, 68),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Environmental Impact Cards - Horizontal scrollable
                  const Text(
                    'Environmental Impact',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: const [
                        EnvironmentalImpactCard(
                          title: 'Carbon Reduction',
                          value: '25.3',
                          unit: 'tons CO₂/ha/yr',
                          description: 'Annual CO₂ removed per hectare (approx.)',
                          icon: Icons.co2,
                          color: Colors.teal,
                          bgPattern: 'carbon',
                          info: '''
Quick facts:
- Estimated removal: ~25.3 tons CO₂ per hectare each year.
- Where it matters: Healthy, intact mangrove forests and restored sites.
- How you can help: Protect existing mangroves, support restoration, avoid clearing.
Takeaway: More mangroves = less CO₂ in the air.''',
                        ),
                        SizedBox(width: 16),
                        EnvironmentalImpactCard(
                          title: 'Marine Expansion Zones',
                          value: '12.5',
                          unit: 'km²/year',
                          description: 'Potential suitable area for new/restored mangroves',
                          icon: Icons.water,
                          color: Colors.indigo,
                          bgPattern: 'marine',
                          info: '''
Quick facts:
- Potential area: Up to ~12.5 km² per year in suitable coastlines.
- Suitable site signs: Gentle slope, correct salinity, natural tidal flow, low pollution.
- Simple actions: Map sites, restore hydrology, plant native seedlings, monitor results.
Note: Expert assessment needed before large-scale planting.''',
                        ),
                        SizedBox(width: 16),
                        EnvironmentalImpactCard(
                          title: 'Coastal Protection',
                          value: '70',
                          unit: '% wave energy',
                          description: 'Estimated reduction in wave energy from mangrove belts',
                          icon: Icons.waves,
                          color: Colors.blue,
                          bgPattern: 'waves',
                          info: '''
Quick facts:
- Wave energy reduction: Up to ~70% with a healthy mangrove belt.
- Benefits: Less coastal erosion, lower flood risk, sediment trapping and shore stabilization.
- How it works: Roots and trunks slow waves and capture sediment.
Practical tip: Keep buffer zones and avoid removing mangroves near vulnerable coasts.''',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Province Statistics Section
                  const Text(
                    'Provincial Statistics',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  GridView.count(
                     shrinkWrap: true,
                     physics: const NeverScrollableScrollPhysics(),
                     crossAxisCount: 2,
                     mainAxisSpacing: 16,
                     crossAxisSpacing: 16,
                     childAspectRatio: 0.85,
                     // remove 'const' so runtime map/list literals (speciesDetails) are allowed
                     children: [
                       ProvinceCard(
                         province: 'Agusan del Norte',
                         treeCount: 5,
                         color: Color.fromARGB(255, 191, 160, 5),
                         speciesByYear: {'2021': 5},
                         speciesDetails: {
                           '2021': [
                             'Avicennia officinalis',
                             'Ceriops tagal',
                             'Rhizophora mucronata',
                             'Sonneratia alba',
                             'Sonneratia caseolaris',
                           ],
                         },
                       ),
                       ProvinceCard(
                         province: 'Surigao del Sur',
                         treeCount: 15,
                         color: Color.fromARGB(255, 126, 202, 130),
                         speciesByYear: {'2022': 8, '2021': 7},
                         speciesDetails: {
                           '2021': [
                             'Bruguiera gymnorhiza',
                             'Lumnitzera littorea',
                             'Nypa fruticans',
                             'Rhizophora apiculata',
                             'Rhizophora mucronata',
                             'Sonneratia alba',
                             'Xylocarpus granatum',
                           ],
                           '2022': [
                             'Avicennia marina',
                             'Bruguiera gymnorhiza',
                             'Ceriops tagal',
                             'Rhizophora apiculata',
                             'Rhizophora mucronata',
                             'Sonneratia alba',
                             'Sonneratia ovata',
                             'Xylocarpus granatum',
                           ],
                         },
                       ),
                       ProvinceCard(
                         province: 'Surigao del Norte',
                         // total reports = sum of species counts per year (13+13+13)
                         treeCount: 39,
                         color: Color.fromARGB(255, 40, 167, 33),
                         speciesByYear: {
                           '2022': 13,
                           '2021': 13,
                           '2020': 13,
                         },
                         speciesDetails: {
                           '2020': [
                             'Avicennia marina',
                             'Avicennia officinalis',
                             'Bruguiera cylindrica',
                             'Bruguiera gymnorhiza',
                             'Ceriops tagal',
                             'Excoecaria agallocha',
                             'Lumnitzera littorea',
                             'Nypa fruticans',
                             'Rhizophora apiculata',
                             'Rhizophora mucronata',
                             'Rhizophora stylosa',
                             'Sonneratia alba',
                             'Xylocarpus granatum',
                           ],
                           '2021': [
                             'Avicennia marina',
                             'Avicennia officinalis',
                             'Bruguiera cylindrica',
                             'Bruguiera gymnorhiza',
                             'Ceriops tagal',
                             'Lumnitzera littorea',
                             'Nypa fruticans',
                             'Rhizophora apiculata',
                             'Rhizophora mucronata',
                             'Rhizophora stylosa',
                             'Sonneratia alba',
                             'Sonneratia ovata',
                             'Xylocarpus granatum',
                           ],
                           '2022': [
                             'Avicennia marina',
                             'Avicennia officinalis',
                             'Bruguiera cylindrica',
                             'Bruguiera gymnorhiza',
                             'Ceriops tagal',
                             'Lumnitzera littorea',
                             'Nypa fruticans',
                             'Rhizophora apiculata',
                             'Rhizophora mucronata',
                             'Rhizophora stylosa',
                             'Sonneratia alba',
                             'Sonneratia ovata',
                             'Xylocarpus granatum',
                           ],
                         },
                       ),
                       ProvinceCard(
                         province: 'Dinagat Islands',
                         treeCount: 10,
                         color: Color.fromARGB(255, 52, 152, 219),
                         speciesByYear: {'2021': 10},
                         speciesDetails: {
                           '2021': [
                             'Avicennia officinalis',
                             'Ceriops tagal',
                             'Lumnitzera littorea',
                             'Nypa fruticans',
                             'Rhizophora apiculata',
                             'Rhizophora mucronata',
                             'Rhizophora stylosa',
                             'Sonneratia alba',
                             'Sonneratia caseolaris',
                             'Xylocarpus granatum',
                           ],
                         },
                       ),
                     ],
                   ),

                  const SizedBox(height: 32),

                  // Chart Title with icon
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.green.shade700, Colors.teal.shade600],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.trending_up,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Mangrove Species Trends',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Track species diversity across Caraga Region over time',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Improved Line Chart Container
                  Container(
                    height: 350, // Increased height for better visibility
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white,
                          Colors.green.shade50.withAlpha(_alpha(0.3)),
                          Colors.blue.shade50.withAlpha(_alpha(0.2)),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.shade300.withAlpha(_alpha(0.4)),
                          spreadRadius: 0,
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                        BoxShadow(
                          color: Colors.black.withAlpha(_alpha(0.08)),
                          spreadRadius: 0,
                          blurRadius: 30,
                          offset: const Offset(0, 8),
                        ),
                      ],
                      border: Border.all(
                        color: Colors.green.shade100.withAlpha(_alpha(0.6)),
                        width: 2,
                      ),
                    ),
                    child: const MangroveSpeciesChart(),
                  ),

                  const SizedBox(height: 32),
                  const Text(
                    'Quick Actions',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ActionButton(
                          title: 'Report New',
                          icon: Icons.add_location_alt,
                          color: Colors.green,
                          onTap: () {},
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ActionButton(
                          title: 'Education',
                          icon: Icons.school,
                          color: Colors.orange,
                          onTap: () {},
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ActionButton(
                          title: 'Initiatives',
                          icon: Icons.eco,
                          color: Colors.blue,
                          onTap: () {},
                        ),
                      ),
                    ],
                  ),

                  // small extra spacer so content never touches the bottom exactly (prevents tiny overflow)
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// EnvironmentalImpactCard (deprecated withOpacity removed)
class EnvironmentalImpactCard extends StatelessWidget {
  final String title;
  final String value;
  final String unit;
  final String description;
  final IconData icon;
  final Color color;
  final String bgPattern;
  final String info; // additional short/expanded info shown under the main stats

  const EnvironmentalImpactCard({
    super.key,
    required this.title,
    required this.value,
    required this.unit,
    required this.description,
    required this.icon,
    required this.color,
    required this.bgPattern,
    this.info = '',
  });

  @override
  Widget build(BuildContext context) {
    // Parehong sukat para sa lahat ng cards para consistent UI
    const double cardWidth = 200;
    // add a tiny buffer to prevent 2.0px rounding overflow on some devices
    const double cardHeight = 222;
 
     return Material(
       color: Colors.transparent,
       child: InkWell(
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(title),
              content: SingleChildScrollView(
                // Scrollable dialog para sa mas mahahabang impormasyon
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('$value $unit', style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(description),
                    const SizedBox(height: 12),
                    if (info.isNotEmpty) _buildFormattedInfo(context, info),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
              ],
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          width: cardWidth,
          height: cardHeight,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  color.withAlpha(_alpha(0.8)),
                  color,
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: color.withAlpha(_alpha(0.3)),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            // clip background pattern so negative Positioned icons cannot overflow the card
            child: Stack(
              clipBehavior: Clip.hardEdge,
               children: [
                 _buildBackgroundPattern(bgPattern),
                 Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     Container(
                       padding: const EdgeInsets.all(8),
                       decoration: BoxDecoration(
                         color: Colors.white.withAlpha(_alpha(0.2)),
                         borderRadius: BorderRadius.circular(12),
                       ),
                       child: Icon(icon, color: Colors.white, size: 24),
                     ),
                     const SizedBox(height: 12),
                     Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                     const SizedBox(height: 8),
                     Row(
                       children: [
                         Text(value, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                         const SizedBox(width: 4),
                         Expanded(child: Text(unit, style: TextStyle(color: Colors.white.withAlpha(_alpha(0.9)), fontSize: 12))),
                       ],
                     ),
                     const SizedBox(height: 8),
                     // short description inside the card
                     Text(description, style: TextStyle(color: Colors.white.withAlpha(_alpha(0.9)), fontSize: 12)),
                     const SizedBox(height: 8),
                     // subtle preview of the expanded info (keeps card compact)
                     if (info.isNotEmpty)
                       Flexible(
                         fit: FlexFit.loose,
                         child: Text(
                           // show a short preview inside the card (first line or so)
                           info.split('\n').first,
                           overflow: TextOverflow.ellipsis,
                           maxLines: 3,
                           style: TextStyle(color: Colors.white.withAlpha(_alpha(0.85)), fontSize: 11, height: 1.2),
                         ),
                       ),
                   ],
                 ),
               ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackgroundPattern(String pattern) {
    switch (pattern) {
      case 'carbon':
        return Positioned(
          right: -20,
          bottom: -10,
          child: Opacity(
            opacity: 0.1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Icon(Icons.co2, size: 40, color: Colors.white),
                Row(children: [Icon(Icons.cloud, size: 30, color: Colors.white), Icon(Icons.air, size: 40, color: Colors.white)]),
                Transform.rotate(angle: 0.2, child: Icon(Icons.eco, size: 50, color: Colors.white)),
              ],
            ),
          ),
        );
      case 'waves':
        return Positioned(
          right: -15,
          bottom: -15,
          child: Opacity(
            opacity: 0.1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Icon(Icons.waves, size: 40, color: Colors.white),
                Icon(Icons.waves, size: 40, color: Colors.white),
                Icon(Icons.beach_access, size: 35, color: Colors.white),
                Row(children: [Icon(Icons.water_drop, size: 20, color: Colors.white), Icon(Icons.water, size: 30, color: Colors.white)]),
              ],
            ),
          ),
        );
      case 'biodiversity':
        return Positioned(
          right: -15,
          bottom: -10,
          child: Opacity(
            opacity: 0.15,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Icon(Icons.pets, size: 30, color: Colors.white),
                Row(children: [Icon(Icons.cruelty_free, size: 25, color: Colors.white), Icon(Icons.bug_report, size: 25, color: Colors.white)]),
                Icon(Icons.forest, size: 40, color: Colors.white),
                Row(children: [Icon(Icons.grass, size: 30, color: Colors.white), Icon(Icons.spa, size: 25, color: Colors.white)]),
              ],
            ),
          ),
        );
      case 'marine':
        return Positioned(
          right: -20,
          bottom: -15,
          child: Opacity(
            opacity: 0.15,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Icon(Icons.water, size: 40, color: Colors.white),
                Row(children: [Icon(Icons.arrow_outward, size: 25, color: Colors.white), Icon(Icons.map, size: 30, color: Colors.white)]),
                Icon(Icons.sailing, size: 35, color: Colors.white),
              ],
            ),
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

// ProvinceCard (withAlpha used instead of withOpacity)
class ProvinceCard extends StatelessWidget {
  final String province;
  final int treeCount;
  final Color color;
  final Map<String, int> speciesByYear;
  final Map<String, List<String>>? speciesDetails;

  const ProvinceCard({
    super.key,
    required this.province,
    required this.treeCount,
    required this.color,
    required this.speciesByYear,
    this.speciesDetails,
  });

  @override
  Widget build(BuildContext context) {
    int totalSpecies = 0;
    speciesByYear.forEach((_, count) => totalSpecies += count);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color, color.withAlpha(_alpha(0.8))],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: color.withAlpha(_alpha(0.3)), blurRadius: 12, offset: const Offset(0, 6)),
          BoxShadow(color: Colors.black.withAlpha(_alpha(0.1)), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            // Summary dialog
            showDialog(
              context: context,
              builder: (ctx) {
                return AlertDialog(
                  title: Text('Mangrove Species in $province'),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Found $treeCount mangrove reports across years:', style: const TextStyle(fontWeight: FontWeight.w500)),
                        const SizedBox(height: 12),
                        ...speciesByYear.entries.map((entry) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(color: Colors.green.shade100, borderRadius: BorderRadius.circular(10)),
                                  child: Text('Year ${entry.key}', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green.shade800)),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    const Icon(Icons.eco, color: Colors.green, size: 16),
                                    const SizedBox(width: 8),
                                    Text('${entry.value} species identified', style: const TextStyle(fontSize: 15)),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }),
                        const SizedBox(height: 8),
                        const Text('These species contribute significantly to coastal protection and biodiversity in the region.', style: TextStyle(fontSize: 13, color: Colors.grey)),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
                    TextButton(
                      onPressed: () {
                        // Open detail dialog on top of summary (so closing detail returns to summary)
                        showDialog(
                          context: ctx,
                          builder: (detailCtx) {
                            final theme = Theme.of(detailCtx);
                            return AlertDialog(
                              title: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(color: theme.colorScheme.primary, borderRadius: BorderRadius.circular(8)),
                                    child: Icon(Icons.eco, color: theme.colorScheme.onPrimary),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(child: Text('Detailed of Identified Species', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold))),
                                  IconButton(icon: Icon(Icons.close, color: theme.iconTheme.color), onPressed: () => Navigator.pop(detailCtx)),
                                ],
                              ),
                              content: SizedBox(
                                width: double.maxFinite,
                                height: MediaQuery.of(detailCtx).size.height * 0.6,
                                child: SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('$province • Detailed list of identified species by year', style: theme.textTheme.bodySmall),
                                      const SizedBox(height: 12),
                                      if (speciesDetails == null || speciesDetails!.isEmpty)
                                        Center(child: Text('No detailed species data available.', style: theme.textTheme.bodyMedium))
                                      else
                                        for (final entry in speciesDetails!.entries)
                                          Padding(
                                            padding: const EdgeInsets.only(bottom: 12.0),
                                            child: Card(
                                              elevation: 2,
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                              child: Padding(
                                                padding: const EdgeInsets.all(12.0),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        Text('Year ${entry.key}', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                                                        Text('${entry.value.length} species', style: theme.textTheme.bodySmall),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 8),
                                                    Wrap(
                                                      spacing: 8,
                                                      runSpacing: 8,
                                                      children: entry.value.map((s) {
                                                        return Chip(
                                                          label: Text(s, style: theme.textTheme.bodyMedium),
                                                          backgroundColor: theme.colorScheme.primary.withAlpha(_alpha(0.12)),
                                                          avatar: Icon(Icons.local_florist, size: 18, color: theme.colorScheme.primary),
                                                        );
                                                      }).toList(),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                      child: const Text('View Details'),
                    ),
                  ],
                );
              },
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: Colors.white.withAlpha(_alpha(0.2)), borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.nature, color: Colors.white, size: 20),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: Colors.white.withAlpha(_alpha(0.2)), borderRadius: BorderRadius.circular(12)),
                      child: Text('${speciesByYear.length} YRS', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                    ),
                  ],
                ),

                // Content
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(province, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600, height: 1.2)),
                    const SizedBox(height: 4),
                    Text('Total: $totalSpecies Species', style: TextStyle(color: Colors.white.withAlpha(_alpha(0.8)), fontSize: 12, fontWeight: FontWeight.w400)),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('$treeCount', style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w700, height: 1)),
                            Text('Reports', style: TextStyle(color: Colors.white.withAlpha(_alpha(0.9)), fontSize: 12, fontWeight: FontWeight.w500)),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(color: Colors.white.withAlpha(_alpha(0.2)), borderRadius: BorderRadius.circular(8)),
                          child: const Icon(Icons.trending_up, color: Colors.white, size: 16),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// MangroveSpeciesChart - Using proper Area Chart with real data
class MangroveSpeciesChart extends StatefulWidget {
  const MangroveSpeciesChart({super.key});

  @override
  State<MangroveSpeciesChart> createState() => _MangroveSpeciesChartState();
}

class _MangroveSpeciesChartState extends State<MangroveSpeciesChart> {
  bool _showLegend = true; // State para sa legend visibility

  @override
  Widget build(BuildContext context) {
    // Real data gikan sa imong ProvinceCard
    const years = ['2017', '2018', '2019', '2020', '2021', '2022', '2023'];
    
    // Colors matching ProvinceCard - consistent sa whole app
    const cAgusan = Color.fromARGB(255, 191, 160, 5);
    const cSurigaoS = Color.fromARGB(255, 126, 202, 130);
    const cSurigaoN = Color.fromARGB(255, 40, 167, 33);
    const cDinagat = Color.fromARGB(255, 52, 152, 219);

    return Stack(
      children: [
        // Subtle background decoration
        Positioned(
          top: 20,
          right: 30,
          child: Opacity(
            opacity: 0.03,
            child: Icon(Icons.eco, size: 100, color: Colors.green.shade700),
          ),
        ),
        
        // Main Area Chart
        Padding(
          padding: const EdgeInsets.only(top: 16, right: 8, bottom: 8, left: 0),
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: true,
                drawHorizontalLine: true,
                horizontalInterval: 5,
                verticalInterval: 1,
                getDrawingHorizontalLine: (value) => FlLine(
                  color: Colors.green.shade200.withAlpha(_alpha(0.4)),
                  strokeWidth: 1,
                  dashArray: [5, 5],
                ),
                getDrawingVerticalLine: (value) => FlLine(
                  color: Colors.green.shade200.withAlpha(_alpha(0.4)),
                  strokeWidth: 1,
                  dashArray: [5, 5],
                ),
              ),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 5,
                    getTitlesWidget: (value, meta) {
                      if (value == 0 || value % 5 != 0) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Text(
                          '${value.toInt()}',
                          style: TextStyle(
                            color: Colors.green.shade800,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    },
                    reservedSize: 40,
                  ),
                  axisNameWidget: Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      'Species Count',
                      style: TextStyle(
                        color: Colors.green.shade700,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final int idx = value.toInt();
                      if (idx < 0 || idx >= years.length) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          years[idx],
                          style: TextStyle(
                            color: Colors.green.shade800,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    },
                    reservedSize: 30,
                  ),
                ),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(
                show: true,
                border: Border(
                  left: BorderSide(color: Colors.green.shade300, width: 2),
                  bottom: BorderSide(color: Colors.green.shade300, width: 2),
                  right: BorderSide.none,
                  top: BorderSide.none,
                ),
              ),
              minX: 0,
              maxX: 6, // 0-6 para sa 7 years (2017-2023)
              minY: 0,
              maxY: 30, // Max value based sa actual data
              lineBarsData: [
                // Surigao del Norte - Complete data (2019-2023)
                LineChartBarData(
                  spots: const [
                    FlSpot(2, 20), // 2019: 20 species
                    FlSpot(3, 17), // 2020: 17 species
                    FlSpot(4, 22), // 2021: 22 species
                    FlSpot(5, 29), // 2022: 29 species
                    FlSpot(6, 1),  // 2023: 1 species
                  ],
                  isCurved: true,
                  curveSmoothness: 0.35,
                  gradient: LinearGradient(
                    colors: [cSurigaoN, cSurigaoN.withAlpha(_alpha(0.8))],
                  ),
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, barData, index) =>
                        FlDotCirclePainter(
                      radius: 5,
                      color: Colors.white,
                      strokeColor: cSurigaoN,
                      strokeWidth: 2.5,
                    ),
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        cSurigaoN.withAlpha(_alpha(0.4)),
                        cSurigaoN.withAlpha(_alpha(0.1)),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                
                // Surigao del Sur - Growing trend (2017, 2021, 2022)
                LineChartBarData(
                  spots: const [
                    FlSpot(0, 9),  // 2017: 9 species
                    FlSpot(4, 13), // 2021: 13 species
                    FlSpot(5, 15), // 2022: 15 species
                  ],
                  isCurved: true,
                  curveSmoothness: 0.35,
                  gradient: LinearGradient(
                    colors: [cSurigaoS, cSurigaoS.withAlpha(_alpha(0.8))],
                  ),
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, barData, index) =>
                        FlDotCirclePainter(
                      radius: 5,
                      color: Colors.white,
                      strokeColor: cSurigaoS,
                      strokeWidth: 2.5,
                    ),
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        cSurigaoS.withAlpha(_alpha(0.4)),
                        cSurigaoS.withAlpha(_alpha(0.1)),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                
                // Dinagat Islands - Single data point (2021)
                LineChartBarData(
                  spots: const [
                    FlSpot(4, 14), // 2021: 14 species
                  ],
                  gradient: LinearGradient(
                    colors: [cDinagat, cDinagat.withAlpha(_alpha(0.8))],
                  ),
                  barWidth: 3,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, barData, index) =>
                        FlDotCirclePainter(
                      radius: 7, // Mas dako para mas visible
                      color: Colors.white,
                      strokeColor: cDinagat,
                      strokeWidth: 3,
                    ),
                  ),
                ),
                
                // Agusan del Norte - Single data point (2021)
                LineChartBarData(
                  spots: const [
                    FlSpot(4, 5), // 2021: 5 species
                  ],
                  gradient: LinearGradient(
                    colors: [cAgusan, cAgusan.withAlpha(_alpha(0.8))],
                  ),
                  barWidth: 3,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, barData, index) =>
                        FlDotCirclePainter(
                      radius: 7, // Mas dako para mas visible
                      color: Colors.white,
                      strokeColor: cAgusan,
                      strokeWidth: 3,
                    ),
                  ),
                ),
              ],
              lineTouchData: LineTouchData(
                enabled: true,
                touchTooltipData: LineTouchTooltipData(
                  tooltipPadding: const EdgeInsets.all(10),
                  getTooltipColor: (touchedSpot) {
                    switch (touchedSpot.barIndex) {
                      case 0: return cSurigaoN;
                      case 1: return cSurigaoS;
                      case 2: return cDinagat;
                      case 3: return cAgusan;
                      default: return Colors.grey;
                    }
                  },
                  getTooltipItems: (touchedSpots) {
                    return touchedSpots.map((spot) {
                      String province;
                      switch (spot.barIndex) {
                        case 0: province = 'Surigao del Norte'; break;
                        case 1: province = 'Surigao del Sur'; break;
                        case 2: province = 'Dinagat Islands'; break;
                        case 3: province = 'Agusan del Norte'; break;
                        default: province = 'Unknown';
                      }
                      
                      return LineTooltipItem(
                        '$province\n',
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                        children: [
                          TextSpan(
                            text: 'Year ${years[spot.x.toInt()]}\n',
                            style: const TextStyle(
                              fontWeight: FontWeight.normal,
                              fontSize: 11,
                            ),
                          ),
                          TextSpan(
                            text: '${spot.y.toInt()} species',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      );
                    }).toList();
                  },
                ),
              ),
            ),
          ),
        ),
        
        // Toggle-able Legend - dili na mag-cover sa data
        if (_showLegend)
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(_alpha(0.97)),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(_alpha(0.08)),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
                border: Border.all(
                  color: Colors.green.shade200,
                  width: 1.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Provinces',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade800,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: () => setState(() => _showLegend = false),
                        child: Icon(
                          Icons.close,
                          size: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  _buildLegendItem('Surigao del Norte', cSurigaoN),
                  _buildLegendItem('Surigao del Sur', cSurigaoS),
                  _buildLegendItem('Agusan del Norte', cAgusan),
                  _buildLegendItem('Dinagat Islands', cDinagat),
                ],
              ),
            ),
          ),
        
        // Show Legend Button (pag naka-hide)
        if (!_showLegend)
          Positioned(
            top: 0,
            right: 0,
            child: GestureDetector(
              onTap: () => setState(() => _showLegend = true),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.shade700,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(_alpha(0.1)),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.legend_toggle,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withAlpha(_alpha(0.3)),
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade800,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ActionButton (withAlpha used)
class ActionButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const ActionButton({super.key, required this.title, required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: color.withAlpha(_alpha(0.1)),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withAlpha(_alpha(0.3))),
          ),
          child: Column(children: [Icon(icon, color: color, size: 28), const SizedBox(height: 8), Text(title, style: TextStyle(color: color.withAlpha(_alpha(0.8)), fontWeight: FontWeight.bold))]),
        ),
      ),
    );
  }
}

// Helper para i-format ang info block (Quick facts) - now theme-aware
Widget _buildFormattedInfo(BuildContext context, String info) {
  final theme = Theme.of(context);
  final bool isDark = theme.brightness == Brightness.dark;

  // Updated: use current TextTheme properties (bodyMedium / bodySmall) instead of deprecated bodyText1 / caption
  final Color textColor = theme.textTheme.bodyMedium?.color ?? (isDark ? Colors.white : Colors.black);
  final Color secondaryColor = theme.textTheme.bodySmall?.color ?? textColor.withAlpha(_alpha(0.85));

  // Updated: avoid withOpacity (deprecated) and use withAlpha helper
  final Color bulletColor = theme.colorScheme.onSurface.withAlpha(_alpha(isDark ? 0.8 : 0.9));

  final lines = info.split('\n').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
  final List<Widget> widgets = [];

  for (final line in lines) {
    if (line.startsWith('-')) {
      // Bullet item
      final content = line.substring(1).trim();
      if (content.contains(':')) {
        final idx = content.indexOf(':');
        final key = content.substring(0, idx).trim();
        final val = content.substring(idx + 1).trim();
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  margin: const EdgeInsets.only(top: 6),
                  decoration: BoxDecoration(color: bulletColor, shape: BoxShape.circle),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(color: textColor),
                      children: [
                        TextSpan(text: '$key: ', style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
                        TextSpan(text: val, style: TextStyle(color: secondaryColor)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      } else {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  margin: const EdgeInsets.only(top: 6),
                  decoration: BoxDecoration(color: bulletColor, shape: BoxShape.circle),
                ),
                const SizedBox(width: 8),
                Expanded(child: Text(content, style: TextStyle(color: textColor))),
              ],
            ),
          ),
        );
      }
    } else {
      final idx = line.indexOf(':');
      if (idx != -1) {
        final key = line.substring(0, idx).trim();
        final val = line.substring(idx + 1).trim();
        final keyLower = key.toLowerCase();
        final isHighlight = keyLower == 'takeaway' || keyLower == 'note' || keyLower == 'practical tip';
        final TextStyle keyStyle = TextStyle(fontWeight: FontWeight.bold, color: textColor);
        final TextStyle valStyle = (keyLower == 'takeaway' || keyLower == 'note')
            ? TextStyle(fontStyle: FontStyle.italic, color: secondaryColor)
            : TextStyle(color: secondaryColor);

        widgets.add(
          Padding(
            padding: EdgeInsets.only(top: isHighlight ? 12.0 : 0.0, bottom: 8.0),
            child: RichText(
              text: TextSpan(
                style: TextStyle(color: textColor),
                children: [
                  TextSpan(text: '$key: ', style: keyStyle),
                  TextSpan(text: val, style: valStyle),
                ],
              ),
            ),
          ),
        );
      } else {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(line, style: TextStyle(color: textColor)),
          ),
        );
      }
    }
  }

  return Column(crossAxisAlignment: CrossAxisAlignment.start, children: widgets);
}
