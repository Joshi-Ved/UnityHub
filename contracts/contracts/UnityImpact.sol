// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract UnityImpact is ERC1155, ERC1155URIStorage, Ownable, EIP712 {
    using ECDSA for bytes32;

    address public oracleAddress;
    mapping(bytes => bool) public usedSignatures;

    bytes32 private constant MINT_TYPEHASH = keccak256("VerifyAndMint(address to,uint256 taskId,uint256 amount,string ipfsUri)");

    event OracleUpdated(address oldOracle, address newOracle);
    event ImpactMinted(address indexed to, uint256 indexed taskId, uint256 amount, string ipfsUri);

    constructor(address initialOwner, address _oracleAddress) 
        ERC1155("") 
        Ownable(initialOwner) 
        EIP712("UnityHub", "1") 
    {
        oracleAddress = _oracleAddress;
    }

    function setOracle(address _newOracle) external onlyOwner {
        address oldOracle = oracleAddress;
        oracleAddress = _newOracle;
        emit OracleUpdated(oldOracle, _newOracle);
    }

    // Required override by Solidity
    function uri(uint256 tokenId) public view virtual override(ERC1155, ERC1155URIStorage) returns (string memory) {
        return super.uri(tokenId);
    }

    function _verifySignature(
        address to, 
        uint256 taskId, 
        uint256 amount, 
        string memory ipfsUri, 
        bytes memory signature
    ) internal {
        require(!usedSignatures[signature], "UnityImpact: Signature already used");
        usedSignatures[signature] = true;

        bytes32 structHash = keccak256(abi.encode(
            MINT_TYPEHASH,
            to,
            taskId,
            amount,
            keccak256(bytes(ipfsUri))
        ));

        bytes32 hash = _hashTypedDataV4(structHash);
        address signer = ECDSA.recover(hash, signature);
        require(signer == oracleAddress, "UnityImpact: Invalid oracle signature");
    }

    function mintImpactToken(
        address volunteer, 
        uint256 taskId, 
        uint256 amount, 
        string memory ipfsUri, 
        bytes memory signature
    ) public {
        _verifySignature(volunteer, taskId, amount, ipfsUri, signature);
        
        // Ensure IPFS URI is set for this task ID (proof of work metadata)
        _setURI(taskId, ipfsUri);
        _mint(volunteer, taskId, amount, "");
        
        emit ImpactMinted(volunteer, taskId, amount, ipfsUri);
    }

    function batchMintImpactTokens(
        address[] calldata volunteers,
        uint256[] calldata taskIds,
        uint256[] calldata amounts,
        string[] calldata ipfsUris,
        bytes[] calldata signatures
    ) external {
        require(volunteers.length == taskIds.length, "Array length mismatch");
        require(taskIds.length == amounts.length, "Array length mismatch");
        require(amounts.length == signatures.length, "Array length mismatch");
        require(signatures.length == ipfsUris.length, "Array length mismatch");

        for (uint256 i = 0; i < volunteers.length; i++) {
            mintImpactToken(volunteers[i], taskIds[i], amounts[i], ipfsUris[i], signatures[i]);
        }
    }
}
