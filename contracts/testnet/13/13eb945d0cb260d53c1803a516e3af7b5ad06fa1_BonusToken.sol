/**
 *Submitted for verification at BscScan.com on 2022-11-07
*/

// SPDX-License-Identifier: -
pragma solidity >= 0.8.17;


contract BonusToken {

    address public minter;
    mapping (address => uint) public balances;

    event BonusAdded(address to, uint amount);
    event BonusSent(address from, address to, uint amount);

    constructor() {
        minter = msg.sender; 
    }

    // добавить бонус сотруднику с адресом "toAddress" в количестве "amount"
    // метод может вызвать только админ бонусов "minter"
    function addBonus(address toAddress, uint amount) public {

        address txSenderAddress = msg.sender;

        require(txSenderAddress == minter, "only minter can add bonus");

        uint oldBalance = balances[toAddress];
        uint newBalance = oldBalance + amount;

        require(newBalance > oldBalance, "bonus balance overflow");

        balances[toAddress] = newBalance;

        emit BonusAdded(toAddress, amount);
    }

    // отправить бонусы на адрес "toAddress" в количестве "amount"
    // метод может вызвать любой у кого есть бонусы
    function sendBonus(address toAddress, uint amount) public {

        require(amount <= balances[msg.sender], "insufficient bonus balance");

        balances[msg.sender] -= amount;
        balances[toAddress] += amount;

        emit BonusSent(msg.sender, toAddress, amount);
    }

}