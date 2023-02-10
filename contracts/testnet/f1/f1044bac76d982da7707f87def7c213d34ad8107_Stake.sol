/**
 *Submitted for verification at BscScan.com on 2023-02-09
*/

// File: contracts/ercWith.sol


pragma solidity ^0.8.9;


contract Stake {

    error InvalidAmount();
    constructor() {
    }
    function stake(uint256 amount) public {
        if (amount==0) revert InvalidAmount();
    }
}