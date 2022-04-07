/**
 *Submitted for verification at BscScan.com on 2022-04-07
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;

contract SetValue {
    uint public value;

    function setValue(uint _value) public {
        value = _value;
    }
}