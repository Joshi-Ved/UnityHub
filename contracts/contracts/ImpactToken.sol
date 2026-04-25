// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ImpactToken is ERC1155, Ownable {
    address public aiOracleAddress;

    event OracleUpdated(address oldOracle, address newOracle);
    event ImpactMinted(address indexed to, uint256 indexed id, uint256 amount);

    modifier onlyOracle() {
        require(msg.sender == aiOracleAddress, "ImpactToken: Caller is not the AI Oracle");
        _;
    }

    constructor(address initialOwner, address _aiOracleAddress) ERC1155("https://api.unityhub.app/metadata/{id}.json") Ownable(initialOwner) {
        aiOracleAddress = _aiOracleAddress;
    }

    function setAIOracle(address _newOracle) external onlyOwner {
        address oldOracle = aiOracleAddress;
        aiOracleAddress = _newOracle;
        emit OracleUpdated(oldOracle, _newOracle);
    }

    function verifyAndMint(address to, uint256 id, uint256 amount, bytes memory data) external onlyOracle {
        _mint(to, id, amount, data);
        emit ImpactMinted(to, id, amount);
    }
}
