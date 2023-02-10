/**
 *Submitted for verification at BscScan.com on 2023-02-10
*/

//PromiseCoin is a BEP20 token that represents promises to pay. It provides a secure and accountable way for individuals and businesses to make financial commitments, without the need for cash, traditional banking or financial institutions. 
// /$$$$$$$   /$$$$$$$$$|  //////////////////
// | $$__  $$ | $$____   |   ////////////////
// | $$  \ $$ | $$    \$$$.  ////////////////
// | $$$$$$$/ | $$           ////////////////
// | $$____/  | $$           ////////////////
// | $$       | $$     $$$   ////////////////
// | $$       | $$$$$$/  |   ////////////////
// |__/       |__________|   ////////////////
/////////////////////////////////////////////
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract Token {
    // Mapping of addresses to token balances
    mapping(address => uint) public balances;

    // Mapping of allowance for other addresses to transfer tokens on behalf of an owner
    mapping(address => mapping(address => uint)) public allowance;

    // Total token supply
    uint public totalSupply = 1000000000000 * 10 ** 18;
    // Token name
    string public name = "PromiseCoin";
    // Token symbol
    string public symbol = "_PROMC";
    // Number of decimals
    uint public decimals = 18;

    // Events
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);

     // Constructor
    constructor() {
        balances[msg.sender] = totalSupply;
    }

    // Returns the balance of the specified address
    function balanceOf(address owner) public view returns(uint) {
        return balances[owner];
    }

    // Transfers 'value' tokens to 'to' address
    function transfer(address to, uint value) public returns(bool) {
        require(balances[msg.sender] >= value, "balance too low");
        balances[to] += value;
        balances[msg.sender] -= value;
        emit Transfer(msg.sender, to, value);
        return true;
    }

    // Transfers 'value' tokens from 'from' address to 'to' address
    function transferFrom(address from, address to, uint value) public returns(bool) {
        require(balances[from] >= value, "balance too low");
        require(allowance[from][msg.sender] >= value, "allowance too low");
        balances[to] += value;
        balances[from] -= value;
        emit Transfer(from, to, value);
        return true;
    }

    // Allows 'spender' to transfer 'value' tokens on behalf of 'msg.sender'
    function approve(address spender, uint value) public returns(bool) {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    // Allows contract owner to mint new coins
    function mint(address receiver, uint amount) public {
        require(msg.sender == address(this), "Only contract owner can mint tokens");
        balances[receiver] += amount;
        totalSupply += amount;
        emit Transfer(address(0), receiver, amount);
    }
}