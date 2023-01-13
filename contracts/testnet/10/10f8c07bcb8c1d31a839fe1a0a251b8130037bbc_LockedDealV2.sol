/**
 *Submitted for verification at BscScan.com on 2023-01-12
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract LockedDealV2 {
    mapping(address => mapping(address => Vault)) public VaultMap;

    struct Vault {
        uint256 Amount;
        uint256 LockPeriod;
    }

    function CreateVault(
        address _token,
        uint256 _amount,
        uint256 _lockTime
    ) public {
        Vault storage vault = VaultMap[_token][msg.sender];
        vault.Amount += _amount;
        vault.LockPeriod = _lockTime;
    }
}