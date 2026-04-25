import 'dart:async';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:unityhub_mobile/core/theme/theme.dart';
import 'package:unityhub_mobile/shared/widgets/adaptive/data_card.dart';
import 'package:unityhub_mobile/shared/widgets/adaptive/unityhub_button.dart';

class AnalyticsDashboardScreen extends StatefulWidget {
  const AnalyticsDashboardScreen({super.key});

  @override
  State<AnalyticsDashboardScreen> createState() =>
      _AnalyticsDashboardScreenState();
}

class _AnalyticsDashboardScreenState extends State<AnalyticsDashboardScreen> {
  final _activityController = ScrollController();
  final List<String> _activityItems = [
    'Volunteer Rahul completed Beach Cleanup - ✅ 20 VIT',
    'Volunteer Sneha completed Tree Plantation - ✅ 25 VIT',
    'Volunteer Arjun completed Food Drive - ✅ 15 VIT',
  ];
  Timer? _timer;
  String _heatmapMode = 'Task Density';

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 7), (_) {
      if (!mounted) return;
      setState(() {
        _activityItems.add(
          'Volunteer #${_activityItems.length + 1} completed Task #${_activityItems.length + 2} - ✅ ${10 + _activityItems.length % 30} VIT',
        );
        if (_activityItems.length > 50) {
          _activityItems.removeAt(0);
        }
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_activityController.hasClients) {
          _activityController.animateTo(
            _activityController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _activityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            SizedBox(
              width: 320,
              child: DataCard(
                title: 'Total Verified Hours',
                value: '847h',
                trend: '+8.2% (7d)',
                sparklineData: const [2, 4, 3, 5, 6, 7, 8],
              ),
            ),
            SizedBox(
              width: 320,
              child: DataCard(
                title: 'Active Volunteers',
                value: '128',
                trend: '+11.5% (7d)',
                sparklineData: const [2, 2.5, 3.2, 3.5, 3.8, 4.1, 4.6],
              ),
            ),
            SizedBox(
              width: 320,
              child: DataCard(
                title: 'Tasks Completed',
                value: '291',
                trend: '+5.1% (7d)',
                sparklineData: const [3, 5, 4, 6, 7, 7.2, 8.1],
              ),
            ),
            SizedBox(
              width: 320,
              child: DataCard(
                title: 'VIT Minted',
                value: '15,420',
                trend: '+9.4% (7d)',
                sparklineData: const [1, 1.5, 2.2, 2.5, 3.1, 3.6, 4.0],
              ),
            ),
          ],
        ).animate().fadeIn(duration: 350.ms).slideY(begin: 0.07),
        const SizedBox(height: 20),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 6, child: _buildFunnelChart()),
            const SizedBox(width: 16),
            Expanded(flex: 4, child: _buildLiveActivityFeed()),
          ],
        ),
        const SizedBox(height: 20),
        _buildHeatmapCard(),
      ],
    );
  }

  Widget _buildFunnelChart() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Verification Funnel',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 260,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 100,
                  borderData: FlBorderData(show: false),
                  gridData: const FlGridData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, _) {
                          const labels = [
                            'Submitted',
                            'AI Processing',
                            'Approved',
                            'Token Minted',
                          ];
                          final index = value.toInt();
                          if (index < 0 || index >= labels.length)
                            return const SizedBox.shrink();
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              labels[index],
                              style: const TextStyle(fontSize: 11),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  barGroups: [
                    BarChartGroupData(
                      x: 0,
                      barRods: [
                        BarChartRodData(
                          toY: 100,
                          color: const Color(0xFFF59E0B),
                          width: 30,
                        ),
                      ],
                    ),
                    BarChartGroupData(
                      x: 1,
                      barRods: [
                        BarChartRodData(
                          toY: 79,
                          color: const Color(0xFFF59E0B),
                          width: 30,
                        ),
                      ],
                    ),
                    BarChartGroupData(
                      x: 2,
                      barRods: [
                        BarChartRodData(
                          toY: 67,
                          color: AppColors.primary500,
                          width: 30,
                        ),
                      ],
                    ),
                    BarChartGroupData(
                      x: 3,
                      barRods: [
                        BarChartRodData(
                          toY: 58,
                          color: AppColors.primary600,
                          width: 30,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveActivityFeed() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Live Activity Feed',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 260,
              child: ListView.builder(
                controller: _activityController,
                itemCount: _activityItems.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    dense: true,
                    leading: const CircleAvatar(
                      radius: 12,
                      child: Icon(Icons.person, size: 14),
                    ),
                    title: Text(
                      _activityItems[index],
                      style: const TextStyle(fontSize: 13),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeatmapCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Impact Heatmap',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                ),
                UnityHubButton(
                  label: 'Task Density',
                  onPressed: () =>
                      setState(() => _heatmapMode = 'Task Density'),
                ),
                const SizedBox(width: 8),
                UnityHubButton(
                  label: 'Volunteer Coverage',
                  onPressed: () =>
                      setState(() => _heatmapMode = 'Volunteer Coverage'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              height: 300,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: const LinearGradient(
                  colors: [Color(0xFFE6F9F1), Color(0xFFC7F2E2)],
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                'Map Layer: $_heatmapMode\n(Google Maps Web integration point)',
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
