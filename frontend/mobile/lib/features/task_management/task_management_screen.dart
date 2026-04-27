import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:unityhub_mobile/core/theme/theme.dart';
import 'package:unityhub_mobile/shared/widgets/adaptive/async_state_widgets.dart';
import 'package:unityhub_mobile/shared/widgets/adaptive/status_badge.dart';
import 'package:unityhub_mobile/shared/widgets/adaptive/unityhub_button.dart';

class TaskManagementScreen extends StatefulWidget {
  const TaskManagementScreen({super.key});

  @override
  State<TaskManagementScreen> createState() => _TaskManagementScreenState();
}

class _TaskManagementScreenState extends State<TaskManagementScreen> {
  final _searchController = TextEditingController();
  String _statusFilter = 'All';
  int _selectedRow = -1;

  final _rows = <Map<String, dynamic>>[
    {'name': 'Beach Cleanup', 'category': 'Environment', 'location': 'Mumbai', 'status': 'Active', 'reward': 20, 'assigned': 8},
    {'name': 'Food Kit Distribution', 'category': 'Food', 'location': 'Delhi', 'status': 'Completed', 'reward': 25, 'assigned': 12},
    {'name': 'After-school Tutoring', 'category': 'Education', 'location': 'Pune', 'status': 'Flagged', 'reward': 18, 'assigned': 4},
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _rows.where((row) {
      final matchesText = _searchController.text.isEmpty ||
          row['name'].toString().toLowerCase().contains(_searchController.text.toLowerCase()) ||
          row['location'].toString().toLowerCase().contains(_searchController.text.toLowerCase());
      final matchesStatus = _statusFilter == 'All' || row['status'] == _statusFilter;
      return matchesText && matchesStatus;
    }).toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 1100;
        final selectedTask = _selectedRow >= 0 && filtered.isNotEmpty
            ? filtered[_selectedRow.clamp(0, filtered.length - 1)]
            : null;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          SizedBox(
                            width: isCompact ? constraints.maxWidth - 32 : 420,
                            child: SearchBar(
                              controller: _searchController,
                              hintText: 'Search by task name or location',
                              onChanged: (_) => setState(() {}),
                            ),
                          ),
                          DropdownButton<String>(
                            value: _statusFilter,
                            items: const [
                              DropdownMenuItem(value: 'All', child: Text('All')),
                              DropdownMenuItem(value: 'Active', child: Text('Active')),
                              DropdownMenuItem(value: 'Completed', child: Text('Completed')),
                              DropdownMenuItem(value: 'Flagged', child: Text('Flagged')),
                            ],
                            onChanged: (value) => setState(() => _statusFilter = value ?? 'All'),
                          ),
                          UnityHubButton(
                            label: '+ Create Task',
                            onPressed: () => _showTaskCreationDialog(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (filtered.isEmpty)
                        const AppEmptyState(
                          title: 'No tasks match the filter',
                          message: 'Try changing search text or status filter.',
                        )
                      else if (isCompact)
                        Column(
                          children: List.generate(filtered.length, (index) {
                            final row = filtered[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 10),
                              child: ListTile(
                                onTap: () => setState(() => _selectedRow = index),
                                title: Text(row['name'].toString()),
                                subtitle: Text('${row['category']} • ${row['location']}'),
                                trailing: StatusBadge(status: row['status'].toString()),
                              ),
                            );
                          }),
                        )
                      else
                        SizedBox(
                          height: 500,
                          child: DataTable2(
                            columnSpacing: 12,
                            horizontalMargin: 12,
                            minWidth: 1000,
                            columns: const [
                              DataColumn2(label: Text('Task Name'), size: ColumnSize.L),
                              DataColumn(label: Text('Category')),
                              DataColumn(label: Text('Location')),
                              DataColumn(label: Text('Status')),
                              DataColumn(label: Text('Token Reward')),
                              DataColumn(label: Text('Assigned Volunteers')),
                              DataColumn(label: Text('Actions')),
                            ],
                            rows: List.generate(filtered.length, (index) {
                              final row = filtered[index];
                              return DataRow(
                                selected: _selectedRow == index,
                                onSelectChanged: (_) => setState(() => _selectedRow = index),
                                cells: [
                                  DataCell(Text(row['name'].toString())),
                                  DataCell(Text(row['category'].toString())),
                                  DataCell(Text(row['location'].toString())),
                                  DataCell(StatusBadge(status: row['status'].toString())),
                                  DataCell(Text('${row['reward']} VIT')),
                                  DataCell(Text('${row['assigned']}')),
                                  DataCell(TextButton(onPressed: () => setState(() => _selectedRow = index), child: const Text('View'))),
                                ],
                              );
                            }),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            if (!isCompact && selectedTask != null) ...[
              const SizedBox(width: 12),
              SizedBox(width: 480, child: _TaskDetailPanel(task: selectedTask)),
            ],
          ],
        );
      },
    );
  }

  Future<void> _showTaskCreationDialog(BuildContext context) async {
    final skills = ['Logistics', 'Teaching', 'Design', 'First Aid'];
    final selectedSkills = <String>[];
    double reward = 20;

    await showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            contentPadding: const EdgeInsets.all(20),
            title: const Text('Create Task'),
            content: SizedBox(
              width: 700,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const TextField(decoration: InputDecoration(labelText: 'Task Title')),
                    const SizedBox(height: 10),
                    const TextField(maxLines: 4, decoration: InputDecoration(labelText: 'Description')),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Category'),
                      items: const [
                        DropdownMenuItem(value: 'Food', child: Text('Food')),
                        DropdownMenuItem(value: 'Education', child: Text('Education')),
                        DropdownMenuItem(value: 'Environment', child: Text('Environment')),
                        DropdownMenuItem(value: 'Health', child: Text('Health')),
                      ],
                      onChanged: (_) {},
                    ),
                    const SizedBox(height: 10),
                    const TextField(decoration: InputDecoration(labelText: 'Location (Google Places Autocomplete)')),
                    const SizedBox(height: 10),
                    MultiSelectDialogField<String>(
                      items: skills.map((e) => MultiSelectItem<String>(e, e)).toList(),
                      title: const Text('Required Skills'),
                      buttonText: const Text('Required Skills'),
                      initialValue: selectedSkills,
                      onConfirm: (values) {
                        selectedSkills
                          ..clear()
                          ..addAll(values);
                      },
                    ),
                    const SizedBox(height: 10),
                    Text('Token Reward: ${reward.toStringAsFixed(0)} VIT'),
                    Slider(
                      value: reward,
                      min: 5,
                      max: 100,
                      divisions: 19,
                      label: reward.toStringAsFixed(0),
                      onChanged: (value) => setStateDialog(() => reward = value),
                    ),
                    const SizedBox(height: 10),
                    const TextField(
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Verification Criteria',
                        hintText: 'Describe what Gemini should check in the photo...',
                      ),
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      onPressed: () => showDatePicker(
                        context: context,
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2030),
                      ),
                      icon: const Icon(Icons.calendar_today),
                      label: const Text('Deadline'),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
              FilledButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Task created (mock POST /api/tasks/create)')));
                },
                child: const Text('Create Task'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _TaskDetailPanel extends StatelessWidget {
  const _TaskDetailPanel({required this.task});

  final Map<String, dynamic> task;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(task['name'].toString(), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700))),
                StatusBadge(status: task['status'].toString()),
              ],
            ),
            const SizedBox(height: 12),
            Text('Category: ${task['category']}'),
            Text('Location: ${task['location']}'),
            Text('Reward: ${task['reward']} VIT'),
            const SizedBox(height: 16),
            const Text('Assigned Volunteers', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Expanded(
              child: ListView(
                children: List.generate(5, (i) {
                  return Card(
                    child: ListTile(
                      leading: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.neutral200,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.image_outlined),
                      ),
                      title: Text('Volunteer ${i + 1}'),
                      subtitle: const Text('Gemini audit: photo quality good, geotag consistent.'),
                      trailing: const StatusBadge(status: 'Approved'),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
