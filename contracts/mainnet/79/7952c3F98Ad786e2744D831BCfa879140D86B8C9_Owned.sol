/**
 *Submitted for verification at BscScan.com on 2022-07-02
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

contract Owned{
    address payable owner;

    constructor() {
        owner = payable(msg.sender);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "You are not allowed");
        _;
    }
}