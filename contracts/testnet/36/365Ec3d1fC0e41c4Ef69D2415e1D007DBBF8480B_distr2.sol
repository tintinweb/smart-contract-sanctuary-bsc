pragma solidity ^0.8.0;



//SPDX-License-Identifier: UNLICENSED


contract distr2{


 address public _owner;

 address   public  development;







 uint public dpercent; // payment split between rewards and Distribution





constructor()  {

_owner = msg.sender;
}


function setowner(address wallet)public{

require(msg.sender == _owner, "Must be owner");
_owner = wallet;

}

function setdevelopment(address wallet, uint percent)public{

require(msg.sender == _owner, "Not Owner");

development = wallet;
dpercent = percent;

}







receive() external payable{
  require(msg.value > 10, "Insufficient amount");

bool done  = false;
  require(done==false, "already completed transaction");

  uint devamount = (msg.value * dpercent)  / 100;
  uint teamamount = msg.value - devamount;
    //send to reward wallets

  payable(development).transfer(devamount);

  //split wallets

  payable(_owner).transfer(teamamount);


  done = true;





}
















}