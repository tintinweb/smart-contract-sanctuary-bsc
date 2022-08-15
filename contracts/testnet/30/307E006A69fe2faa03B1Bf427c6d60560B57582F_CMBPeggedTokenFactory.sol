// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Ownable.sol";
import "./CMBPeggedTokenUpgradeableProxy.sol";

interface IProxyInitialize {
    function initialize(string calldata name, string calldata symbol, uint8 decimals, uint256 amount, bool mintable, address owner) external;
}

contract CMBPeggedTokenFactory is Ownable{

    address public logicImplement;

    event TokenCreated(address indexed token);

    constructor(address _logicImplement) {
        logicImplement = _logicImplement;
    }

    function createToken(string calldata name, string calldata symbol, uint8 decimals, uint256 amount, bool mintable, address erc20Owner, address proxyAdmin) external onlyOwner returns (address) {
        CMBPeggedTokenUpgradeableProxy proxyToken = new CMBPeggedTokenUpgradeableProxy(logicImplement, proxyAdmin, "");

        IProxyInitialize token = IProxyInitialize(address(proxyToken));
        token.initialize(name, symbol, decimals, amount, mintable, erc20Owner);
        emit TokenCreated(address(token));
        return address(token);
    }
}