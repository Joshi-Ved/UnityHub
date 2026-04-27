import 'package:flutter/material.dart';
import 'package:unityhub_mobile/core/theme/theme.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final normalized = status.toLowerCase();
    late final Color background;
    late final Color foreground;

    switch (normalized) {
      case 'verified':
      case 'approved':
        background = AppColors.success;
        foreground = AppColors.textInverse;
        break;
      case 'pending':
        background = AppColors.warning;
        foreground = AppColors.textInverse;
        break;
      case 'rejected':
        background = AppColors.error;
        foreground = AppColors.textInverse;
        break;
      case 'flagged':
        background = AppColors.warning;
        foreground = AppColors.textInverse;
        break;
      default:
        background = AppColors.neutral200;
        foreground = AppColors.textPrimary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: foreground,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
