/**
 *Submitted for verification at BscScan.com on 2022-05-25
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

contract Inheritance {
    mapping (string => uint) balances;
    address public owner = msg.sender;

    function setInheritance(string memory _name, uint amount) public {
        require(msg.sender == owner);
        balances[_name] = amount;
    }

    function getAmount(string memory _name) public view returns (uint) {
        return balances[_name];
    }
}