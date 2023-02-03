/**
 *Submitted for verification at BscScan.com on 2023-02-03
*/

// File: gameta.sol

pragma solidity ^0.5.17;

contract Ownable {
  address public owner;
  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  constructor() public {
    owner = msg.sender;
  }

  modifier onlyOwner() { 
    require(msg.sender == owner);
    _;
  }

  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }
}


contract SignContract is Ownable{

  mapping(address => uint) register;
  
  event UserRecord(address indexed owner, uint256 numbers);

  function getUserRecord(address user) public view returns (uint num) {
    return register[user];
  }

  function setUserRecord(address user, uint num) public onlyOwner {
    register[user] = num;
    emit UserRecord(user,num);
  }

  function userSign() public {
    register[msg.sender]++;
  }

  function getMine() public view returns (uint num) {
    return register[msg.sender];
  }
  
}