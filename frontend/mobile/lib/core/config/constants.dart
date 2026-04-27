class AppConstants {
  // Local Uvicorn backend URL — change to your deployed URL for production
  static const String apiBaseUrl = 'http://127.0.0.1:8000';

  // Polygon Amoy RPC URL
  static const String rpcUrl = 'https://rpc-amoy.polygon.technology/';

  // Polygon Amoy Contract Address
  // TODO: Replace with the real deployed UnityImpact.sol address after `npx hardhat run scripts/deploy.js --network amoy`
  static const String polygonAmoyContractAddress =
      '0xPLACEHOLDER_AMOY_CONTRACT_ADDRESS_1234567';
}
