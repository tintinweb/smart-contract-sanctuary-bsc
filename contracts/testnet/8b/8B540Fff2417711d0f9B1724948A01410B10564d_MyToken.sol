// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract MyToken {
  string public name = "Sample Token";
  string public symbol = "sToken";

  //Example of Setter & Geter 

  uint public count;

  function increaseCount() public {
    count += 5;
  }
  function decreaseCount() public {
    count -= 5;
  }

  //Datatypes

  bool public defaultBoo; // false
  uint public defaultUint; // 0
  int public defaultInt; // 0
  address public defaultAddr; // 0x0000000000000000000000000000000000000000

  //Variable 

  // State variables are stored on the blockchain.
  string public text = "Hello";
  uint public num = 123;

    function doSomething() public view returns (uint, uint, address){
        // Local variables are not saved to the blockchain.
        uint i = 456;

        // Here are some global variables
        uint timestamp = block.timestamp; // Current block timestamp
        address sender = msg.sender; // address of the caller
        return (i, timestamp, sender);
    }



}