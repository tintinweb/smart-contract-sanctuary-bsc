/**
 *Submitted for verification at BscScan.com on 2022-06-28
*/

//SPDX-License-Identifier: Unlicense
pragma solidity ^0.6.6;

contract Router {
    uint256 public number;

    constructor(uint256 _initialNumber) public {
        number = _initialNumber;
    }

    function increment(uint256 _value) public {
        number = number + _value;
    }

    function reset() public {
        number = 0;
    }
}