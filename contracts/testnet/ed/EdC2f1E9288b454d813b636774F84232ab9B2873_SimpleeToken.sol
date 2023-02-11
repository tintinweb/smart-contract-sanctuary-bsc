/**
 *Submitted for verification at BscScan.com on 2023-02-10
*/

pragma solidity ^0.8.15;

// SPDX-License-Identifier: MIT

contract SimpleeToken {
    string public name = "Simplee Token";
    string public symbol = "ST";
    uint8 public decimals = 18;
    uint256 public totalSupply = 10000000;

    mapping (address => uint256) public balances;

    constructor() {
        balances[msg.sender] = totalSupply;
    }

    function transfer(address _to, uint256 _value) public {
        require(balances[msg.sender] >= _value, "Insufficient balance");
        balances[msg.sender] -= _value;
        balances[_to] += _value;
    }
}