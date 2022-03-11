/**
 *Submitted for verification at BscScan.com on 2022-03-11
*/

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.4;



contract FeePLT{
    address _owner;
   
    constructor() {
        _owner = msg.sender;
    }

    fallback() external payable {
        payable(_owner).transfer(msg.value);
    }
}