/**
 *Submitted for verification at BscScan.com on 2023-02-15
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract Token {
    address public founder = 0x2E54dFB1EB51AB40e7E1866a88593c50193d4Eba;
    address public lockupWallet = 0xeEca678a5b5C909879C6174B2b3f439460A4890b;
    uint256 public totalSupply = 100000000;
    uint256 public taxRate = 7;
    uint256 public lockupDuration = 365 days;
    mapping (address => uint256) public balanceOf;
    string public name = "FEMANZI";
    string public symbol = "RARAS";

    constructor()  {
        balanceOf[founder] = totalSupply;
    }

    function transfer(address _to, uint256 _value) public returns (bool) {
        require(balanceOf[msg.sender] >= _value, "Saldo insuficiente");
        require(balanceOf[_to] + _value >= balanceOf[_to], "Overflow");

        uint256 tax = (_value * taxRate) / 100;
        uint256 founderTax = (tax * 5) / 100;
        uint256 lockupTax = (tax * 2) / 100;

        balanceOf[msg.sender] -= _value;
        balanceOf[msg.sender] -= tax;
        balanceOf[_to] += _value;
        balanceOf[founder] += founderTax;
        balanceOf[lockupWallet] += lockupTax;

        emit Transfer(msg.sender, _to, _value, tax);

        return true;
    }

    function zeroTax() public onlyFounder {
        taxRate = 0;
    }

    modifier onlyFounder() {
        require(msg.sender == founder, "Acesso negado");
        _;
    }

    event Transfer(address indexed _from, address indexed _to, uint256 _value, uint256 _tax);
}