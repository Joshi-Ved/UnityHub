import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:unityhub_mobile/core/theme/theme.dart';
import 'package:unityhub_mobile/features/admin/dashboard/dashboard_view_model.dart';
import 'package:go_router/go_router.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(adminDashboardProvider);

    return dashboardAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(title: const Text('NGO Analytics Dashboard')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('Failed to load dashboard: $error', textAlign: TextAlign.center),
          ),
        ),
      ),
      data: (dashboardData) {
        final stats = dashboardData.stats;
        final activityLogs = dashboardData.activity;
        final topVolunteers = dashboardData.leaderboard;

    return Scaffold(
      appBar: AppBar(
        title: const Text('NGO Analytics Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.manage_search),
            onPressed: () => context.go('/admin/tasks'),
            tooltip: 'Task Management',
          ),
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () => context.go('/admin/reports'),
            tooltip: 'ESG Reports',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // KPI Row
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildKPICard(context, 'Verified Hours', '${stats.verifiedHours}', Icons.timer),
                  _buildKPICard(context, 'Active Volunteers', '${stats.activeVolunteers}', Icons.people),
                  _buildKPICard(context, 'Tasks Completed', '${stats.tasksCompleted}', Icons.task_alt),
                  _buildKPICard(context, 'VIT Minted', '${stats.vitMinted}', Icons.generating_tokens),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
                // Funnel Chart
                Text('Verification Funnel', style: Theme.of(context).textTheme.headlineLarge),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      barGroups: [
                        BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 100, color: AppColors.primary200, width: 30)]),
                        BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 80, color: AppColors.primary400, width: 30)]),
                        BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 70, color: AppColors.primary500, width: 30)]),
                        BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 65, color: AppColors.primary700, width: 30)]),
                      ],
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              const titles = ['Submitted', 'AI Processed', 'Approved', 'Minted'];
                              final index = value.toInt();
                              if (index < 0 || index >= titles.length) return const SizedBox.shrink();
                              return Text(titles[index], style: const TextStyle(fontSize: 10));
                            },
                          ),
                        ),
                        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(show: false),
                      gridData: const FlGridData(show: false),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Live Activity Feed & Leaderboard
                LayoutBuilder(
                  builder: (context, constraints) {
                    // Responsive layout for wide vs narrow screens
                    if (constraints.maxWidth > 800) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: _buildActivityFeed(context, activityLogs)),
                          const SizedBox(width: 24),
                          Expanded(child: _buildLeaderboard(context, topVolunteers)),
                        ],
                      );
                    } else {
                      return Column(
                        children: [
                          _buildActivityFeed(context, activityLogs),
                          const SizedBox(height: 24),
                          _buildLeaderboard(context, topVolunteers),
                        ],
                      );
                    }
                  },
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildKPICard(BuildContext context, String title, String value, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(20),
      width: 200,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: AppColors.neutral200, blurRadius: 4)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary500, size: 28),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(color: AppColors.textPrimary, fontSize: 28, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildActivityFeed(BuildContext context, List<ActivityLog> logs) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Live Activity Feed', style: Theme.of(context).textTheme.headlineLarge),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: logs.length,
            itemBuilder: (context, index) {
              final log = logs[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    const Icon(Icons.flash_on, color: AppColors.warning, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(color: AppColors.textPrimary),
                          children: [
                            TextSpan(text: '${log.volunteerName} ', style: const TextStyle(fontWeight: FontWeight.bold)),
                            TextSpan(text: 'completed ${log.taskName} — '),
                            const TextSpan(text: '✅ Verified ', style: TextStyle(color: AppColors.primary500)),
                            TextSpan(text: '— 🏅 ${log.vitMinted} VIT', style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboard(BuildContext context, List<Map<String, dynamic>> volunteers) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Top Volunteers', style: Theme.of(context).textTheme.headlineLarge),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: volunteers.length,
            itemBuilder: (context, index) {
              final v = volunteers[index];
              return ListTile(
                leading: CircleAvatar(backgroundColor: AppColors.primary100, child: Text('${index + 1}')),
                title: Text(v['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('${v['tasks']} tasks • Impact: ${v['score']}'),
                trailing: Text('${v['vit']} VIT', style: const TextStyle(color: AppColors.primary600, fontWeight: FontWeight.bold)),
              );
            },
          ),
        ],
      ),
    );
  }
}
