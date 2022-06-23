/**
 *Submitted for verification at BscScan.com on 2022-06-22
*/

pragma solidity 0.8.7;

// SPDX-License-Identifier: GPL-3.0

contract Counter{
    uint256 public count=0;

    function setCount()public{
        count++;
    }
}