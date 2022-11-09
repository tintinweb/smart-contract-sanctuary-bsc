/**
 *Submitted for verification at BscScan.com on 2022-11-08
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.13;

contract Entity{

    address public manager;

    constructor ()  {
        manager= msg.sender;
    }

}

error Unauthorized(address caller );
contract CreateEntity{
     mapping(address=>uint) public entities;
     address public manager;
     address public factory;

    event UserCreated(address user,uint256 timeCreated);
    event Credited(address user, uint256 amount);

    constructor ()  {
        manager=msg.sender;
        
    }
     modifier OnlyOwner() {
     if (msg.sender!=manager) {
        revert Unauthorized(msg.sender);
     }
    _;
    }

    modifier Onlymain(){
      require(msg.sender==factory);
      _;
    }
    function CreateUser() OnlyOwner public{
      Entity  created = new Entity();
      entities[address(created)]=0;
      emit UserCreated(address(created),block.timestamp);
    }
    
    // only token contract can call this functions
    function CreditUser(address _user, uint256 _amount) Onlymain public{
       entities[_user]=entities[_user]+_amount;
       emit Credited(_user, _amount);
    }
    


}
contract createEntityProxy{
     mapping(address=>uint) public entities;
     address public manager;
     address public factory;
     address public main_;
    

    constructor ()  {
        manager=msg.sender;
        // factory= _factory;
    }
     modifier OnlyOwner() {
     if (msg.sender!=manager) {
        revert Unauthorized(msg.sender);
     }
    _;
    }

   

    function setMain(address main__) OnlyOwner public returns (bool){
      main_=main__;
      return true;
    }
    function CreateUser()  public returns (bool isCreated) {
      (isCreated,)=main_.delegatecall(abi.encodeWithSelector(CreateEntity.CreateUser.selector));
      
    }
    
    // only token contract can call this functions
    function CreditUser(address _user, uint256 _amount)  public returns (bool isCredited){
        (isCredited,)= main_.delegatecall(abi.encodeWithSelector(CreateEntity.CreditUser.selector, _user,_amount));
        
    }
    


}