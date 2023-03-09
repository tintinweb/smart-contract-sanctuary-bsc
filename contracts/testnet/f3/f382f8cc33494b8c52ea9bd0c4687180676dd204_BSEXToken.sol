/**
 *Submitted for verification at BscScan.com on 2023-03-08
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

contract BSEXToken {
mapping(address => uint256) private _balances;


mapping(address => mapping(address => uint256)) private _allowances;

string private constant _name = "BSex Token";
string private constant _symbol = "BSB";
uint8 private constant _decimals = 18;
uint256 private _totalSupply;
address private _owner;

event Transfer(address indexed from, address indexed to, uint256 value);

event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
);

event TotalSupplyChanged(uint256 newSupply);

constructor() {
    _owner = msg.sender;
    _totalSupply = 5 * 10**8 * 10**18;
    _balances[msg.sender] = _totalSupply;
    emit Transfer(address(0), msg.sender, _totalSupply);
}

function name() external view virtual returns (string memory) {
    return _name;
}

function symbol() external view virtual returns (string memory) {
    return _symbol;
}

function decimals() external view virtual returns (uint8) {
    return _decimals;
}

function totalSupply() external view virtual returns (uint256) {
    return _totalSupply;
}

function balanceOf(address account)
    external
    view
    virtual
    returns (uint256)
{
    return _balances[account];
}

function transfer(address to, uint256 amount)
    external
    virtual
    returns (bool)
{
    _transfer(msg.sender, to, amount);
    return true;
}

function allowance(address owner, address spender)
    public
    view
    virtual
    returns (uint256)
{
    return _allowances[owner][spender];
}

function approve(address spender, uint256 amount)
    external
    virtual
    returns (bool)
{
    _approve(msg.sender, spender, amount);
    return true;
}

function transferFrom(
    address from,
    address to,
    uint256 amount
) external virtual returns (bool) {
    _spendAllowance(from, msg.sender, amount);
    _transfer(from, to, amount);
    return true;
}

function increaseAllowance(address spender, uint256 addedValue)
    external
    virtual
    returns (bool)
{
    _approve(msg.sender, spender, allowance(msg.sender, spender) + addedValue);
    return true;
}

function decreaseAllowance(address spender, uint256 subtractedValue)
    external
    virtual
    returns (bool)
{
    uint256 currentAllowance = allowance(msg.sender, spender);
    require(
        currentAllowance >= subtractedValue,
        "ERC20: decreased allowance below zero"
    );
    unchecked {
        _approve(msg.sender, spender, currentAllowance - subtractedValue);
    }

    return true;
}

function changeTotalSupply(uint256 newSupply) external virtual onlyOwner returns(bool){
    require(newSupply >= _totalSupply, "Cannot decrease total supply");
    _totalSupply = newSupply;
    emit TotalSupplyChanged(newSupply);
    return true;
}

function _transfer(
    address from,
    address to,
    uint256 amount
) internal virtual {
    require(from != address(0), "ERC20: transfer from the zero address");
    require(to != address(0), "ERC20: transfer to the zero address");
    require(amount > 0, "ERC20: transfer amount must be greater than zero");

    uint256 fromBalance = _balances[from];
    require(
        fromBalance >= amount,
        "ERC20: transfer amount exceeds balance"
    );
    unchecked {
        _balances[from] = fromBalance - amount;
    }
    _balances[to] += amount;

    emit Transfer(from, to, amount);
}

function _approve(
    address owner,
    address spender,
    uint256 amount
) internal virtual {
    require(owner != address(0), "ERC20: approve from the zero address");
    require(spender != address(0), "ERC20: approve to the zero address");

    _allowances[owner][spender] = amount;
    emit Approval(owner, spender, amount);
}

function _spendAllowance(
    address owner,
    address spender,
    uint256 amount
) internal virtual {
    uint256 currentAllowance = allowance(owner, spender);
    if (currentAllowance != type(uint256).max) {
        require(
            currentAllowance >= amount,
            "ERC20: insufficient allowance"
        );
        unchecked {
            _approve(owner, spender, currentAllowance - amount);
        }
    }
}

modifier onlyOwner() {
    require(msg.sender == _owner, "Only owner is allowed");
    _;
}
}