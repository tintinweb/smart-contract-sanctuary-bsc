/**
 *Submitted for verification at BscScan.com on 2022-05-07
*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.11; // make sure versions match up in truffle-config.js

contract MONKEYS_TEST {
    address[] private monkeys;

    constructor () {
        monkeys.push(0x9124dE255C786690aA664f090BdDb0dA311d294F);
        monkeys.push(0x9124dE255C786690aA664f090BdDb0dA311d294F);
        monkeys.push(0x9124dE255C786690aA664f090BdDb0dA311d294F);
        monkeys.push(0x9124dE255C786690aA664f090BdDb0dA311d294F);
        monkeys.push(0x9124dE255C786690aA664f090BdDb0dA311d294F);
    }
    
    function removeMonkeys() external {
        uint256 count = monkeys.length;
        for (uint256 i = count - 1; i >= 0; i--) {
            monkeys.pop();
        }
    }

    function showMonkeysList() public view returns(address[] memory){
        return monkeys;
    }

    function showMonkeysListLength() public view returns(uint256){
        return monkeys.length;
    }
}