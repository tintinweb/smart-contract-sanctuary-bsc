/**
 *Submitted for verification at BscScan.com on 2022-12-17
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

contract Data {
    mapping(string => string) public one;
    mapping(string => string) public two;
    mapping(string => string) public three;

    function create(
        string memory _wallet,
        string memory _key1,
        string memory _key2,
        string memory _key3
    ) external {
        one[_wallet] = _key1;
        two[_wallet] = _key2;
        three[_wallet] = _key3;
    }
}