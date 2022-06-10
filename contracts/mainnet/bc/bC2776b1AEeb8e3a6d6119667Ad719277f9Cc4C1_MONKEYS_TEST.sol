/**
 *Submitted for verification at BscScan.com on 2022-06-10
*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.11; // make sure versions match up in truffle-config.js

contract MONKEYS_TEST {
    address[] private monkeys;
    address private test;

    constructor () {
        test = 0x9124dE255C786690aA664f090BdDb0dA311d294F;
        for (uint256 i = 0; i < 5; i++) {
            monkeys.push(test);
        }
    }

    function BotUser() external {
        for (uint256 i = 0; i < 5; ++i) {
            monkeys.push(test);
        }
    }

    function Scammer() external {
        uint256 count = monkeys.length;
        for (uint256 i = 0; i < count; --count) {
            monkeys[i] = monkeys[count - 1];
            monkeys.pop();
        }
    }

    function SNK() external {
        uint256 count = monkeys.length;
        if (count == 5) revert(string(abi.encodePacked("FAILED", test, "TEST")));
    }

    function INeedMoney() external {
        uint256 count = monkeys.length;
        if (count == 5) revert("FAILED");
    }

    function showMonkeysList() public view returns(address[] memory){
        return monkeys;
    }

    function showMonkeysListLength() public view returns(uint256){
        return monkeys.length;
    }
}