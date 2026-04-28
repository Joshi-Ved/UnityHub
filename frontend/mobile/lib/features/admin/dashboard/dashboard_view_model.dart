import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unityhub_mobile/features/admin/data/admin_api.dart';

class DashboardStats {
  final int verifiedHours;
  final int activeVolunteers;
  final int tasksCompleted;
  final int vitMinted;

  DashboardStats({
    required this.verifiedHours,
    required this.activeVolunteers,
    required this.tasksCompleted,
    required this.vitMinted,
  });
}

class ActivityLog {
  final String volunteerName;
  final String taskName;
  final int vitMinted;

  ActivityLog({
    required this.volunteerName,
    required this.taskName,
    required this.vitMinted,
  });
}

class AdminDashboardData {
  final DashboardStats stats;
  final List<ActivityLog> activity;
  final List<Map<String, dynamic>> leaderboard;
  final Map<String, int> funnel;

  AdminDashboardData({
    required this.stats,
    required this.activity,
    required this.leaderboard,
    required this.funnel,
  });
}

final adminApiProvider = Provider<AdminApi>((ref) => AdminApi());

final adminDashboardProvider = FutureProvider<AdminDashboardData>((ref) async {
  final api = ref.read(adminApiProvider);

  try {
    final dashboard = await api.fetchDashboard();
    final activity = await api.fetchActivity();

    final kpi = (dashboard['kpi'] as Map<String, dynamic>? ?? const <String, dynamic>{});
    final leaderboard = (dashboard['leaderboard'] as List? ?? const [])
        .whereType<Map>()
        .map((entry) => Map<String, dynamic>.from(entry))
        .toList();
    final activityRows = (activity['activity'] as List? ?? const [])
        .whereType<Map>()
        .map((entry) => ActivityLog(
              volunteerName: '${entry['volunteer_name'] ?? 'Unknown'}',
              taskName: '${entry['task_name'] ?? 'Task'}',
              vitMinted: (entry['vit_minted'] as num?)?.toInt() ?? 0,
            ))
        .toList();

    final funnelRaw = (dashboard['funnel'] as Map? ?? const {});
    final funnel = {
      'submitted': (funnelRaw['submitted'] as num?)?.toInt() ?? 0,
      'processed': (funnelRaw['processed'] as num?)?.toInt() ?? 0,
      'approved': (funnelRaw['approved'] as num?)?.toInt() ?? 0,
      'minted': (funnelRaw['minted'] as num?)?.toInt() ?? 0,
    };

    return AdminDashboardData(
      stats: DashboardStats(
        verifiedHours: (kpi['verified_hours'] as num?)?.toInt() ?? 0,
        activeVolunteers: (kpi['active_volunteers'] as num?)?.toInt() ?? 0,
        tasksCompleted: (kpi['tasks_completed'] as num?)?.toInt() ?? 0,
        vitMinted: (kpi['vit_minted'] as num?)?.toInt() ?? 0,
      ),
      activity: activityRows,
      leaderboard: leaderboard,
      funnel: funnel,
    );
  } catch (e) {
    throw Exception('Failed to load dashboard data: $e');
  }
});
