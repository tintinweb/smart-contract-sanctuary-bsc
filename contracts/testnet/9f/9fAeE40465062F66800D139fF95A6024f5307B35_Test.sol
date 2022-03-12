/**
 *Submitted for verification at BscScan.com on 2022-03-12
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract Test{

    mapping(uint256 => string) public maps;

    function addMap(uint256 key, string memory name) public {
        maps[key] = string(abi.encodePacked("I", "am", name));
    }
}