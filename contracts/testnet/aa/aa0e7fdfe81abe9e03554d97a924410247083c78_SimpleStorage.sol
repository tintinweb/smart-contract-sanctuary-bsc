/**
 *Submitted for verification at BscScan.com on 2022-11-13
*/

// SPDX-License-Identifier: GPL-3.0
//pragma solidity >=0.4.16 <0.9.0;
pragma solidity ^0.7.6;
contract SimpleStorage {
   
    string name;
   
   
   
    function set(string memory x) public {
        name = x;
    }
   
    function get() public view returns (string memory) {
        return name;
    }
   
}