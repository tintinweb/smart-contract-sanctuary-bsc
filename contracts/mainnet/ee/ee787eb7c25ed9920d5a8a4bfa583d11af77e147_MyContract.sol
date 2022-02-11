/**
 *Submitted for verification at BscScan.com on 2022-02-06
*/

// File: contracts/events.sol

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
contract MyContract{
 

 event moneySent(address _from, address _to, uint _amount);
 
 constructor () {

 }
 
 
 function sendMoney(uint _amount) public returns(bool) {
    emit moneySent(msg.sender, msg.sender, _amount);
    return true;
 
 }
}