/**
 *Submitted for verification at BscScan.com on 2022-06-19
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;


contract preSale {
    uint256 public last;

    function buy() public payable returns(uint256) {
        last = msg.value;
        return last;
    }
}