import 'package:flutter_riverpod/flutter_riverpod.dart';

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

final dashboardStatsProvider = Provider<DashboardStats>((ref) {
  return DashboardStats(
    verifiedHours: 1250,
    activeVolunteers: 85,
    tasksCompleted: 420,
    vitMinted: 15400,
  );
});

final activityFeedProvider = Provider<List<ActivityLog>>((ref) {
  return [
    ActivityLog(volunteerName: 'Rahul M.', taskName: 'Beach Cleanup', vitMinted: 15),
    ActivityLog(volunteerName: 'Sneha P.', taskName: 'Tree Plantation', vitMinted: 20),
    ActivityLog(volunteerName: 'Aman K.', taskName: 'Food Distribution', vitMinted: 30),
  ];
});

final topVolunteersProvider = Provider<List<Map<String, dynamic>>>((ref) {
  return [
    {'name': 'Sneha P.', 'tasks': 45, 'vit': 1200, 'score': 98},
    {'name': 'Rahul M.', 'tasks': 38, 'vit': 950, 'score': 92},
    {'name': 'Priya S.', 'tasks': 32, 'vit': 800, 'score': 89},
  ];
});
