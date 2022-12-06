/**
 *Submitted for verification at BscScan.com on 2022-12-06
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

contract DemoUpgrade {
    address public walletAddress;

    function setAddress() public {
        walletAddress = msg.sender;
    }
}