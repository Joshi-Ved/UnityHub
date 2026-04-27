import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unityhub_mobile/core/router/app_routes.dart';
import 'package:unityhub_mobile/core/theme/theme.dart';
import 'package:unityhub_mobile/features/map/map_view_model.dart';
import 'package:go_router/go_router.dart';
import 'package:unityhub_mobile/shared/widgets/adaptive/async_state_widgets.dart';

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
    final tasks = ref.watch(mapTasksProvider);

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
            if (tasks.isEmpty)
              const AppEmptyState(
                title: 'No tasks yet',
                message: 'Create the first task to start volunteer verification.',
              )
            else
              LayoutBuilder(
                builder: (context, constraints) {
                  final isCompact = constraints.maxWidth < 900;
                  return isCompact
                      ? Column(
                          children: tasks
                              .map((task) => Card(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    child: ListTile(
                                      title: Text(task.title),
                                      subtitle: Text('${task.ngoName} • ${task.tokenReward} VIT'),
                                      trailing: _statusBadge(task.status),
                                      onTap: () => _showVerificationLogs(context, task),
                                    ),
                                  ))
                              .toList(),
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
                                return DataRow(
                                  cells: [
                                    DataCell(Text(task.title)),
                                    DataCell(_statusBadge(task.status)),
                                    DataCell(Text(task.ngoName)),
                                    DataCell(Text('${task.tokenReward} VIT')),
                                    DataCell(
                                      TextButton(
                                        onPressed: () => _showVerificationLogs(context, task),
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
              ),
          ],
        ),
      ),
    );
  }

  /// Shows a bottom sheet with mock Gemini verification logs for the selected task.
  void _showVerificationLogs(BuildContext context, VolunteerTask task) {
    final mockLogs = [
      {'volunteer': 'Rahul M.', 'score': '94%', 'status': 'Approved', 'time': '2h ago', 'fraud': false},
      {'volunteer': 'Sneha P.', 'score': '91%', 'status': 'Approved', 'time': '4h ago', 'fraud': false},
      {'volunteer': 'Anon User', 'score': '22%', 'status': 'Rejected', 'time': '5h ago', 'fraud': true},
    ];

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
                      Expanded(
                        child: Text(
                          'Verification Logs — ${task.title}',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: mockLogs.length,
                      itemBuilder: (context, index) {
                        final log = mockLogs[index];
                        final approved = log['status'] == 'Approved';
                        return Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: approved ? AppColors.primary100 : AppColors.error.withOpacity(0.15),
                              child: Icon(
                                approved ? Icons.check : Icons.close,
                                color: approved ? AppColors.primary600 : AppColors.error,
                              ),
                            ),
                            title: Text(log['volunteer'].toString()),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Gemini Score: ${log['score']} · ${log['time']}'),
                                if (log['fraud'] as bool)
                                  const Text(
                                    '⚠️ Fraud detected: image appears to be a screenshot',
                                    style: TextStyle(color: AppColors.error, fontSize: 11),
                                  ),
                              ],
                            ),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: approved ? AppColors.primary100 : AppColors.error.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                log['status'].toString(),
                                style: TextStyle(
                                  color: approved ? AppColors.primary700 : AppColors.error,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
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
    // Clear controllers before showing
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
                final title = _titleController.text.trim();
                if (title.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Task title is required')),
                  );
                  return;
                }
                // Add the new task to the local notifier state
                await ref.read(mapTasksProvider.notifier).addLocalTask(
                  title: title,
                  description: _descriptionController.text.trim(),
                  reward: int.tryParse(_rewardController.text) ?? 20,
                  criteria: _criteriaController.text.trim(),
                );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Task "$title" created successfully!')),
                );
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }
}
