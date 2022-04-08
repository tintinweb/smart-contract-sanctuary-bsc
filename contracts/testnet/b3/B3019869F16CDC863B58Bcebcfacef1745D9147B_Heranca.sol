/**
 *Submitted for verification at BscScan.com on 2022-04-07
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

contract Heranca {

    mapping(string => uint) money;

    function setValue(string memory _name, uint value) public {
        money[_name] = value;
    }

    function getValue(string memory _name) public view returns(uint){
        return money[_name];
    }
}