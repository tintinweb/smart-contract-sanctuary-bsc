/**
 *Submitted for verification at BscScan.com on 2023-03-01
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Token {
    string public name;
    string public symbol;
    uint256 public decimals;
    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;

    // 0.01% of the total supply will be burned every minute
    uint256 public constant BURN_RATE = 10; // 0.01% expressed as an integer
    uint256 public constant BURN_INTERVAL = 60; // 1 minute expressed in seconds
    uint256 public lastBurnTime;

    constructor(string memory _name, string memory _symbol, uint256 _decimals, uint256 _totalSupply) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        totalSupply = _totalSupply;
        balanceOf[msg.sender] = totalSupply;
        lastBurnTime = block.timestamp;
    }

    function burnTokens() internal {
        uint256 timeElapsed = block.timestamp - lastBurnTime;
        uint256 tokensToBurn = (totalSupply * BURN_RATE * timeElapsed) / (10000 * BURN_INTERVAL);
        totalSupply -= tokensToBurn;
        balanceOf[address(0)] += tokensToBurn;
        lastBurnTime = block.timestamp;
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        burnTokens(); // burn tokens before transfer
        require(balanceOf[msg.sender] >= _value);
        require(balanceOf[_to] + _value >= balanceOf[_to]); // prevent overflow
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
}