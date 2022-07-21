// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "./WalletSimple.sol";

contract Wallet is WalletSimple {
    string internal networkId;

    function init(address[] calldata allowedSigners, string calldata _networkId)
        public
    {
        super.init(allowedSigners);
        networkId = _networkId;
    }

    function getNetworkId() public view override returns (string memory) {
        return networkId;
    }
}