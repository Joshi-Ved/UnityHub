import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unityhub_mobile/features/admin/data/admin_api.dart';

class AdminTask {
  final String id;
  final String title;
  final String description;
  final String ngoName;
  final String status;
  final int tokenReward;
  final DateTime createdAt;

  AdminTask({
    required this.id,
    required this.title,
    required this.description,
    required this.ngoName,
    required this.status,
    required this.tokenReward,
    required this.createdAt,
  });

  factory AdminTask.fromMap(Map<String, dynamic> map) {
    return AdminTask(
      id: map['id'] ?? '',
      title: map['title'] ?? 'Unknown Task',
      description: map['description'] ?? '',
      ngoName: map['ngo_name'] ?? 'UnityHub NGO',
      status: map['status'] ?? 'available',
      tokenReward: map['token_reward'] ?? 0,
      createdAt: DateTime.tryParse(map['created_at'] ?? '') ?? DateTime.now(),
    );
  }
}

final adminTasksProvider = FutureProvider<List<AdminTask>>((ref) async {
  final api = AdminApi();
  final tasks = await api.fetchTasks();
  return tasks.map((t) => AdminTask.fromMap(t)).toList();
});
