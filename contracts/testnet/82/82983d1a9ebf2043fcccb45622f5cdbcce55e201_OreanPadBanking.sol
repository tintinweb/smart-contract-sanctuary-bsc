/**
 *Submitted for verification at BscScan.com on 2022-10-05
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract OreanPadBanking {
    address private owner;
    address public manager;

    event Deposit(address _address, uint256 amount);

    modifier _onlyManager() {
        require(msg.sender == manager, "This funtion only executed by manger");
        _;
    }

    constructor(address _manager) {
        owner = msg.sender;
        manager = _manager;
    }

    function deposit() public payable {
        payable(manager).transfer((msg.value * 3) / 100);
        emit Deposit(msg.sender, msg.value);
    }

    function sendReward(address user, uint256 amount) public _onlyManager {
        payable(user).transfer(
            address(this).balance < amount ? address(this).balance : amount
        );
    }
}