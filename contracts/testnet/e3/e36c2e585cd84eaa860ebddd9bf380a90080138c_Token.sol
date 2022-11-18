/**
 *Submitted for verification at BscScan.com on 2022-11-17
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.2;

contract Token{
    uint public total_supply = 150000000000000000000000000;
    string public token_name = "Max Bong Token";
    string public symbol = "MBT";
    uint public decimals = 18;


    mapping(address => uint) public balances;
    mapping(address => mapping(address => uint)) public allowance;
    // event transfer
    event Transfer(address indexed from, address indexed to, uint value);
    // event emitted during an approval
    event Approval(address indexed owner, address indexed spender, uint value);

    constructor(){ 
        // send supply of tokens to the address that deployed smart contract
        balances[msg.sender] = total_supply;
    }

    function balanceOf(address owner) public view returns(uint) {
        // return mapping balance of the owner
        return balances[owner]; 
    }

    function transfer(address to, uint value) public returns(bool){
        // ensure sender has enough
        value = value * 10**18;
        require(balanceOf(msg.sender)>= value, 'balance not enough');
        balances[to] += value;
        balances[msg.sender] -= value;
        // smart contracts emit event which external s/w e.g wallet
        emit Transfer(msg.sender, to , value);
        return true;
    }

    function approve(address spender, uint value) public returns(bool){
        allowance[msg.sender][spender] = value; // spender can spend *value* amount belonging to sender 
        emit Approval(msg.sender, spender, value); // emit approval event to allow spending
        return true;
    }

    function transferFrom(address from, address to, uint value) public returns(bool){
        // check allowance mapping if spender is approved
        require(allowance[from][msg.sender] >=value, "allowance too low");  
        // check balance
        require(balanceOf(from) >= value, "balance is too low"); 
        // update mappings balances of sender & recipient 
        balances[to] += value;
        balances[from] -= value;
        // emit event
        emit Transfer(from, to, value);
        return true;
    }

}