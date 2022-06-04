/**
 *Submitted for verification at BscScan.com on 2022-06-03
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

contract Child {
     uint256 public data;
     constructor(uint256 _data){
        data = _data;
     }
}

contract Factory {
      mapping(uint256 => Child) public children;
      uint256 public count = 0;
      address[] public childAddressList;
      function createChild(uint256 data) public {
         Child child = new Child(data);
         children[count] = child;
         count += 1;
         childAddressList.push(address(child));
      }
      function getChildAddress(uint256 _index) public view returns(address) {
          return address(children[_index]);
      }
}