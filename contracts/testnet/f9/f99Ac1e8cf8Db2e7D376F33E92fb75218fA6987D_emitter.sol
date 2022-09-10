/**
 *Submitted for verification at BscScan.com on 2022-09-10
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract emitter {
    event Contributed(address indexed account, uint amount);
    function trigger(uint max) external {
        uint i;
        while(i < max) {
            i++;
            emit Contributed(msg.sender, i * 1 ether);
        }
    }
}