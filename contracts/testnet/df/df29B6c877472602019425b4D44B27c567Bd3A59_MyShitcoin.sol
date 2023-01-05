/**
 *Submitted for verification at BscScan.com on 2023-01-04
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

contract MyShitcoin {
    address payable public owner;
    string public name;
    string public symbol;
    uint public totalSupply;
    mapping(address => uint) public balances;

    constructor() public {
        owner = msg.sender;
        name = "TEST2";
        symbol = "TEST2";
        totalSupply = 10000;
        balances[owner] = 10000;
    }

    function sendCoins(address payable _to, uint _amount) public {
        require(balances[msg.sender] >= _amount && _amount > 0);
        balances[msg.sender] -= _amount;
        balances[_to] += _amount;
    }

    function buyCoins(uint _amount) public payable {
        // Calculer la taxe d'achat (5%)
        uint buyFee = _amount / 20;
        // S'assurer que l'acheteur envoie suffisamment d'Ether pour couvrir le coût de la crypto-monnaie et la taxe d'achat
        require(msg.value == _amount + buyFee);
        // Transférer la crypto-monnaie et la taxe d'achat au vendeur
        msg.sender.transfer(_amount);
        owner.transfer(buyFee);
        // Mettre à jour le solde de l'acheteur
        balances[msg.sender] += _amount;
        totalSupply += _amount;
    }

    function balanceOf(address _owner) public view returns (uint balance) {
        return balances[_owner];
    }
}