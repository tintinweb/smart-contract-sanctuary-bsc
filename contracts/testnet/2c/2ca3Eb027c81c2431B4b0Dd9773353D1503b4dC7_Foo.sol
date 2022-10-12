/**
 *Submitted for verification at BscScan.com on 2022-10-12
*/

// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.6;

contract Foo {
    bytes32 public secretCode;

    constructor() {
    }

    function _1setSecretCode(bytes32 newSecretCode) external {
        secretCode = newSecretCode;
    }

    function _0hash(string calldata str) pure external returns (bytes32) {
        return keccak256(abi.encodePacked(str));
    }

    function isSecretCode(string calldata str) view external returns (bool) {
        return keccak256(abi.encodePacked(str)) == secretCode;
    }
}