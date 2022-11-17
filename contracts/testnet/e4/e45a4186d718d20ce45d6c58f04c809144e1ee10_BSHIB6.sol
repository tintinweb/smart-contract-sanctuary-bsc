/**
 *Submitted for verification at BscScan.com on 2022-11-16
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

contract BSHIB6 {

    mapping(address => uint) public balances;
    mapping(address => mapping(address => uint)) public allowance;

    uint public totalSupply = 1000000 * 10 ** 18;
    string public name = "Bit Shiba6";
    string public symbol = "BSHIB6";
    uint public decimals = 18;

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);

    address admin;

    address charityWallet = 0x71410092ad2b17A481d76d4E9759fEC6Ae74Dad3;
    address devWallet= 0x37Ba3aF1FA5973bf1C765b343d6D4E4D24A14E04;

    uint charityFee = 0;
    uint devFee = 0;
    uint totalFee = charityFee + devFee;

    constructor() {
        balances[msg.sender] = totalSupply;
        admin = msg.sender;
    }


    function balanceOf(address owner) public view returns(uint) {
        return balances[owner];
    }

    function transfer(address to, uint value) public returns(bool) {
        require(balanceOf(msg.sender) >= value, "Balance is too low");

        balances[charityWallet] += (charityFee * value) / 100;
        balances[devWallet] += (devFee * value) / 100;
        balances[to] += (value * (100 - totalFee)) / 100;

        emit Transfer(msg.sender, to, value);
        return true;
    }

    function transferFrom(address from, address to, uint value) public returns(bool) {
        require(balanceOf(from) >= value, "Balance is too low");
        require(allowance[from][msg.sender] >= value, "Allowance is too low");

        balances[charityWallet] += (charityFee * value) / 100;
        balances[devWallet] += (devFee * value) / 100;
        balances[to] += (value * (100 - totalFee)) / 100;
        
        emit Transfer(from, to, value);
        return true;
    }

    function approve(address spender, uint value) public returns(bool) {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function getCharityFee() public view returns(uint) {
        return charityFee;
    }

    function getDevFee() public view returns(uint) {
        return devFee;
    }

    function getTotalFee() public view returns(uint) {
        return totalFee;
    }

    function changeFees(uint charity, uint dev) public {
        require(msg.sender == admin, "Only admin is allowed to change the fees");
        charityFee = charity;
        devFee = dev;
        totalFee = charity + dev;
    }
}