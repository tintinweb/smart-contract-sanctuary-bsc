/**
 *Submitted for verification at BscScan.com on 2022-12-02
*/

// SPDX-License-Identifier: MIT
    pragma solidity >=0.8.7;
    contract AddTotal {
     uint256 public myTotal = 0;

          function addTotal(uint8 _myArg) public {
        myTotal = myTotal + _myArg;
            }
    }