import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unityhub_mobile/core/theme/theme.dart';
import 'package:unityhub_mobile/features/map/map_view_model.dart';
import 'package:unityhub_mobile/features/tasks/verification_modal.dart';

class TaskTray extends ConsumerWidget {
  const TaskTray({super.key, this.heightFactor = 0.4});

  final double heightFactor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final task = ref.watch(selectedTaskProvider);

    if (task == null) {
      return const SizedBox.shrink();
    }

    return FractionallySizedBox(
      heightFactor: heightFactor,
      alignment: Alignment.bottomCenter,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    task.title,
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary100,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '🏅 ${task.tokenReward} VIT',
                    style: const TextStyle(
                      color: AppColors.primary700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${task.ngoName} • ${task.distance}km away',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: task.skills
                  .map(
                    (skill) => Chip(
                      label: Text(skill),
                      backgroundColor: AppColors.background,
                      side: BorderSide.none,
                    ),
                  )
                  .toList(),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  showGeneralDialog(
                    context: context,
                    barrierColor: Colors.black,
                    barrierDismissible: false,
                    barrierLabel: 'Verification',
                    transitionDuration: const Duration(milliseconds: 300),
                    pageBuilder: (context, animation, secondaryAnimation) {
                      return const VerificationModal();
                    },
                  );
                },
                child: const Text('Mark Complete / Verify'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
