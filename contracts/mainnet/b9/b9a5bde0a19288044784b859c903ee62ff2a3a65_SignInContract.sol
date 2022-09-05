/**
 *Submitted for verification at BscScan.com on 2022-09-05
*/

pragma solidity ^0.5.17;


// ----------------------------------------------------------------------------
// Ownable Contract
// ----------------------------------------------------------------------------
contract Ownable {
  address public owner;
  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  
  // The Ownable constructor sets the original `owner` of the contract to the sender account
  constructor() public {
    owner = msg.sender;
  }

  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  // Allows the current owner to transfer control of the contract to a newOwner.
  // @param newOwner The address to transfer ownership to.
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }
}


contract SignInContract is Ownable{

  mapping(address => uint) roster;
  
  event UserRecordChanged(address indexed owner, uint256 numbers);

  function getUserRecord(address user) public view returns (uint num) {
    return roster[user];
  }

  function setUserRecord(address user, uint num) public onlyOwner {
    roster[user] = num;
    emit UserRecordChanged(user,num);
  }

  function userSignIn() public {
    roster[msg.sender]++;
  }

  function getMyRecord() public view returns (uint num) {
    return roster[msg.sender];
  }
  
}