/**
 *Submitted for verification at BscScan.com on 2022-02-12
*/

// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.11;

//defined interface needed to interact with other contract
interface Ibusinesslogic {
  function getAge() external pure returns(uint);
}

contract MainContract {
  //set an admin address
  address public admin;
  //interface contract address
  Ibusinesslogic public businesslogic;
  //the admin is the owner
  constructor() {
    admin = msg.sender;
  }

 
  //function to upgrade the contract to point to execute function
  function upgrade(address _businesslogic) external {
    require(msg.sender == admin, 'only admin');
    businesslogic = Ibusinesslogic(_businesslogic);
  }


  //call the getAge function using the businesslogic function
  function getAge() external view returns(uint) {
    return businesslogic.getAge();
  }
}