/**
 *Submitted for verification at BscScan.com on 2022-09-10
*/

//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

contract Bobelr {
  string public name;
  string public alia;
  bytes private data;

  address public grantAndFundReceiver;

  constructor() {
    name = "Isaac J";
    alia = "Bobman";
  } 

  function setData(bytes memory newData) public {
    data = newData;
  }

  function getData() public view returns(bytes memory) {
    return data;
  }
}