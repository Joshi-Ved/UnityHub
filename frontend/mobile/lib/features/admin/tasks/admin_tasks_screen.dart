import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unityhub_mobile/core/router/app_routes.dart';
import 'package:unityhub_mobile/core/theme/theme.dart';
import 'package:unityhub_mobile/features/admin/data/admin_api.dart';
import 'package:go_router/go_router.dart';
import 'package:unityhub_mobile/shared/widgets/adaptive/async_state_widgets.dart';

final adminTasksProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  return ref.read(adminApiProvider).fetchTasks();
});

class AdminTasksScreen extends ConsumerStatefulWidget {
  const AdminTasksScreen({super.key});

  @override
  ConsumerState<AdminTasksScreen> createState() => _AdminTasksScreenState();
}

class _AdminTasksScreenState extends ConsumerState<AdminTasksScreen> {
  // Form controllers for the Create Task dialog
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _rewardController = TextEditingController(text: '20');
  final _criteriaController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _rewardController.dispose();
    _criteriaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tasksAsync = ref.watch(adminTasksProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Management'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRoutes.adminDashboard),
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
            tasksAsync.when(
              loading: () => const Center(child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(),
              )),
              error: (error, stack) => Padding(
                padding: const EdgeInsets.all(12),
                child: Text('Failed to load tasks: $error'),
              ),
              data: (tasks) {
                if (tasks.isEmpty) {
                  return const AppEmptyState(
                    title: 'No tasks yet',
                    message: 'Create the first task to start volunteer verification.',
                  );
                }
                return LayoutBuilder(
                  builder: (context, constraints) {
                    final isCompact = constraints.maxWidth < 900;
                    return isCompact
                        ? Column(
                            children: tasks.map((task) {
                              final status = task['status']?.toString() ?? 'available';
                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                child: ListTile(
                                  title: Text(task['title']?.toString() ?? 'Untitled'),
                                  subtitle: Text('${task['ngo_name'] ?? 'NGO'} • ${task['token_reward'] ?? 0} VIT'),
                                  trailing: _statusBadge(status),
                                  onTap: () => _showTaskLogs(context, task['id']?.toString() ?? ''),
                                ),
                              );
                            }).toList(),
                          )
                        : Container(
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.neutral200),
                            ),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: DataTable(
                                columns: const [
                                  DataColumn(label: Text('Title')),
                                  DataColumn(label: Text('Status')),
                                  DataColumn(label: Text('NGO')),
                                  DataColumn(label: Text('Reward')),
                                  DataColumn(label: Text('Actions')),
                                ],
                                rows: tasks.map((task) {
                                  final status = task['status']?.toString() ?? 'available';
                                  return DataRow(
                                    cells: [
                                      DataCell(Text(task['title']?.toString() ?? 'Untitled')),
                                      DataCell(_statusBadge(status)),
                                      DataCell(Text(task['ngo_name']?.toString() ?? 'NGO')),
                                      DataCell(Text('${task['token_reward'] ?? 0} VIT')),
                                      DataCell(
                                        TextButton(
                                          onPressed: () => _showTaskLogs(context, task['id']?.toString() ?? ''),
                                          child: const Text('View Logs'),
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                          );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showTaskLogs(BuildContext context, String taskId) async {
    try {
      final logs = await ref.read(adminApiProvider).fetchTaskLogs(taskId);
      if (!context.mounted) return;

      showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        isScrollControlled: true,
        builder: (context) {
          return DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.55,
            maxChildSize: 0.85,
            builder: (context, scrollController) {
              return Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Task Logs',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text('Powered by Gemini Vision AI', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                    const Divider(height: 24),
                    Expanded(
                      child: logs.isEmpty
                        ? const Center(child: Text('No logs available for this task yet.'))
                        : ListView.separated(
                            controller: scrollController,
                            itemCount: logs.length,
                            separatorBuilder: (_, __) => const Divider(height: 16),
                            itemBuilder: (context, index) => ListTile(
                              leading: const CircleAvatar(
                                backgroundColor: AppColors.primary100,
                                child: Icon(Icons.info_outline, color: AppColors.primary600),
                              ),
                              title: Text(logs[index]),
                            ),
                          ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      );
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load logs: $error')),
      );
    }
  }

  Widget _statusBadge(String status) {
    final available = status == 'available';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: available ? AppColors.primary100 : AppColors.warning.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: available ? AppColors.primary700 : AppColors.warning,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showCreateTaskModal(BuildContext context) {
    _titleController.clear();
    _descriptionController.clear();
    _rewardController.text = '20';
    _criteriaController.clear();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Create New Task'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _rewardController,
                  decoration: const InputDecoration(labelText: 'Token Reward (VIT)'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _criteriaController,
                  decoration: const InputDecoration(
                    labelText: 'Verification Criteria (for Gemini)',
                    hintText: 'Describe what Gemini should check in the photo...',
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  final title = _titleController.text.trim();
                  if (title.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Task title is required')),
                    );
                    return;
                  }
                  final reward = int.tryParse(_rewardController.text.trim()) ?? 0;
                  await ref.read(adminApiProvider).createTask(
                        title: title,
                        description: _descriptionController.text.trim(),
                        tokenReward: reward,
                        verificationCriteria: _criteriaController.text.trim(),
                      );

                  ref.invalidate(adminTasksProvider);
                  if (!context.mounted) return;
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Task created successfully!')),
                  );
                } catch (error) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Task creation failed: $error')),
                  );
                }
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }
}
