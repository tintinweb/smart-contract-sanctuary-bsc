// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

contract Presalev1 {
    mapping(address => bool) public goldList;

    function addGoldList(address newAddress) external {
        goldList[newAddress] = true;
    }
}