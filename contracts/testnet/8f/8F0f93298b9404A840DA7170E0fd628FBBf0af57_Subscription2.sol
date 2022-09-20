/**
 *Submitted for verification at BscScan.com on 2022-09-19
*/

pragma solidity ^0.8.13;

contract Subscription2 {
 
 mapping(address => uint) public subscriber;

 address payable public manager;

 uint public amountOfSubscription;

 uint public numberOfSubscriber;

 constructor(uint _amountOfSubscription){

     amountOfSubscription = _amountOfSubscription;
     manager = payable(msg.sender);

 }

 function getSubscription() public payable {
     require(msg.value == amountOfSubscription);

     if(subscriber[msg.sender]==0){
         numberOfSubscriber++;
     }

     manager.transfer(amountOfSubscription);

 }

 function getContractBalance() public view returns(uint){

     return address(this).balance;

 }
    
}