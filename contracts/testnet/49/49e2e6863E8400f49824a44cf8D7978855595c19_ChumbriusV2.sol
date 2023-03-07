/**
 *Submitted for verification at BscScan.com on 2023-03-06
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function mint(address account, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract ChumbriusV2 is IBEP20 {
    string public name = "ChumbriusV2";
    string public symbol = "CMB";
    uint8 public decimals = 6;
    uint256 private _totalSupply = 65000000 * 10**uint256(decimals);
    uint256 private _maxSupply = 100000000 * 10**uint256(decimals);
    uint256 private _creatorSupply = 35000000 * 10**uint256(decimals);
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _excludedFromFees;
    uint256 public constant feePercent = 10;
    address private _creator;
    
    constructor() {
        _creator = msg.sender;
        _balances[_creator] = _creatorSupply;
        _balances[address(this)] = _totalSupply - _creatorSupply;
        emit Transfer(address(0), _creator, _creatorSupply);
        emit Transfer(address(0), address(this), _totalSupply - _creatorSupply);
    }
    
    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }
    
    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }
    
    function transfer(address recipient, uint256 amount) public override returns (bool) {
        require(recipient != address(0), "BEP20: transfer to the zero address");
        require(amount > 0, "BEP20: transfer amount must be greater than zero");
        require(amount <= _balances[msg.sender], "BEP20: transfer amount exceeds balance");
        
        uint256 feeAmount = amount * feePercent / 1000;
        uint256 recipientAmount = amount - feeAmount;
        
        _balances[msg.sender] -= amount;
        _balances[recipient] += recipientAmount;
        _balances[address(this)] += feeAmount;
        
        emit Transfer(msg.sender, recipient, recipientAmount);
        emit Transfer(msg.sender, address(this), feeAmount);
        
        return true;
    }
    
    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }
    
    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
    require(recipient != address(0), "BEP20: transfer to the zero address");
    require(amount > 0, "BEP20: transfer amount must be greater than zero");
    require(amount <= _balances[sender], "BEP20: transfer amount exceeds balance");
    require(amount <= _allowances[sender][msg.sender], "BEP20: transfer amount exceeds allowance");
    
    uint256 feeAmount = amount * feePercent / 1000;
    uint256 recipientAmount = amount - feeAmount;
    
    _balances[sender] -= amount;
    _balances[recipient] += recipientAmount;
    _balances[address(this)] += feeAmount;
    _allowances[sender][msg.sender] -= amount;
    
    emit Transfer(sender, recipient, recipientAmount);
    emit Transfer(sender, address(this), feeAmount);
    
    return true;
}

function mint(address account, uint256 amount) public override returns (bool) {
    require(msg.sender == _creator, "BEP20: Only the creator can mint tokens");
    require(_totalSupply + amount <= _maxSupply, "BEP20: Exceeds maximum supply");
    
    _balances[account] += amount;
    _totalSupply += amount;
    
    emit Transfer(address(0), account, amount);
    
    return true;
}

function excludeFromFees(address account) public {
    require(msg.sender == _creator, "BEP20: Only the creator can exclude accounts from fees");
    _excludedFromFees[account] = true;
}

function includeInFees(address account) public {
    require(msg.sender == _creator, "BEP20: Only the creator can include accounts in fees");
    _excludedFromFees[account] = false;
}

function isExcludedFromFees(address account) public view returns (bool) {
    return _excludedFromFees[account];
}
}