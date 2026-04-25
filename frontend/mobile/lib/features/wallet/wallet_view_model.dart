import 'package:flutter_riverpod/flutter_riverpod.dart';

class TokenTransaction {
  final String taskName;
  final DateTime date;
  final int vitEarned;
  final String txHash;

  TokenTransaction({
    required this.taskName,
    required this.date,
    required this.vitEarned,
    required this.txHash,
  });
}

class WalletState {
  final int totalVit;
  final double impactScore; // 0.0 to 1.0
  final List<TokenTransaction> transactions;

  WalletState({
    required this.totalVit,
    required this.impactScore,
    required this.transactions,
  });
}

final walletProvider = Provider<WalletState>((ref) {
  return WalletState(
    totalVit: 450,
    impactScore: 0.75, // 75%
    transactions: [
      TokenTransaction(
        taskName: 'Beach Cleanup Drive',
        date: DateTime.now().subtract(const Duration(days: 1)),
        vitEarned: 15,
        txHash: '0xabc...123',
      ),
      TokenTransaction(
        taskName: 'Food Distribution',
        date: DateTime.now().subtract(const Duration(days: 3)),
        vitEarned: 30,
        txHash: '0xdef...456',
      ),
      TokenTransaction(
        taskName: 'Tree Plantation',
        date: DateTime.now().subtract(const Duration(days: 7)),
        vitEarned: 20,
        txHash: '0xghi...789',
      ),
    ],
  );
});
