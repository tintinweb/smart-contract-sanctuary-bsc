/**
 *Submitted for verification at BscScan.com on 2022-08-31
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;
contract MetaCoin{
    mapping(address => uint) balances;
    event Transfer(address indexed _from, address indexed _to, uint);
    constructor(){
        balances[msg.sender]=10000;
    }
    function sendCoin(address receiver, uint amount) public returns(bool){
        if(balances[msg.sender]<amount) return false;
        balances[msg.sender]-=amount;
        balances[receiver]+=amount;
        emit Transfer(msg.sender,receiver,amount);
        return true;
    }
    function getBalance(address addr) public view returns(uint){
        return balances[addr];
    }
}