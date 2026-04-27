import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unityhub_mobile/core/theme/theme.dart';
import 'package:unityhub_mobile/features/admin/dashboard/dashboard_view_model.dart';

class VolunteerDirectoryScreen extends ConsumerWidget {
  const VolunteerDirectoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topVolunteers = ref.watch(topVolunteersProvider);
    final activityLogs = ref.watch(activityFeedProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Volunteer Directory',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            const Text(
              'Sorted by impact score — sample data',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            // Top volunteers from provider
            ...topVolunteers.map((v) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.primary100,
                  child: Text(
                    '${v['score']}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary700,
                    ),
                  ),
                ),
                title: Text(v['name'].toString()),
                subtitle: Text('${v['tasks']} tasks · ${v['vit']} VIT'),
                trailing: v['score'] as int >= 95
                    ? const Icon(Icons.verified, color: AppColors.primary500)
                    : null,
              ),
            )),
            const Divider(),
            const SizedBox(height: 8),
            const Text(
              'Recent Activity',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            // Recent activity feed
            ...activityLogs.map((log) => ListTile(
              dense: true,
              leading: const Icon(Icons.check_circle_outline, color: AppColors.primary500),
              title: Text(log.volunteerName),
              subtitle: Text('Task: ${log.taskName}'),
              trailing: Text(
                '+${log.vitMinted} VIT',
                style: const TextStyle(
                  color: AppColors.primary600,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }
}
