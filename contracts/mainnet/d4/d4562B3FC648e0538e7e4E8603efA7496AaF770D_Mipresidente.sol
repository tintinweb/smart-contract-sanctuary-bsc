// SPDX-License-Identifier: MIT
pragma solidity ^0.5.4;

contract Mipresidente {

  uint public count;
  address public owner;

  mapping(uint => Vote) private votes;

  struct Vote {
    address _address;
    uint _candidate;
  }


  modifier restricted() {
    if (msg.sender == owner) _;
  }

  constructor() public {
    owner = msg.sender;
    count = 0;
  }

  function register(uint _candidate, uint _attempts) public payable {
    require(_attempts >= 1);
    require(msg.value >= 5e15*_attempts);
    for (uint i = 0; i < _attempts; i++) {
      votes[count]._address = msg.sender;
      votes[count]._candidate = _candidate;
      count += 1;
    }
  }

  function getCount(uint _candidate) public view returns (uint) {
    uint counter = 0;
    for (uint i = 0; i < count; i++) {
      if(votes[i]._candidate == _candidate) {
        counter += 1;
      }
    }
    return counter;
  }    


  function getUserVotes(uint _candidate, address _address) public view returns (uint) {
    uint counter = 0;
    for (uint i = 0; i < count; i++) {
      if(votes[i]._candidate == _candidate && votes[i]._address == _address) {
        counter += 1;
      }
    }
    return counter;
  } 

  
  function getList(uint _candidate) public view returns (address[] memory) {
    uint size = getCount(_candidate);
    address[] memory users = new address[](size);
    uint j = 0;
    for (uint i = 0; i < count; i++) {
      if(votes[i]._candidate == _candidate) {
        users[j] = votes[i]._address;
        j += 1;
      }
    }
    return users;
  }   
  
  function getBalance() public view returns (uint256) {
      return address(this).balance;
  }    

  function withdraw(address payable _to, uint256 _value) public restricted {
    uint256 balance = address(this).balance;
    require(_value <= balance); 
    _to.transfer(_value);
  }

}