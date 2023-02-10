/**
 *Submitted for verification at BscScan.com on 2023-02-09
*/

//SPDX-License-Identifier: MIT
pragma solidity 0.8.18;
 
contract Token {
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;

    mapping(address => uint256) private _balance;
    mapping(address => mapping(address => uint256)) private _allowance;

    event Approval(address indexed owner, address indexed spender, uint256 amount);
    event Transfer(address indexed sender, address indexed recipient, uint256 amount);
    
    constructor() {
        name = "Test Token";
        symbol = "TT";
        decimals = 18;
        totalSupply = 10 ether;
        _balance[msg.sender] = totalSupply;
        emit Transfer(address(0), msg.sender, totalSupply);
    }

    function balanceOf(address owner) external view returns(uint256) {
        return _balance[owner];
    }

    function allowance(address owner, address spender) external view returns(uint256) {
        return _allowance[owner][spender];
    }

    function approve(address spender, uint256 amount) external returns(bool) {
        _allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transfer(address recipient, uint256 amount) external returns(bool) {
        require(_balance[msg.sender] >= amount, "Low Balance.");
        _balance[msg.sender] -= amount;
        _balance[recipient] += amount;
        emit Transfer(msg.sender, recipient, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external returns(bool) {
        require(_balance[sender] >= amount, "Low Balance.");
        require(_allowance[sender][msg.sender] >= amount, "Low Allowance.");
        _allowance[sender][msg.sender] -= amount;
        _balance[sender] -= amount;
        _balance[recipient] += amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }
}