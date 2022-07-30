/**
 *Submitted for verification at BscScan.com on 2022-07-30
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

interface IBal {
    function balanceOf(address user) external returns (uint256);
}

contract MulticallBalance {
    function call(address target, address[] memory addresses) external returns (uint256[] memory) {
        uint256[] memory balances = new uint256[](addresses.length);

        for (uint256 i = 0; i < addresses.length; i++){
            balances[i] = IBal(target).balanceOf(addresses[i]);
        }

        return balances;
    }
}