import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unityhub_mobile/core/theme/theme.dart';
import 'package:unityhub_mobile/features/map/map_view_model.dart';
import 'package:go_router/go_router.dart';

class AdminTasksScreen extends ConsumerWidget {
  const AdminTasksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(mapTasksProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Management'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/admin/dashboard'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('All Tasks', style: Theme.of(context).textTheme.headlineLarge),
                ElevatedButton.icon(
                  onPressed: () => _showCreateTaskModal(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Create Task'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Tasks Table
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Title')),
                    DataColumn(label: Text('Status')),
                    DataColumn(label: Text('Reward')),
                    DataColumn(label: Text('Actions')),
                  ],
                  rows: tasks.map((task) {
                    return DataRow(
                      cells: [
                        DataCell(Text(task.title)),
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: task.status == 'available' ? AppColors.primary100 : Colors.amber.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              task.status.toUpperCase(),
                              style: TextStyle(
                                color: task.status == 'available' ? AppColors.primary700 : Colors.amber.shade900,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        DataCell(Text('${task.tokenReward} VIT')),
                        DataCell(
                          TextButton(
                            onPressed: () {},
                            child: const Text('View Logs'),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateTaskModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Create New Task'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const TextField(decoration: InputDecoration(labelText: 'Title')),
                const SizedBox(height: 12),
                const TextField(decoration: InputDecoration(labelText: 'Description')),
                const SizedBox(height: 12),
                const TextField(decoration: InputDecoration(labelText: 'Token Reward (VIT)')),
                const SizedBox(height: 12),
                const TextField(
                  decoration: InputDecoration(labelText: 'Verification Criteria (for Gemini)'),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Task Created successfully!')));
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }
}
