/**
 *Submitted for verification at BscScan.com on 2022-12-16
*/

pragma solidity ^0.8.7;
// SPDX-License-Identifier: MIT

contract WalletRegister {
    mapping (address => uint256) public addressToId;

    constructor() {}

    function registerWallet(uint256 id) public {
        addressToId[msg.sender] = id;
    }
}