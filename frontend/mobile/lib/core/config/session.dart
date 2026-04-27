import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Demo session holding the active volunteer's wallet credentials.
///
/// In production this would be populated by a real wallet SDK (e.g. WalletConnect,
/// MetaMask Mobile SDK, or a custodial wallet backed by the DigiLocker identity).
///
/// For demo / testnet, we use a known Polygon Amoy test account so that:
///   - The user_address sent to /verify-impact is consistent
///   - The userPrivateKey used to submit the mint tx matches that address
///   - The backend nonce is fetched for the correct address
///
/// Amoy test wallet (DO NOT use in production — no real funds):
///   Address : 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266
///   Key     : 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
class DemoSession {
  /// Demo volunteer wallet address (derived from [demoPrivateKey]).
  static const String demoWalletAddress =
      '0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266';

  /// Demo private key — used only to sign/send the mint transaction on Amoy.
  /// Never store real keys here. Replace with a wallet SDK in production.
  static const String demoPrivateKey =
      '0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80';
}

/// Riverpod state for the currently logged-in volunteer's wallet address.
/// Initialises with the demo address; will be overwritten when real auth is wired.
final activeWalletAddressProvider = StateProvider<String>((ref) {
  return DemoSession.demoWalletAddress;
});
