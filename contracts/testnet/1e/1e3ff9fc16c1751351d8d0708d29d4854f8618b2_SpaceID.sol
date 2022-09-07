/**
 *Submitted for verification at BscScan.com on 2022-09-07
*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;

contract SpaceID {
    event NameRegistered(string name,address indexed owner);
    function register(string calldata name, address owner) external payable {
        emit NameRegistered(name, owner);
    }
}