/**
 *Submitted for verification at BscScan.com on 2023-01-03
*/

//  SPDX-License-Identifier: MIT
pragma solidity ^0.8.2; // compiler version

contract Token{
    uint public total_supply = 100000000;
    string public token_name = "Rubik"; // token name - human - readable 
    string public symbol = "RBK";
    uint public decimals = 18; // will set the divisibility of your token 

    // mapping
    mapping(address => uint) public _balance; // bal will constantly update
    mapping(address => mapping(address => uint)) public allowance; //[allowance - how much spender is allowed to spend]
    
    // event transfer
    event Transfer(address indexed from, address indexed to, uint value);
    // event emitted during an approval
    event Approval(address indexed owner, address indexed spender, uint value);

    constructor(){ 
    // send supply of tokens to the address that deployed smart contract
    _balance[msg.sender] = total_supply;
    }

    function balanceOf(address owner) public view returns(uint) {
    // return mapping balance of the owner
    return _balance[owner]; 
    }

    function transfer(address to, uint value) public returns(bool){
    // ensure sender has enough
    require(balanceOf(msg.sender)>= value, 'balance not enough');
    _balance[to] += value;
    _balance[msg.sender] -= value;
    // smart contracts emit event which external s/w e.g wallet
    emit Transfer(msg.sender, to , value);
    return true;
    }

    // Delegate a Transfer Functionn
    function approve(address spender, uint value) public returns(bool){
        allowance[msg.sender][spender] = value; // spender can spend *value* amount belonging to sender 
        emit Approval(msg.sender, spender, value); // emit approval event to allow spending
        return true;
    }

    // 
    function transferFrom(address from, address to, uint value) public returns(bool){
        // check allowance mapping if spender is approved
        require(allowance[from][msg.sender] >=value, "allowance too low");  
        // check balance
        require(balanceOf(from) >= value, "balance is too low"); 
        // update mappings balances of sender & recipient 
        _balance[to] += value;
        _balance[from] -= value;
        // emit event
        emit Transfer(from, to, value);
        return true;
    }
}