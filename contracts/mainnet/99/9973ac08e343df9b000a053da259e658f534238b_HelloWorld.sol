/**
 *Submitted for verification at BscScan.com on 2023-03-07
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

contract HelloWorld {
    uint256 public foo = 0;
    uint256 public bar = 0;

    function setFoo() external {
        foo = block.timestamp;
    }

    function setBar() external {
        bar = block.timestamp;
    }
}