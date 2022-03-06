/**
 *Submitted for verification at BscScan.com on 2022-03-05
*/

pragma solidity ^0.5.0;

contract TestEvent {
   event Deposit(address indexed _from, bytes32 indexed _id, uint _value);
   function deposit(bytes32 _id) public payable {      
      emit Deposit(msg.sender, _id, msg.value);
   }
}