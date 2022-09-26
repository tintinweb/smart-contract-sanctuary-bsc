//SPDX-License-Identifier: UNLICENSED
pragma solidity <=0.8.10;

contract MyPets {
  string public MyDog;

  constructor(string memory _myDog) {
    MyDog = _myDog;
  }

  function updateDog(string memory _myDog) external {
    MyDog = _myDog;
  }
}