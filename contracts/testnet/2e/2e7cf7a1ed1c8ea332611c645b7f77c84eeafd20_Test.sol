/**
 *Submitted for verification at BscScan.com on 2022-03-12
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract Test{

    function test1() public pure returns (string memory){
        string memory str = string(abi.encodePacked("I", "am", "damon"));
        return str;
    }
}