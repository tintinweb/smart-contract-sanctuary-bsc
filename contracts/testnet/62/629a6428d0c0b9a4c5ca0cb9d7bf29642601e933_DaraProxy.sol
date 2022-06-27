/**
 *Submitted for verification at BscScan.com on 2022-06-26
*/

// SPDX-License-Identifier: MIT

// Current Version of solidity
pragma solidity ^0.8.7;

// Main coin information
contract DaraProxy {

    // Transfers
    event Signature(address indexed from, string sigText);
    
    // Event executed only ones uppon deploying the contract
    constructor() {
    }
    
    function signature(string memory sigText) external returns (bool) {
        emit Signature(msg.sender, sigText);
        return true;
    }
}