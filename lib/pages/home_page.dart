import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Dashboard welcome header
                const Text(
                  'Welcome to AIGrove Dashboard',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'Explore environmental impact of mangroves',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
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
                        title: 'Carbon Capture',
                        value: '25.3',
                        unit: 'tons/hectare',
                        description: 'Annual carbon sequestration',
                        icon: Icons.co2,
                        color: Colors.teal,
                        bgPattern: 'carbon',
                      ),
                      SizedBox(width: 16),
                      EnvironmentalImpactCard(
                        title: 'Coastal Protection',
                        value: '70%',
                        unit: 'wave energy',
                        description: 'Reduction in coastal erosion',
                        icon: Icons.waves,
                        color: Colors.blue,
                        bgPattern: 'waves',
                      ),
                      SizedBox(width: 16),
                      EnvironmentalImpactCard(
                        title: 'Biodiversity',
                        value: '1,300+',
                        unit: 'species',
                        description: 'Supported by mangrove ecosystems',
                        icon: Icons.pets,
                        color: Colors.amber,
                        bgPattern: 'biodiversity',
                      ),
                      SizedBox(width: 16),
                      EnvironmentalImpactCard(
                        title: 'Marine Expansion',
                        value: '12.5',
                        unit: 'km²/year',
                        description: 'Potential growth zones',
                        icon: Icons.water,
                        color: Colors.indigo,
                        bgPattern: 'marine',
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
                  children: const [
                    ProvinceCard(
                      province: 'Agusan del Norte',
                      treeCount: 5,
                      color: Color.fromARGB(255, 191, 160, 5),
                      speciesByYear: {'2021': 5},
                    ),
                    ProvinceCard(
                      province: 'Surigao del Sur',
                      treeCount: 37,
                      color: Color.fromARGB(255, 126, 202, 130),
                      speciesByYear: {'2022': 15, '2021': 13, '2017': 9},
                    ),
                    ProvinceCard(
                      province: 'Surigao del Norte',
                      treeCount: 89,
                      color: Color.fromARGB(255, 40, 167, 33),
                      speciesByYear: {
                        '2023': 1,
                        '2022': 29,
                        '2021': 22,
                        '2020': 17,
                        '2019': 20,
                      },
                    ),
                    ProvinceCard(
                      province: 'Dinagat Islands',
                      treeCount: 14,
                      color: Color.fromARGB(255, 52, 152, 219),
                      speciesByYear: {'2021': 14},
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Chart Title
                const Text(
                  'Mangrove Species by Year',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                // Line Chart
                Container(
                  height: 300,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.green.shade50,
                        // ignore: deprecated_member_use
                        Colors.blue.shade50.withOpacity(0.8),
                        // ignore: deprecated_member_use
                        Colors.white.withOpacity(0.9),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        // ignore: deprecated_member_use
                        color: Colors.green.shade200.withOpacity(0.3),
                        spreadRadius: 0,
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                      BoxShadow(
                        // ignore: deprecated_member_use
                        color: Colors.black.withOpacity(0.05),
                        spreadRadius: 0,
                        blurRadius: 20,
                        offset: const Offset(0, 5),
                      ),
                    ],
                    border: Border.all(
                      // ignore: deprecated_member_use
                      color: Colors.green.shade100.withOpacity(0.5),
                      width: 1,
                    ),
                  ),
                  child: const MangroveSpeciesChart(),
                ),

                // Suggested additional element: Quick Actions
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
                        onTap: () {
                          // Navigation logic to add new report
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ActionButton(
                        title: 'Education',
                        icon: Icons.school,
                        color: Colors.orange,
                        onTap: () {
                          // Navigation to educational content
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ActionButton(
                        title: 'Initiatives',
                        icon: Icons.eco,
                        color: Colors.blue,
                        onTap: () {
                          // Navigation to initiatives page
                        },
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
}

// Updated environmental impact cards with topic-specific designs
class EnvironmentalImpactCard extends StatelessWidget {
  final String title;
  final String value;
  final String unit;
  final String description;
  final IconData icon;
  final Color color;
  final String bgPattern;

  const EnvironmentalImpactCard({
    super.key,
    required this.title,
    required this.value,
    required this.unit,
    required this.description,
    required this.icon,
    required this.color,
    required this.bgPattern,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          // Magbukas ng detailed view or dialog para sa card
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(title),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('$value $unit'),
                  const SizedBox(height: 8),
                  Text(description),
                  const SizedBox(height: 16),
                  const Text(
                    'Mangroves play a crucial role in environmental conservation and provide numerous ecosystem services.',
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // Pwede mag-navigate sa detailed page
                  },
                  child: const Text('Learn More'),
                ),
              ],
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 180,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                // ignore: deprecated_member_use
                color.withOpacity(0.8),
                color,
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                // ignore: deprecated_member_use
                color: color.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Add background pattern based on topic
              _buildBackgroundPattern(bgPattern),

              // Main content
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      // ignore: deprecated_member_use
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: Colors.white, size: 24),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        value,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        unit,
                        style: TextStyle(
                          // ignore: deprecated_member_use
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: TextStyle(
                      // ignore: deprecated_member_use
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to build background pattern based on the topic
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
                Row(
                  children: [
                    Icon(Icons.cloud, size: 30, color: Colors.white),
                    Icon(Icons.air, size: 40, color: Colors.white),
                  ],
                ),
                Transform.rotate(
                  angle: 0.2,
                  child: Icon(Icons.eco, size: 50, color: Colors.white),
                ),
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
                Row(
                  children: [
                    Icon(Icons.water_drop, size: 20, color: Colors.white),
                    Icon(Icons.water, size: 30, color: Colors.white),
                  ],
                ),
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
                Row(
                  children: [
                    Icon(Icons.cruelty_free, size: 25, color: Colors.white),
                    Icon(Icons.bug_report, size: 25, color: Colors.white),
                  ],
                ),
                Icon(Icons.forest, size: 40, color: Colors.white),
                Row(
                  children: [
                    Icon(Icons.grass, size: 30, color: Colors.white),
                    Icon(Icons.spa, size: 25, color: Colors.white),
                  ],
                ),
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
                Row(
                  children: [
                    Icon(Icons.arrow_outward, size: 25, color: Colors.white),
                    Icon(Icons.map, size: 30, color: Colors.white),
                  ],
                ),
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

// Updated ProvinceCard class to show species by year
class ProvinceCard extends StatelessWidget {
  final String province;
  final int treeCount;
  final Color color;
  final Map<String, int> speciesByYear;

  const ProvinceCard({
    super.key,
    required this.province,
    required this.treeCount,
    required this.color,
    required this.speciesByYear,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate total species count
    int totalSpecies = 0;
    speciesByYear.forEach((year, count) => totalSpecies += count);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          // ignore: deprecated_member_use
          colors: [color, color.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: color.withOpacity(0.3),
            spreadRadius: 0,
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background leaf icon
          Positioned(
            bottom: -20,
            right: -20,
            child: Transform.rotate(
              angle: 0.2, // Para slight angle ang leaf
              child: Icon(
                Icons.eco,
                size: 120,
                // ignore: deprecated_member_use
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          // Additional background leaf para mas decorative
          Positioned(
            top: -10,
            left: -15,
            child: Transform.rotate(
              angle: -0.3,
              child: Icon(
                Icons.local_florist,
                size: 80,
                // ignore: deprecated_member_use
                color: Colors.white.withOpacity(0.08),
              ),
            ),
          ),
          // Main content
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                // I-display ang dialog nga naa ang species sa province
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Mangrove Species in $province'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Found $treeCount mangrove reports across years:',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 16),

                        // Show species by year
                        ...speciesByYear.entries.map((entry) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade100,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    'Year ${entry.key}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green.shade800,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.eco,
                                      color: Colors.green,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${entry.value} species identified',
                                      style: const TextStyle(fontSize: 15),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }),

                        const SizedBox(height: 12),
                        const Text(
                          'These species contribute significantly to coastal protection and biodiversity in the region.',
                          style: TextStyle(fontSize: 13, color: Colors.grey),
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Close'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          // Pwede mag-navigate sa detailed page about sa province later
                        },
                        child: const Text('View Details'),
                      ),
                    ],
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            // ignore: deprecated_member_use
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.nature,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            // ignore: deprecated_member_use
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${speciesByYear.length} YRS',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Content section
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          province,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Total: $totalSpecies Species',
                          style: TextStyle(
                            // ignore: deprecated_member_use
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '$treeCount',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 28,
                                    fontWeight: FontWeight.w700,
                                    height: 1,
                                  ),
                                ),
                                Text(
                                  'Reports',
                                  style: TextStyle(
                                    // ignore: deprecated_member_use
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                // ignore: deprecated_member_use
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.trending_up,
                                color: Colors.white,
                                size: 16,
                              ),
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
        ],
      ),
    );
  }
}

// New chart to display mangrove species by year
class MangroveSpeciesChart extends StatelessWidget {
  const MangroveSpeciesChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background decorations
        Positioned(
          top: 20,
          right: 30,
          child: Transform.rotate(
            angle: 0.3,
            child: Icon(
              Icons.eco,
              size: 60,
              // ignore: deprecated_member_use
              color: Colors.green.shade300.withOpacity(0.15),
            ),
          ),
        ),
        Positioned(
          bottom: 40,
          left: 20,
          child: Transform.rotate(
            angle: -0.4,
            child: Icon(
              Icons.local_florist,
              size: 80,
              // ignore: deprecated_member_use
              color: Colors.green.shade400.withOpacity(0.12),
            ),
          ),
        ),
        // Additional decorations
        Positioned(
          bottom: 100,
          right: 80,
          child: Transform.rotate(
            angle: -0.2,
            child: Icon(
              Icons.grass,
              size: 35,
              // ignore: deprecated_member_use
              color: Colors.green.shade600.withOpacity(0.1),
            ),
          ),
        ),

        // Chart content
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: true,
                drawHorizontalLine: true,
                horizontalInterval: 5,
                verticalInterval: 1,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    // ignore: deprecated_member_use
                    color: Colors.green.shade300.withOpacity(0.4),
                    strokeWidth: 1,
                  );
                },
                getDrawingVerticalLine: (value) {
                  return FlLine(
                    // ignore: deprecated_member_use
                    color: Colors.green.shade300.withOpacity(0.4),
                    strokeWidth: 1,
                  );
                },
              ),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        '${value.toInt()}',
                        style: TextStyle(
                          color: Colors.green.shade800,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    },
                    reservedSize: 40,
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      const years = [
                        '2017',
                        '2018',
                        '2019',
                        '2020',
                        '2021',
                        '2022',
                        '2023',
                      ];
                      if (value.toInt() < 0 || value.toInt() >= years.length) {
                        return const Text('');
                      }
                      return Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Text(
                          years[value.toInt()],
                          style: TextStyle(
                            color: Colors.green.shade800,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    },
                    reservedSize: 30,
                  ),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              borderData: FlBorderData(
                show: true,
                border: Border.all(
                  // ignore: deprecated_member_use
                  color: Colors.green.shade400.withOpacity(0.6),
                  width: 2,
                ),
              ),
              minX: 0,
              maxX: 6,
              minY: 0,
              maxY: 30,
              lineBarsData: [
                // Surigao del Norte data
                LineChartBarData(
                  spots: const [
                    FlSpot(2, 20), // 2019: 20
                    FlSpot(3, 17), // 2020: 17
                    FlSpot(4, 22), // 2021: 22
                    FlSpot(5, 29), // 2022: 29
                    FlSpot(6, 1), // 2023: 1
                  ],
                  isCurved: true,
                  gradient: LinearGradient(
                    colors: [Colors.green.shade700, Colors.green.shade800],
                  ),
                  barWidth: 4,
                  isStrokeCapRound: true,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, barData, index) =>
                        FlDotCirclePainter(
                          radius: 6,
                          color: Colors.white,
                          strokeColor: Colors.green.shade700,
                          strokeWidth: 3,
                        ),
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        // ignore: deprecated_member_use
                        Colors.green.shade400.withOpacity(0.3),
                        // ignore: deprecated_member_use
                        Colors.green.shade200.withOpacity(0.15),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                // Surigao del Sur data
                LineChartBarData(
                  spots: const [
                    FlSpot(0, 9), // 2017: 9
                    FlSpot(4, 13), // 2021: 13
                    FlSpot(5, 15), // 2022: 15
                  ],
                  isCurved: true,
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade600, Colors.blue.shade700],
                  ),
                  barWidth: 4,
                  isStrokeCapRound: true,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, barData, index) =>
                        FlDotCirclePainter(
                          radius: 6,
                          color: Colors.white,
                          strokeColor: Colors.blue.shade600,
                          strokeWidth: 3,
                        ),
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        // ignore: deprecated_member_use
                        Colors.blue.shade400.withOpacity(0.3),
                        // ignore: deprecated_member_use
                        Colors.blue.shade200.withOpacity(0.15),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                // Agusan del Norte data
                LineChartBarData(
                  spots: const [
                    FlSpot(4, 5), // 2021: 5
                  ],
                  isCurved: true,
                  gradient: LinearGradient(
                    colors: [Colors.amber.shade700, Colors.amber.shade800],
                  ),
                  barWidth: 4,
                  isStrokeCapRound: true,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, barData, index) =>
                        FlDotCirclePainter(
                          radius: 6,
                          color: Colors.white,
                          strokeColor: Colors.amber.shade700,
                          strokeWidth: 3,
                        ),
                  ),
                ),
                // Dinagat Islands data
                LineChartBarData(
                  spots: const [
                    FlSpot(4, 14), // 2021: 14
                  ],
                  isCurved: true,
                  gradient: LinearGradient(
                    colors: [Colors.purple.shade500, Colors.purple.shade600],
                  ),
                  barWidth: 4,
                  isStrokeCapRound: true,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, barData, index) =>
                        FlDotCirclePainter(
                          radius: 6,
                          color: Colors.white,
                          strokeColor: Colors.purple.shade500,
                          strokeWidth: 3,
                        ),
                  ),
                ),
              ],
              lineTouchData: LineTouchData(
                // Mag-create og basic tooltip first kay naproblema ta sa parameters
                enabled: true,
                touchTooltipData: LineTouchTooltipData(
                  // Tangtangon nato ang problematic parameters
                  // tooltipBgColor: Colors.white, <- KINI ANG PROBLEM
                  getTooltipItems: (touchedSpots) {
                    return touchedSpots.map((touchedSpot) {
                      String provinceName;
                      Color color;

                      switch (touchedSpot.barIndex) {
                        case 0:
                          provinceName = 'Surigao del Norte';
                          color = Colors.green.shade700;
                          break;
                        case 1:
                          provinceName = 'Surigao del Sur';
                          color = Colors.blue.shade600;
                          break;
                        case 2:
                          provinceName = 'Agusan del Norte';
                          color = Colors.amber.shade700;
                          break;
                        case 3:
                          provinceName = 'Dinagat Islands';
                          color = Colors.purple.shade500;
                          break;
                        default:
                          provinceName = 'Unknown';
                          color = Colors.grey;
                      }

                      const years = [
                        '2017',
                        '2018',
                        '2019',
                        '2020',
                        '2021',
                        '2022',
                        '2023',
                      ];

                      return LineTooltipItem(
                        '$provinceName\n',
                        TextStyle(color: color, fontWeight: FontWeight.bold),
                        children: [
                          TextSpan(
                            text: '${years[touchedSpot.x.toInt()]}: ',
                            style: const TextStyle(
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                          TextSpan(
                            text: '${touchedSpot.y.toInt()} species',
                            style: const TextStyle(fontWeight: FontWeight.bold),
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

        // Legend for the chart
        Positioned(
          top: 10,
          right: 10,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              // ignore: deprecated_member_use
              color: Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLegendItem('Surigao del Norte', Colors.green.shade700),
                _buildLegendItem('Surigao del Sur', Colors.blue.shade600),
                _buildLegendItem('Agusan del Norte', Colors.amber.shade700),
                _buildLegendItem('Dinagat Islands', Colors.purple.shade500),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade800,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// New widget for action buttons
class ActionButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const ActionButton({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

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
            // ignore: deprecated_member_use
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            // ignore: deprecated_member_use
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  // ignore: deprecated_member_use
                  color: color.withOpacity(0.8),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
