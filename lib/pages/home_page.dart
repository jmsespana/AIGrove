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
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        // ignore: deprecated_member_use
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 2,
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const TreePlantingChart(),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            province,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            '$treeCount',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Text(
            'Mangrove Report',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class TreePlantingChart extends StatelessWidget {
  const TreePlantingChart({super.key});

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: true),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${value.toInt()}',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                );
              },
              reservedSize: 40,
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                const years = ['2020', '2021', '2022', '2023', '2024', '2025'];
                if (value.toInt() < 0 || value.toInt() >= years.length) {
                  return const Text('');
                }
                return Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Text(
                    years[value.toInt()],
                    style: const TextStyle(
                      color: Colors.grey,
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
        borderData: FlBorderData(show: true),
        minX: 0,
        maxX: 5, // Changed to match number of years (6 years)
        minY: 0,
        maxY: 2000, // Adjusted based on your data range
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
            color: Colors.green,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(radius: 6),
            ),
            belowBarData: BarAreaData(
              show: true,
              // ignore: deprecated_member_use
              color: Colors.green.withOpacity(0.2),
            ),
          ),
        ],
      ),
    );
  }
}
