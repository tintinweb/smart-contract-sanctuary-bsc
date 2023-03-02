/**
 *Submitted for verification at BscScan.com on 2023-03-01
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract LockToken {
    string public name;
    string public symbol;
    uint256 public totalSupply;
    uint256 public lockedSupply;
    mapping(address => uint256) public balanceOf;
    mapping(address => uint256) public lockedBalance;
    uint256 public unlockTime;

    constructor() {
        name = "Lock Token";
        symbol = "LTK";
        totalSupply = 10000000 * 10 ** 18; // 10 million tokens with 18 decimal places
        lockedSupply = 9000000 * 10 ** 18; // 9 million tokens with 18 decimal places
        unlockTime = block.timestamp + 5 minutes; // Lock until 5 minutes from contract deployment
        balanceOf[msg.sender] = totalSupply;
        lockedBalance[msg.sender] = lockedSupply;
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(block.timestamp > unlockTime || balanceOf[msg.sender] - _value >= lockedBalance[msg.sender], "Locked balance cannot be transferred yet");
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
}