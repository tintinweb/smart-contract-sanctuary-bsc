/**
 *Submitted for verification at BscScan.com on 2023-01-11
*/

// SPDX-License-Identifier: agpl-3.0

pragma solidity ^0.8.0;


contract Gmx {

    address[] public allTrades;
    event Trade(address indexed user);

    function trade() external {

        allTrades.push(msg.sender);
        emit Trade(msg.sender);

    }
}