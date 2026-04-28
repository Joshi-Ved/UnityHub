import 'package:flutter/material.dart';
import 'package:unityhub_mobile/core/theme/theme.dart';
import 'package:url_launcher/url_launcher.dart';

class TransparencyView extends StatelessWidget {
  final String contractAddress;
  final List<Map<String, String>> transactions;

  const TransparencyView({
    super.key,
    required this.contractAddress,
    required this.transactions,
  });

  Future<void> _launchUrl(String txHash) async {
    final url = Uri.parse('https://amoy.polygonscan.com/tx/$txHash');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Transparency Layer',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              'Polygon Amoy Contract:\n$contractAddress',
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontFamily: 'monospace'),
            ),
            const Divider(height: 32),
            const Text(
              'Recent Transactions',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            ...transactions.map((tx) {
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.link, color: AppColors.primary500),
                title: Text(tx['task'] ?? 'Task', style: const TextStyle(fontWeight: FontWeight.w500)),
                subtitle: Text(
                  tx['hash'] ?? '',
                  style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: const Icon(Icons.open_in_new, size: 16),
                onTap: () => _launchUrl(tx['hash'] ?? ''),
              );
            }),
          ],
        ),
      ),
    );
  }
}
