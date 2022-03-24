/**
 *Submitted for verification at BscScan.com on 2022-03-23
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;


contract MainStreetStaker {
    
    uint TOTAL_BANANA_BOUGHT;

    constructor() {}

    
    function deposit() external payable {
        TOTAL_BANANA_BOUGHT += msg.value;
    }

}