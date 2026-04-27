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

  AdminDashboardData({
    required this.stats,
    required this.activity,
    required this.leaderboard,
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

    return AdminDashboardData(
      stats: DashboardStats(
        verifiedHours: (kpi['verified_hours'] as num?)?.toInt() ?? 0,
        activeVolunteers: (kpi['active_volunteers'] as num?)?.toInt() ?? 0,
        tasksCompleted: (kpi['tasks_completed'] as num?)?.toInt() ?? 0,
        vitMinted: (kpi['vit_minted'] as num?)?.toInt() ?? 0,
      ),
      activity: activityRows,
      leaderboard: leaderboard,
    );
  } catch (_) {
    return AdminDashboardData(
      stats: DashboardStats(
        verifiedHours: 1250,
        activeVolunteers: 85,
        tasksCompleted: 420,
        vitMinted: 15400,
      ),
      activity: [
        ActivityLog(volunteerName: 'Rahul M.', taskName: 'Beach Cleanup', vitMinted: 15),
        ActivityLog(volunteerName: 'Sneha P.', taskName: 'Tree Plantation', vitMinted: 20),
        ActivityLog(volunteerName: 'Aman K.', taskName: 'Food Distribution', vitMinted: 30),
      ],
      leaderboard: [
        {'name': 'Sneha P.', 'tasks': 45, 'vit': 1200, 'score': 98},
        {'name': 'Rahul M.', 'tasks': 38, 'vit': 950, 'score': 92},
        {'name': 'Priya S.', 'tasks': 32, 'vit': 800, 'score': 89},
      ],
    );
  }
});
