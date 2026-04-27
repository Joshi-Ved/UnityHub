const String unityImpactAbi = r'''
[
  {
    "inputs": [
      {"internalType": "address", "name": "volunteer", "type": "address"},
      {"internalType": "uint256", "name": "taskId", "type": "uint256"},
      {"internalType": "uint256", "name": "amount", "type": "uint256"},
      {"internalType": "string", "name": "ipfsUri", "type": "string"},
      {"internalType": "bytes", "name": "signature", "type": "bytes"}
    ],
    "name": "mintImpactToken",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "inputs": [
      {"internalType": "address", "name": "account", "type": "address"},
      {"internalType": "uint256", "name": "id", "type": "uint256"}
    ],
    "name": "balanceOf",
    "outputs": [{"internalType": "uint256", "name": "", "type": "uint256"}],
    "stateMutability": "view",
    "type": "function"
  }
]
''';
