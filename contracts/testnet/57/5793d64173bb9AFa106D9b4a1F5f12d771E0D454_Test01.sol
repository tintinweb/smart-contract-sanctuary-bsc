/**
 *Submitted for verification at BscScan.com on 2023-02-05
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract Test01 {
    uint256 public number;

    function setnumber(uint256 x) public {
        number = x;
    }

    function getnumber() public view returns (uint256) {
        return number;
    }
}