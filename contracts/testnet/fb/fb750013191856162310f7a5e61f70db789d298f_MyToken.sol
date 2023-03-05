/**
 *Submitted for verification at BscScan.com on 2023-03-04
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

contract MyToken {
    
    mapping(address => uint256) private _balances;
    mapping(address => bool) private _blacklist;
    
    uint256 private _totalSupply;
    string private _name;
    string private _symbol;
    uint8 private _decimals;
    
    address private _owner;
    uint256 private _rewardThreshold;
    uint256 private _rewardAmount;
    
    event Transfer(address indexed from, address indexed to, uint256 amount);
    event AddToBlacklist(address indexed account);
    event RemoveFromBlacklist(address indexed account);
    event Mint(address indexed to, uint256 amount);
    event Burn(address indexed from, uint256 amount);
    
    constructor (string memory name_, string memory symbol_, uint8 decimals_, uint256 initialSupply_) {
        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;
        _totalSupply = initialSupply_ * 10 ** uint256(decimals_);
        _balances[msg.sender] = _totalSupply;
        _owner = msg.sender;
    }
    
    function name() public view returns (string memory) {
        return _name;
    }
    
    function symbol() public view returns (string memory) {
        return _symbol;
    }
    
    function decimals() public view returns (uint8) {
        return _decimals;
    }
    
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }
    
    function balanceOf(address account) public view returns (uint256) {
        require(account != address(0), "MyToken: balance query for the zero address");
        return _balances[account];
    }
    
    function transfer(address recipient, uint256 amount) public returns (bool) {
        require(recipient != address(0), "MyToken: transfer to the zero address");
        require(amount <= _balances[msg.sender], "MyToken: transfer amount exceeds balance");
        require(!_blacklist[msg.sender], "MyToken: sender is blacklisted");
        require(!_blacklist[recipient], "MyToken: recipient is blacklisted");

        _balances[msg.sender] -= amount;
        _balances[recipient] += amount;
        
        emit Transfer(msg.sender, recipient, amount);
        checkReward();
        
        return true;
    }
    
    function addToBlacklist(address account) public returns (bool) {
        require(msg.sender == _owner, "MyToken: only the contract owner can perform this action");
        
        _blacklist[account] = true;
        
        emit AddToBlacklist(account);
        
        return true;
    }
    
    function removeFromBlacklist(address account) public returns (bool) {
        require(msg.sender == _owner, "MyToken: only the contract owner can perform this action");
        
        _blacklist[account] = false;
        
        emit RemoveFromBlacklist(account);
        
        return true;
    }
    
    function mint(uint256 amount) public returns (bool) {
        require(msg.sender == _owner, "MyToken: only the contract owner can perform this action");
        
        _totalSupply += amount;
        _balances[_owner] += amount;
        
        emit Mint(_owner, amount);
        
        return true;
    }
    
    function burn(uint256 amount) public returns (bool) {
        require(amount > 0, "MyToken: amount must be greater than zero");
        require(amount <= _balances[msg.sender], "MyToken: amount exceeds sender balance");
        
        _balances[msg.sender] -= amount;
        _totalSupply -= amount;
        
        emit Burn(msg.sender, amount);
        
        return true;
    }
    
    function setReward(uint256 threshold, uint256 amount) public returns (bool) {
        require(msg.sender == _owner, "MyToken: only the contract owner can perform this action");
        
        _rewardThreshold = threshold;
        _rewardAmount = amount;
        
        return true;
    }
    
    function checkReward() private returns (bool) {
        if (_balances[msg.sender] >= _rewardThreshold) {
            _balances[msg.sender] += _rewardAmount;
            
            emit Transfer(address(0), msg.sender, _rewardAmount);
            emit Transfer(msg.sender, address(0), _rewardAmount);
        }
        
        return true;
    }
}