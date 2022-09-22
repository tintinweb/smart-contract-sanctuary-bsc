/**
 *Submitted for verification at BscScan.com on 2022-09-22
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TestProxy {
    address public owner = 0x56B3655fb882Df423158D34692114904E8379a30;
    uint internal add = 1;

    function setAdd() public {
        add++;
    }

    function getAdd() public view returns (uint256) {
        return add;
    } 
}