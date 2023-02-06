/**
 *Submitted for verification at BscScan.com on 2023-02-06
*/

//"SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract blabla {
    string public constant name = "bla";
    string public constant symbol = "GBAI";
    uint256 public totalSupply = 100;

    mapping(address => uint256) public balanceOf;
    mapping(address => bool) public blacklistedAddresses;

    bool public tradingPaused = false;

    constructor() public {
        balanceOf[msg.sender] = totalSupply;
    }

    function getBalance(address _address) public view returns (uint256) {
        return balanceOf[_address];
    }

    function pauseTrading() public {
        require(msg.sender == address(this), "Only the contract owner can pause trading");
        tradingPaused = true;
    }

    function resumeTrading() public {
        require(msg.sender == address(this), "Only the contract owner can resume trading");
        tradingPaused = false;
    }

    function blackList(address _address) public {
        require(msg.sender == address(this), "Only the contract owner can blacklist addresses");
        blacklistedAddresses[_address] = true;
    }

    function transfer(address _to, uint256 _value) public {
        require(!tradingPaused, "Trading is currently paused");
        require(balanceOf[msg.sender] >= _value && _value > 0, "Transfer failed: insufficient funds");
        require(!blacklistedAddresses[_to], "Transfer failed: recipient address is blacklisted");
        require(_to != address(0), "Transfer failed: invalid recipient address");

        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
    }
}