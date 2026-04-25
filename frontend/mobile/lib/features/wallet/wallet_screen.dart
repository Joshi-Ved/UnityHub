import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unityhub_mobile/core/theme/theme.dart';
import 'package:unityhub_mobile/features/wallet/wallet_view_model.dart';
import 'package:go_router/go_router.dart';

class WalletScreen extends ConsumerWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walletState = ref.watch(walletProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Impact Wallet'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/volunteer/map'),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final useGrid = kIsWeb && constraints.maxWidth >= 900;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildScoreCard(context, walletState),
                const SizedBox(height: 24),
                Text('Badge Shelf', style: Theme.of(context).textTheme.headlineLarge),
                const SizedBox(height: 16),
                _buildBadgeShelf(),
                const SizedBox(height: 32),
                Text('Transaction History', style: Theme.of(context).textTheme.headlineLarge),
                const SizedBox(height: 16),
                useGrid
                    ? _buildTransactionGrid(walletState.transactions)
                    : _buildTransactionList(walletState.transactions),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildScoreCard(BuildContext context, WalletState state) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.primary500,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Total Balance', style: TextStyle(color: Colors.white70, fontSize: 16)),
              const SizedBox(height: 8),
              Text(
                '${state.totalVit} VIT',
                style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(
            width: 80,
            height: 80,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: state.impactScore,
                  strokeWidth: 8,
                  backgroundColor: Colors.white24,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
                Center(
                  child: Text(
                    '${(state.impactScore * 100).toInt()}%',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadgeShelf() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(4, (index) {
          return Container(
            margin: const EdgeInsets.only(right: 16),
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primary50,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary200, width: 2),
            ),
            child: const Center(
              child: Icon(Icons.star, color: AppColors.primary400, size: 40),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTransactionList(List<TokenTransaction> transactions) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final tx = transactions[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: AppColors.primary100,
              child: Icon(Icons.check, color: AppColors.primary600),
            ),
            title: Text(tx.taskName, style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text('Tx: ${tx.txHash}'),
            trailing: Text(
              '+${tx.vitEarned} VIT',
              style: const TextStyle(color: AppColors.primary600, fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTransactionGrid(List<TokenTransaction> transactions) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: transactions.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.6,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemBuilder: (context, index) {
        final tx = transactions[index];
        return Card(
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: AppColors.primary100,
              child: Icon(Icons.check, color: AppColors.primary600),
            ),
            title: Text(tx.taskName, style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text('Tx: ${tx.txHash}'),
            trailing: Text(
              '+${tx.vitEarned} VIT',
              style: const TextStyle(color: AppColors.primary600, fontWeight: FontWeight.bold),
            ),
          ),
        );
      },
    );
  }
}
