/**
 *Submitted for verification at BscScan.com on 2023-03-09
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

contract BSEXToken {
mapping(address => uint256) private _balances;
mapping(address => mapping(address => uint256)) private _allowances;

string private constant _name = "BSEX Token";
string private constant _symbol = "BSB";
uint8 private constant _decimals = 18;
uint256 private constant _totalSupply = 500000000 * 10**18;
address private _owner;

event Transfer(address indexed from, address indexed to, uint256 value);
event Approval(address indexed owner, address indexed spender, uint256 value);

constructor() {
    _balances[msg.sender] = _totalSupply;
    _owner = msg.sender;
    emit Transfer(address(0), msg.sender, _totalSupply);
}

function name() external pure returns (string memory) {
    return _name;
}

function symbol() external pure returns (string memory) {
    return _symbol;
}

function decimals() external pure returns (uint8) {
    return _decimals;
}

function totalSupply() external pure returns (uint256) {
    return _totalSupply;
}

function balanceOf(address account) external view returns (uint256) {
    return _balances[account];
}

function transfer(address to, uint256 amount) external returns (bool) {
    require(to != address(0), "ERC20: transfer to the zero address");
    require(amount > 0, "ERC20: amount must be greater than zero");
    require(_balances[msg.sender] >= amount, "ERC20: insufficient balance");

    _balances[msg.sender] -= amount;
    _balances[to] += amount;

    emit Transfer(msg.sender, to, amount);
    return true;
}

function allowance(address owner, address spender) external view returns (uint256) {
    return _allowances[owner][spender];
}

function approve(address spender, uint256 amount) external returns (bool) {
    require(spender != address(0), "ERC20: approve to the zero address");

    _allowances[msg.sender][spender] = amount;

    emit Approval(msg.sender, spender, amount);
    return true;
}

function transferFrom(address from, address to, uint256 amount) external returns (bool) {
    require(from != address(0), "ERC20: transfer from the zero address");
    require(to != address(0), "ERC20: transfer to the zero address");
    require(amount > 0, "ERC20: amount must be greater than zero");
    require(_balances[from] >= amount, "ERC20: insufficient balance");
    require(_allowances[from][msg.sender] >= amount, "ERC20: insufficient allowance");

    _balances[from] -= amount;
    _balances[to] += amount;

    _allowances[from][msg.sender] -= amount;

    emit Transfer(from, to, amount);
    return true;
}

function increaseAllowance(address spender, uint256 addedValue) external returns (bool) {
    require(spender != address(0), "ERC20: approve to the zero address");
    _allowances[msg.sender][spender] += addedValue;

    emit Approval(msg.sender, spender, _allowances[msg.sender][spender]);
    return true;
}

function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool) {
    require(spender != address(0), "ERC20: approve to the zero address");
    require(_allowances[msg.sender][spender] >= subtractedValue, "ERC20: insufficient allowance");

    _allowances[msg.sender][spender] -= subtractedValue;

    emit Approval(msg.sender, spender, _allowances[msg.sender][spender]);
    return true;
}

function transferOwnership(address newOwner) external {
    require(msg.sender == _owner, "ERC20: Only owner can transfer ownership");
    _owner = newOwner;
}
}