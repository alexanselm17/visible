import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:visible/model/product_model.dart';

class ProductAnalyticsPage extends StatefulWidget {
  final Datum product;

  const ProductAnalyticsPage({
    super.key,
    required this.product,
  });

  static const routeName = '/product-analytics';

  @override
  State<ProductAnalyticsPage> createState() => _ProductAnalyticsPageState();
}

class _ProductAnalyticsPageState extends State<ProductAnalyticsPage> {
  List<BarChartGroupData> generateViewsData() {
    List<BarChartGroupData> barGroups = [];

    final screenshots = widget.product.allScreenshots;

    if (screenshots == null || screenshots.isEmpty) return barGroups;

    for (int i = 0; i < screenshots.length; i++) {
      final views = screenshots[i]['views'] ?? 0;
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: views.toDouble(),
              gradient: const LinearGradient(
                colors: [
                  Colors.white,
                  Colors.white70,
                ],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
              width: 16,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
            ),
          ],
        ),
      );
    }

    return barGroups;
  }

  Widget _buildViewsBarChart() {
    List<BarChartGroupData> barGroups = generateViewsData();

    if (barGroups.isEmpty) {
      return Container(
        height: 250,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1F2937),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF374151), width: 1),
        ),
        child: const Center(
          child: Text(
            'No data available',
            style: TextStyle(color: Colors.white70),
          ),
        ),
      );
    }

    double maxY = barGroups
        .map((group) => group.barRods.first.toY)
        .reduce((a, b) => a > b ? a : b);

    return Container(
      height: 280,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2937),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF374151), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your trend',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: BarChart(
              BarChartData(
                maxY: maxY * 1.2,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    tooltipBgColor: const Color(0xFF374151),
                    tooltipRoundedRadius: 8,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        '${rod.toY.round()} views',
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        int index = value.toInt();
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            'SS ${index + 1}',
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 10,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: maxY / 4,
                      reservedSize: 42,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        return Text(
                          value.toInt().toString(),
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 10,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(color: const Color(0xFF374151), width: 1),
                ),
                barGroups: barGroups,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxY / 4,
                  getDrawingHorizontalLine: (value) {
                    return const FlLine(
                      color: Color(0xFF374151),
                      strokeWidth: 1,
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards() {
    int totalViews = widget.product.allScreenshots!.last['views'] ?? 0;
    int totalScreenshots = widget.product.screenshotCount ?? 0;
    double avgViewsPerScreenshot =
        totalScreenshots > 0 ? totalViews / totalScreenshots : 0;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Total views',
            totalViews.toString(),
            Icons.visibility,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Total reports',
            totalScreenshots.toString(),
            Icons.smartphone,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Average views',
            avgViewsPerScreenshot.toStringAsFixed(1),
            Icons.trending_up,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 250,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white, width: 0.5),
            color: Colors.white,
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                  color: Colors.grey.shade300,
                  width: 1.0), // Added border around image
              image: DecorationImage(
                image: NetworkImage(widget.product.imageUrl!),
                fit: BoxFit.cover,
                onError: (exception, stackTrace) =>
                    const Icon(Icons.image_not_supported),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.green,
            borderRadius: BorderRadius.circular(5),
          ),
          child: const Text(
            'COMPLETED',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Text(
              'Ksh ${widget.product.reward}',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'EARNED',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDateCards() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                const Icon(Icons.calendar_today, color: Colors.white, size: 24),
                const SizedBox(height: 8),
                const Text(
                  'Created',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.product.createdAt != null
                      ? '${widget.product.createdAt!.day}/${widget.product.createdAt!.month}/${widget.product.createdAt!.year}'
                      : 'N/A',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                const Icon(Icons.event_available,
                    color: Colors.white, size: 24),
                const SizedBox(height: 8),
                const Text(
                  'Valid until',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.product.validUntil != null
                      ? '${widget.product.validUntil!.day}/${widget.product.validUntil!.month}/${widget.product.validUntil!.year}'
                      : 'N/A',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProductHeader()
                  .animate()
                  .fadeIn(
                    duration: 400.ms,
                  )
                  .slideY(
                    begin: -0.2,
                    duration: 400.ms,
                    curve: Curves.easeOut,
                  ),

              const SizedBox(height: 20),

              // Stats Cards
              _buildStatsCards().animate().fadeIn(
                    duration: 500.ms,
                    delay: 200.ms,
                  ),

              const SizedBox(height: 20),

              // Date Cards
              _buildDateCards().animate().fadeIn(
                    duration: 500.ms,
                    delay: 300.ms,
                  ),

              const SizedBox(height: 20),

              // Views Chart
              _buildViewsBarChart().animate().slideY(
                    begin: 0.3,
                    duration: 500.ms,
                    delay: 400.ms,
                    curve: Curves.easeOut,
                  ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
