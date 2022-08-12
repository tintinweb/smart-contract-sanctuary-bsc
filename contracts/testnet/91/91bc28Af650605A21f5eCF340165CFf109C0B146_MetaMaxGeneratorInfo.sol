/**
 *Submitted for verification at BscScan.com on 2022-08-11
*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract MetaMaxGeneratorInfo {
    string public constant _GENERATOR = "https://mmx.finance";
    string public constant _VERSION = "v1.0.0";

    function generator() public pure returns (string memory) {
        return _GENERATOR;
    }

    function version() public pure returns (string memory) {
        return _VERSION;
    }
}