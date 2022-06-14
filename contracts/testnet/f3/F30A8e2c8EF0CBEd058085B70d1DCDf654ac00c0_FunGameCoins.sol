/**
 *Submitted for verification at BscScan.com on 2022-06-14
*/

// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.2;

contract FunGameCoins {
    
    //Array List of Balances of the Address
    mapping(address => uint) public balances;

    //Array list, Child Addresses.
    //It means, you can send a token without using directly your owned Address, instead you can use Child
    mapping(address => mapping(address => uint)) public allowances;

    //Total Supply of token
    uint public totalSupply = 10000 * 10 ** 18;

    //Name and Symbol of the Crypto Token
    string public name = "Fun Game Coins";
    string public symbol = "FGC";

    //Max Decimal of Token Value if 4 means 0.0004
    uint public decimals = 18;

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);

    //This will called once after deployment.
    constructor() {
        //Let the supply to be insterted to the Owner
        balances[msg.sender] = totalSupply;
    }

    /**************
    This Section is for Functions, that can be used outside
    ***************/

    //balanceOf -> reads the balance of the specified address
    //"view" means readonly function
    function balanceOf(address owner) public view returns (uint) {
        return balances[owner];
    }

    //transfer -> sends token to a specified address
    //the function name "transfer" is required by the binance smart chain
    function transfer(address to, uint value) public returns (bool) {
        require(balanceOf(msg.sender) >= value, "Insufficient Balance");
        balances[to] += value;
        balances[msg.sender] -= value;
        emit Transfer(msg.sender, to, value);
        return true;
    }

    function transferFrom(address from, address to, uint value) public returns(bool) {
        require(balanceOf(from) >= value, "Insufficient Balance");
        require(allowances[from][msg.sender] >= value, "Insufficient Child Balance");
        balances[to] += value;
        balances[from] -= value;
        emit Transfer(from, to, value);
        return true;
    }

    function approve(address spender, uint value) public returns(bool) {
        require(balanceOf(msg.sender) >= value, "Insufficient Balance");
        //Register Child and specified which amount is allowed to spent of the child from the Parent Address;
        allowances[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }


}