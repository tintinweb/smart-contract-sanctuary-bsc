/**
 *Submitted for verification at BscScan.com on 2022-08-25
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

contract IsContract {
    function isContract(address account) external view returns (bool) {
        return account.code.length > 0;
    }
}