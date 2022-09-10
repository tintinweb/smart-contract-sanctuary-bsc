/**
 *Submitted for verification at BscScan.com on 2022-09-09
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

contract ERC20 {
    string public constant name = "ERC20-Workshop";
    string public constant symbol = "ERC20";
    uint8 public constant decimals = 18;

    uint256 public totalSupply;

    mapping(address => uint256) public _balances;
    mapping(address => mapping(address => uint256)) public _allowances;
    // map (token owner => map ( spender => amount))

    event Transfer(address from, address to, uint256 amount);

    constructor() {
        uint256 amount = 100e6 * 1e18;
        _balances[msg.sender] = amount;
        emit Transfer(address(0), msg.sender, amount);
        totalSupply = amount;
    }

    function balanceOf(address owner) public view returns (uint256) {
        return _balances[owner];
    }

    function transfer(address to, uint256 amount) public returns (bool) {
        uint256 fromAmount = _balances[msg.sender];

        require(fromAmount >= amount, "ERC20: balance exceeded");

        _balances[msg.sender] = fromAmount - amount;
        _balances[to] += amount;

        emit Transfer(msg.sender, to, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) public returns (bool) {
        require(_allowances[from][msg.sender] >= amount, "ERC20: insufficient amount");

        uint256 fromAmount = _balances[from];

        require(fromAmount >= amount, "ERC20: balance exceeded");

        _balances[from] = fromAmount - amount;
        _balances[to] += amount;

        emit Transfer(from, to, amount);
        return true;
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        _allowances[msg.sender][spender] = amount;

        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }
}