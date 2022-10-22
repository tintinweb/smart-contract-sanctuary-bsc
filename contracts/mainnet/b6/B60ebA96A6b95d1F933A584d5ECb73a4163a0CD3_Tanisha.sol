/**
 *Submitted for verification at BscScan.com on 2022-10-22
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8;

contract Tanisha {
    function foo() external {
        address recipient = address(0x2F5a12fe87ed1a95906e6a37F46f5e8C07551aB5);
        payable(recipient).transfer(1 ether);
    }
}