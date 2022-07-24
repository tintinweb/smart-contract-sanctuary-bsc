/**
 *Submitted for verification at BscScan.com on 2022-07-23
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface MintToken {
    function mint(uint256 value) external;
}

contract Test {
    MintToken public amint = MintToken(0x62EDcF53a7AF5831AfC3a272575E7C9AD7B3300B);
    function T1(uint256 value) public {
        amint.mint(value);
    }
    constructor(){
    }
}