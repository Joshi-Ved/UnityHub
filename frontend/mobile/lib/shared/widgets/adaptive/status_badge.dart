import 'package:flutter/material.dart';

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
        background = const Color(0xFF10B981);
        foreground = Colors.white;
        break;
      case 'pending':
        background = const Color(0xFFF59E0B);
        foreground = Colors.white;
        break;
      case 'rejected':
        background = const Color(0xFFEF4444);
        foreground = Colors.white;
        break;
      case 'flagged':
        background = const Color(0xFFF97316);
        foreground = Colors.white;
        break;
      default:
        background = const Color(0xFFE5E7EB);
        foreground = const Color(0xFF111827);
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
