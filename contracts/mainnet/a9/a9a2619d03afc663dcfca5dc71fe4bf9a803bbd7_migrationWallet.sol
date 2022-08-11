/**
 *Submitted for verification at BscScan.com on 2022-08-10
*/

// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.12;

contract migrationWallet {
    mapping (address => address) public eth_wallet;

    function set_my_wallet(address _wallet) external {
        eth_wallet[msg.sender] = _wallet;
    }
}