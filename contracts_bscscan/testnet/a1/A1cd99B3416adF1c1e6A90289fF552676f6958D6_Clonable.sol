// SPDX-License-Identifier: unlicense OR MIT
pragma solidity 0.8.11;

contract Clonable {
 string public name;
 uint256 public generation;

 constructor(string memory _name,  uint256 _gen){
  name = _name;
  generation = _gen;
 }


}