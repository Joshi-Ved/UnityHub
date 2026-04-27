import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:unityhub_mobile/core/router/app_routes.dart';
import 'package:unityhub_mobile/features/map/map_view_model.dart';
import 'package:unityhub_mobile/shared/widgets/adaptive/async_state_widgets.dart';
import 'package:unityhub_mobile/shared/widgets/adaptive/status_badge.dart';

class TaskListScreen extends ConsumerWidget {
  const TaskListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(mapTasksProvider);
    if (tasks.isEmpty) {
      return const AppEmptyState(
        title: 'No tasks available',
        message: 'New volunteer tasks will appear here once they are published.',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: tasks.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final task = tasks[index];
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(task.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                    ),
                    StatusBadge(status: task.status == 'completed' ? 'Verified' : 'Pending'),
                  ],
                ),
                const SizedBox(height: 8),
                Text('${task.ngoName} | ${task.distance.toStringAsFixed(1)} km'),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: task.skills
                      .map((skill) => Chip(label: Text(skill), visualDensity: VisualDensity.compact))
                      .toList(),
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () {
                    // Set the selected task BEFORE navigating so VerificationModal
                    // reads the correct task title for the Gemini AI request
                    ref.read(selectedTaskProvider.notifier).state = task;
                    context.go(AppRoutes.volunteerVerify(task.id));
                  },
                  child: const Text('Open Verification Flow'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
