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
        // Remove AppBar and drawer
        body: SafeArea(
          // Add SafeArea to handle status bar
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Province Statistics Grid
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.85, // I-adjust para fit ang content
                  children: const [
                    ProvinceCard(
                      province: 'Agusan del Sur',
                      treeCount: 600,
                      color: Color.fromARGB(255, 227, 230, 39),
                    ),
                    ProvinceCard(
                      province: 'Agusan del Norte',
                      treeCount: 987,
                      color: Color.fromARGB(255, 191, 160, 5),
                    ),
                    ProvinceCard(
                      province: 'Surigao del Sur',
                      treeCount: 1503,
                      color: Color.fromARGB(255, 126, 202, 130),
                    ),
                    ProvinceCard(
                      province: 'Surigao del Norte',
                      treeCount: 1845,
                      color: Color.fromARGB(255, 40, 167, 33),
                    ),
                    ProvinceCard(
                      province: 'Dinagat Islands',
                      treeCount: 1200,
                      color: Color.fromARGB(255, 52, 152, 219),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Chart Title
                const Text(
                  'Mangroves Progress',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                // Line Chart
                Container(
                  height: 300,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    // Remove ang plain white background
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
                    borderRadius: BorderRadius.circular(20), // Mas rounded
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
                    // I-add ang border para mas defined
                    border: Border.all(
                      // ignore: deprecated_member_use
                      color: Colors.green.shade100.withOpacity(0.5),
                      width: 1,
                    ),
                  ),
                  child: const MangroveProgressChart(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ProvinceCard extends StatelessWidget {
  final String province;
  final int treeCount;
  final Color color;

  const ProvinceCard({
    super.key,
    required this.province,
    required this.treeCount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
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
                // I-add ang navigation logic diri later
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
                          child: const Text(
                            'ACTIVE',
                            style: TextStyle(
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
                          'Mangrove Species',
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

class MangroveProgressChart extends StatelessWidget {
  const MangroveProgressChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background leaf decorations - i-adjust ang opacity para di masyadong prominent
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
        Positioned(
          top: 80,
          left: 50,
          child: Transform.rotate(
            angle: 0.6,
            child: Icon(
              Icons.nature,
              size: 40,
              // ignore: deprecated_member_use
              color: Colors.green.shade500.withOpacity(0.15),
            ),
          ),
        ),
        // Additional small leaves para mas decorative
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
        // Main chart content
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: true,
                drawHorizontalLine: true,
                horizontalInterval: 400,
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
                        '2020',
                        '2021',
                        '2022',
                        '2023',
                        '2024',
                        '2025',
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
              maxX: 5,
              minY: 0,
              maxY: 2000,
              lineBarsData: [
                LineChartBarData(
                  spots: [
                    const FlSpot(0, 600), // 2020
                    const FlSpot(1, 987), // 2021
                    const FlSpot(2, 1503), // 2022
                    const FlSpot(3, 1845), // 2023
                    const FlSpot(4, 1920), // 2024
                    const FlSpot(5, 1980), // 2025
                  ],
                  isCurved: true,
                  gradient: LinearGradient(
                    colors: [
                      Colors.green.shade500,
                      Colors.green.shade700,
                      Colors.green.shade900,
                    ],
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
              ],
            ),
          ),
        ),
      ],
    );
  }
}
