/**
 *Submitted for verification at BscScan.com on 2023-03-31
*/

// SPDX-License-Identifier: YK
pragma solidity ^0.8.19;

contract TokenDepositContract {
    address payable public walletAddress;
    
    constructor() {
        walletAddress = payable(0xFfE1c8d2343aF7f6056A11cD068AFebB37F3bf80);
    }

    function deposit(uint256 _amount) public {
        require(_amount > 0, "Amount must be greater than 0");
        walletAddress.transfer(_amount);
    }
}