/**
 *Submitted for verification at BscScan.com on 2022-07-24
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {

    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address _owner) external view returns (uint256 balance);
    function transfer(address _to, uint256 _value) external returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool success);
    function approve(address _spender, uint256 _value) external returns (bool success);
    function allowance(address _owner, address _spender) external view returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

contract MyToken is IERC20 {
    address public owner;
    address payable public vault;

    struct TimeLock {
        uint256 balance;
        uint256 until;
    }

    mapping(address => uint256) private balances;
    mapping(address => mapping(address => uint256)) private allowances;
    mapping(address => TimeLock) private timelocks;

    string private name_;
    string private symbol_;
    
    uint256 private totalSupply_;
    uint256 private lockedSupply_;

    uint8 private decimals_;

    constructor(string memory _name, string memory _symbol, uint8 _decimals, uint256 _totalSupply) {
        vault = payable(address(this));
        owner = msg.sender;
        name_ = _name;
        symbol_ = _symbol;
        decimals_ = _decimals;
        totalSupply_ = _totalSupply;
        
        balances[owner] = totalSupply_;
    }

    function decimals() public view override returns (uint8){
        return decimals_;
    }
    function totalSupply() public view override returns (uint){
        return totalSupply_;
    }
    function balanceOf(address _owner) public view override returns (uint256){
        return balances[_owner];
    }
    
    function transfer(address _to, uint256 _value) public virtual override returns (bool success){      
        require(balances[msg.sender] >= _value, 'Insufficient Balance!');
        require(msg.sender != _to, 'You cannot transfer to same wallet!');

        _transfer(msg.sender, _to, _value);

        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public virtual override returns (bool success){
        require(allowance(_from,_to) >= _value, 'Allowance amount is too low!');
        require(balances[_from] >= _value, 'Insufficient Balance!');

        allowances[_from][_to] -= _value;
        _transfer(_from, _to, _value);

        return true;
    }

    function approve(address _spender, uint256 _value) public virtual override returns (bool success){
        require(msg.sender != _spender, 'Cannot Approve Same Addresses!');
        
        allowances[msg.sender][_spender] = _value;

        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public view override returns (uint256 remaining){
        return allowances[_owner][_spender];
    }

    function _transfer(address _from, address _to, uint256 _value) private {

        balances[_from] -= _value;
        balances[_to] += _value;

        emit Transfer(_from, _to, _value);
    }

    function reserve(address _receiver, uint256 _value, uint256 _lockperiod) public returns (bool) {
        require(balances[msg.sender] >= _value, 'Insufficient Balance!');
        require(timelocks[_receiver].balance == 0, 'Already reserved');

        _transfer(msg.sender, vault, _value);
        _reserve(_receiver, _value, _lockperiod);

        return true;
    }

    function _reserve(address _receiver, uint256 _value, uint256 _lockperiod) private {
        timelocks[_receiver].balance = _value;
        timelocks[_receiver].until = block.timestamp + _lockperiod;

        lockedSupply_ += _value;
    }

    function claimable(address _receiver) public view returns (uint256) {
        return timelocks[_receiver].balance;
    }
    function lockedSupply() public view returns (uint256) {
        return lockedSupply_;
    }
    function lockedUntil(address _receiver) public view returns (uint256){
        return timelocks[_receiver].until;
    }

    function claim() public returns (bool success) {
        require (timelocks[msg.sender].until <= block.timestamp, 'Lock period is not over yet!');

        _transfer(vault, msg.sender, timelocks[msg.sender].balance);
        _claim();

        return true;
    }

    function _claim() private {
            lockedSupply_ -= timelocks[msg.sender].balance;
            timelocks[msg.sender].balance = 0;
    }
}