/**
 *Submitted for verification at BscScan.com on 2022-10-16
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract ZombiesFactoryBank {
    address public manager;

    struct Factory {
        uint256 totalInvested;
        uint256 amountWithdrawn;
        uint256 latestBuyCoinsTime;
        uint256 latestWithdrawalTime;
    }

    mapping(address => Factory) public factories;
    uint256 public totalFactories;
    uint256 public totalInvested;

    event BuyCoins(address _address, uint256 amount, address _ref);

    event SendMoneyToUser(address _user, uint256 _amount);

    modifier _onlyManager() {
        require(msg.sender == manager, "This funtion only executed by manger");
        _;
    }

    constructor() {
        manager = msg.sender;
    }

    function buyCoins(address ref) public payable {
        require(msg.sender != ref, "ref address cannot be main account");
        totalInvested += msg.value;
        if (factories[msg.sender].totalInvested == 0) {
            totalFactories++;
        }
        factories[msg.sender].totalInvested += msg.value;
        factories[msg.sender].latestBuyCoinsTime = block.timestamp;
        payable(manager).transfer((msg.value * 3) / 100);
        emit BuyCoins(msg.sender, msg.value, ref);
    }

    function sendMoneyToUser(address user, uint256 amount) public _onlyManager {
        factories[msg.sender].amountWithdrawn += amount;
        factories[msg.sender].latestWithdrawalTime = block.timestamp;
        payable(user).transfer(
            address(this).balance < amount ? address(this).balance : amount
        );
        emit SendMoneyToUser(user, amount);
    }
}