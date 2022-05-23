// SPDX-License-Identifier: MIT
pragma solidity >0.8.0 <=0.9.0;

contract Multisend {
  function sendBatch(address[] memory _addresses) public payable {
    uint len = _addresses.length;
    for(uint i = 0; i < len;) {
      payable(_addresses[i]).transfer(msg.value/len);
      unchecked { ++i; }
    }
  }
}