/**
 *Submitted for verification at BscScan.com on 2022-05-22
*/

/**
 *Submitted for verification at polygonscan.com on 2022-05-04
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

contract RewardContract {
    mapping(address => bool) public managers;

    constructor() {
        managers[msg.sender] = true;
    }

    function addManager(address _addr) external {
        require(managers[msg.sender] == true, 'Error, you are not allowed');
        managers[_addr] = true;
    }

    function removeManager(address _addr) external {
        require(managers[msg.sender] == true, 'Error, you are not allowed');
        managers[_addr] = false;
    }

    function fund() external payable {}

    function distributeRewards(address[] memory holders, uint amount) external {
        require(managers[msg.sender] == true, 'Error, you are not allowed');

        for (uint i = 0; i < holders.length; i ++) {
            payable(holders[i]).transfer(amount);
        }   
    }

    function withdrawFunds() external {
        require(managers[msg.sender] == true, 'Error, you are not allowed');
        uint balance = address(this).balance;
        payable(msg.sender).transfer(balance);
    }
}