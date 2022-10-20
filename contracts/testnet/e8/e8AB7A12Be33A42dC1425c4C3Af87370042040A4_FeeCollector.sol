/**
 *Submitted for verification at BscScan.com on 2022-10-19
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

contract FeeCollector {
    address public owner;

    constructor () {
        owner = msg.sender;
 }
}