/**
 *Submitted for verification at BscScan.com on 2023-02-15
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract BTCClone {
    address public owner;
    string public name = "BabyBitCoin";
    string public symbol = "BBC";
    uint8 public decimals = 8;
    uint256 public totalSupply = 21000000 * (10 ** decimals);
    uint256 public remainingSupply = totalSupply;
    uint256 public halvingInterval = 1460 days;
    uint256 public lastHalvingTime = block.timestamp;
    mapping(address => uint256) public balances;

    constructor() {
        owner = msg.sender;
        balances[msg.sender] = 100000 * (10 ** decimals); // Give the contract creator 100,000 tokens
        balances[address(this)] = totalSupply - balances[msg.sender];
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(balances[msg.sender] >= _value);
        require(balances[_to] + _value >= balances[_to]);
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }

    function halveSupply() public {
        require(block.timestamp >= lastHalvingTime + halvingInterval);
        require(remainingSupply > totalSupply / (2**16)); // Ensure a minimum of 1/65536th of the total supply remains after each halving
        remainingSupply = totalSupply - (totalSupply / (2**((block.timestamp - lastHalvingTime) / halvingInterval)));
        lastHalvingTime = block.timestamp;
        balances[address(this)] = remainingSupply;
        emit Halving(lastHalvingTime, remainingSupply);
    }

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Halving(uint256 indexed time, uint256 remainingSupply);
}