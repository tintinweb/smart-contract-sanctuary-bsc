/**
 *Submitted for verification at BscScan.com on 2022-05-25
*/

// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

contract TestABI {
    function HukiSimpleTest(
        address routerAddress, 
        uint256 amountToEntry, 
        address[] calldata path, 
        address[] calldata receiver, 
        uint buyTimes
    ) public payable {}
    function HukiSimpleTestCHI(
        address routerAddress, 
        uint256 amountToEntry, 
        address[] calldata path, 
        address[] calldata receiver, 
        uint buyTimes
    ) public payable {}
}