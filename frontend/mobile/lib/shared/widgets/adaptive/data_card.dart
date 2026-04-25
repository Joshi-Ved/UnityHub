import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:unityhub_mobile/core/theme/theme.dart';

class DataCard extends StatelessWidget {
  const DataCard({
    super.key,
    required this.title,
    required this.value,
    required this.trend,
    required this.sparklineData,
    this.accentColor = AppColors.primary500,
  });

  final String title;
  final String value;
  final String trend;
  final List<double> sparklineData;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
        border: Border(left: BorderSide(color: accentColor, width: 4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(trend, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          const SizedBox(height: 10),
          SizedBox(height: 32, child: _MiniLineChart(data: sparklineData, color: accentColor)),
        ],
      ),
    );
  }
}

class _MiniLineChart extends StatelessWidget {
  const _MiniLineChart({required this.data, required this.color});

  final List<double> data;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        lineBarsData: [
          LineChartBarData(
            spots: [
              for (var i = 0; i < data.length; i++) FlSpot(i.toDouble(), data[i]),
            ],
            isCurved: true,
            barWidth: 2,
            color: color,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(show: false),
          ),
        ],
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(show: false),
        lineTouchData: const LineTouchData(enabled: false),
      ),
    );
  }
}
