/**
 *Submitted for verification at BscScan.com on 2022-09-02
*/

// Code written by MrGreenCrypto
// SPDX-License-Identifier: None

pragma solidity 0.8.16;

contract ArrayPushTest {
    address[] public array;
    constructor() {}

    function testArrayPush(uint256 amount) external {
        for(uint256 i= 0; i<amount; i++) array.push(msg.sender);
    }
}