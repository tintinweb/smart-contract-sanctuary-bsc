/**
 *Submitted for verification at BscScan.com on 2022-12-26
*/

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract Moonbank {

event Deposite (uint amount);
event Withdraw (uint amount);

address public owner = msg.sender;
receive() external payable{
    emit Deposite(msg.value);
}

function withdraw() external{
require( msg.sender == owner, "not owner");
emit Withdraw(address(this).balance);
selfdestruct(payable(msg.sender));
}

function getBalance() external view returns(uint){
return address(this).balance;
}

}