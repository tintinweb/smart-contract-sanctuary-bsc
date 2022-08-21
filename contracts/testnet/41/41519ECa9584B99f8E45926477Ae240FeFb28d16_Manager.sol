// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.7.6;

import "./ManagerInterface.sol";
import "./Ownable.sol";

contract Manager is ManagerInterface, Ownable {
    mapping(address => bool) safeNFTAddr;

    function safeNFT(address _address) external view override returns (bool) {
        return safeNFTAddr[_address];
    }

    function setSafeNFT(address _address) external onlyOwner {
        safeNFTAddr[_address] = true;
    }

    function removeSafeNFT(address _address) external onlyOwner {
        safeNFTAddr[_address] = false;
    }
}