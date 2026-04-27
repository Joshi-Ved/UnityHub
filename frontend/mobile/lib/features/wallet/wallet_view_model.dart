import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';
import 'package:hex/hex.dart';
import 'package:unityhub_mobile/core/config/constants.dart';
import 'package:unityhub_mobile/core/config/abi.dart';

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
  final bool isLoading;
  final String? error;

  WalletState({
    required this.totalVit,
    required this.impactScore,
    required this.transactions,
    this.isLoading = false,
    this.error,
  });

  // Sentinel so callers can explicitly clear error by passing clearError: true
  WalletState copyWith({
    int? totalVit,
    double? impactScore,
    List<TokenTransaction>? transactions,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return WalletState(
      totalVit: totalVit ?? this.totalVit,
      impactScore: impactScore ?? this.impactScore,
      transactions: transactions ?? this.transactions,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class WalletViewModel extends StateNotifier<WalletState> {
  WalletViewModel() : super(WalletState(
    totalVit: 0,
    impactScore: 0.0,
    transactions: [],
    isLoading: true,
  ));

  final _client = Web3Client(AppConstants.rpcUrl, http.Client());

  Future<void> loadWalletData(String userAddress) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final contract = DeployedContract(
        ContractAbi.fromJson(unityImpactAbi, 'UnityImpact'),
        EthereumAddress.fromHex(AppConstants.polygonAmoyContractAddress),
      );

      final balanceFn = contract.function('balanceOf');
      final balanceResponse = await _client.call(
        contract: contract,
        function: balanceFn,
        params: [EthereumAddress.fromHex(userAddress), BigInt.from(1)], // tokenId = 1 for VIT
      );

      final balance = balanceResponse.first as BigInt;

      // Impact score: 100 VIT = 100%. Clamped so it never overflows the ring gauge.
      final score = (balance.toInt() / 100).clamp(0.0, 1.0);

      // TODO: Fetch transaction history from a sub-graph or block explorer events API

      state = state.copyWith(
        totalVit: balance.toInt(),
        impactScore: score,
        isLoading: false,
        clearError: true,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<String> mintToken({
    required String signature,
    required int taskId,
    required int amount,
    required String ipfsUri,
    required String userPrivateKey,
  }) async {
    try {
      final credentials = EthPrivateKey.fromHex(userPrivateKey);
      final userAddress = credentials.address;

      final contract = DeployedContract(
        ContractAbi.fromJson(unityImpactAbi, 'UnityImpact'),
        EthereumAddress.fromHex(AppConstants.polygonAmoyContractAddress),
      );

      final mintFn = contract.function('mintImpactToken');
      
      // Clean signature if it has 0x prefix
      String cleanSignature = signature.startsWith('0x') ? signature.substring(2) : signature;
      Uint8List signatureBytes = Uint8List.fromList(HEX.decode(cleanSignature));

      final txHash = await _client.sendTransaction(
        credentials,
        Transaction.callContract(
          contract: contract,
          function: mintFn,
          parameters: [
            userAddress,
            BigInt.from(taskId),
            BigInt.from(amount),
            ipfsUri,
            signatureBytes,
          ],
        ),
        chainId: 80002, // Polygon Amoy
      );

      // Refresh balance after transaction
      await loadWalletData(userAddress.hex);

      return txHash;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }
}

final walletProvider = StateNotifierProvider<WalletViewModel, WalletState>((ref) {
  return WalletViewModel();
});
