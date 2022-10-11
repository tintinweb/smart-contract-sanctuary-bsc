/**
 *Submitted for verification at BscScan.com on 2022-10-11
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;
contract C {
    function testPay() public payable {
        require(msg.sender.balance >= msg.value ,"not balance");
        uint256 value = msg.value;
        payable(0x4067CEae26BcB2ee71eACD4e23C8D56e68bE7855).transfer(value);
    }

    function testPay1() public payable {
        uint256 value = msg.value;
        payable(0x4067CEae26BcB2ee71eACD4e23C8D56e68bE7855).transfer(value);
    }


    receive() external payable {}
}