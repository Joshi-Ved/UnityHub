import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unityhub_mobile/core/config/session.dart';
import 'package:unityhub_mobile/core/theme/theme.dart';
import 'package:unityhub_mobile/features/wallet/wallet_view_model.dart';

class VolunteerProfileScreen extends ConsumerWidget {
  const VolunteerProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walletState = ref.watch(walletProvider);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const CircleAvatar(radius: 36, child: Icon(Icons.person, size: 32)),
        const SizedBox(height: 12),
        const Center(
          child: Text(
            'Volunteer Profile',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(height: 4),
        Center(
          child: Text(
            // Show truncated wallet address as identity
            '${DemoSession.demoWalletAddress.substring(0, 8)}...${DemoSession.demoWalletAddress.substring(36)}',
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
        ),
        const SizedBox(height: 4),
        const Center(
          child: Chip(
            avatar: Icon(Icons.verified_user, size: 14, color: AppColors.primary600),
            label: Text('Identity Verified via DigiLocker',
                style: TextStyle(fontSize: 12, color: AppColors.primary700)),
            backgroundColor: AppColors.primary100,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: ListTile(
            leading: const Icon(Icons.insights_outlined, color: AppColors.primary500),
            title: const Text('Impact Score'),
            subtitle: walletState.isLoading
                ? const LinearProgressIndicator()
                : Text('${walletState.impactScore} / 100'),
            trailing: walletState.impactScore >= 80
                ? const Icon(Icons.emoji_events, color: AppColors.warning)
                : null,
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.token_outlined, color: AppColors.primary500),
            title: const Text('VIT Balance'),
            subtitle: walletState.isLoading
                ? const LinearProgressIndicator()
                : Text('${walletState.totalVit} Volunteer Impact Tokens'),
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.task_alt, color: AppColors.primary500),
            title: const Text('Completed Tasks'),
            subtitle: Text('${walletState.transactions.length} verified submissions'),
          ),
        ),
        const Card(
          child: ListTile(
            leading: Icon(Icons.workspace_premium_outlined, color: AppColors.primary500),
            title: Text('Badges'),
            subtitle: Text('Community Builder, Eco Warrior'),
          ),
        ),
      ],
    );
  }
}
