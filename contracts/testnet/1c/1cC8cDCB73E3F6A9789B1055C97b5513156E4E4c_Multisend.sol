// SPDX-License-Identifier: MIT
pragma solidity >0.8.0 <=0.9.0;

contract Multisend {
  function sendBatch(address[] calldata _addresses) public payable {
    for(uint i = 0; i < _addresses.length; i++) {
      payable(_addresses[i]).transfer(msg.value/_addresses.length);
    }
  }
}