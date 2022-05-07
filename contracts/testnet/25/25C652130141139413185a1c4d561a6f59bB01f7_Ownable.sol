/**
 *Submitted for verification at BscScan.com on 2022-05-06
*/

// File: contracts/Ownable.sol

//SPDX-License-Identifier:MIT

pragma solidity ^0.8.4;


contract Ownable {
 
  address public  owner;

   constructor () {
     owner = msg.sender;
   }
   modifier onlyOwner {
       require(owner ==msg.sender,"caller is not Owner");
       _;
   }
   function ownerOf() public view returns (address){
       return owner;
   }
   
}

// File: contracts/HotalManagementSystem.sol



pragma solidity ^0.8.0;


contract HotalManagementSystem is Ownable {
   
   mapping(address =>Hotel) public hotel;
  
  struct Hotel {
      string name;
      uint256 price;
      string location;
      uint qty;
      uint booked;
      uint free;
  }

  constructor (){
     
  }

  modifier roomCost (uint _amount){
      require(hotel[msg.sender].price != _amount ,"Please provide right price");
      _;
  }

  function configureHotel (string memory name,uint price ,string memory location, uint qty) public onlyOwner {
      
      hotel[msg.sender] = Hotel(name,price,location,qty,0,0);
  }
  function booking (uint booked) public payable onlyOwner roomCost(msg.value) {
     
      hotel[msg.sender].booked = hotel[msg.sender].booked + booked;     
      hotel[msg.sender].free = hotel[msg.sender].qty - hotel[msg.sender].booked;     
  }


   

}