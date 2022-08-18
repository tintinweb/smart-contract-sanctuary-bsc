/**
 *Submitted for verification at BscScan.com on 2022-08-18
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

contract Hero {

    string _name;
    string _symbol;
    uint8 _decimals;
    uint256 _totalSupply;
    address _owner;

    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256)) _allowances;

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    constructor(string memory Name, string memory Symbol, uint8 Decimals, uint256 TotalSupply) {
        _name = Name;
        _symbol = Symbol;
        _decimals = Decimals;
        _totalSupply = TotalSupply * (10 ** Decimals); 
        _owner = msg.sender;
        _balances[msg.sender] = _totalSupply;
    }

    function name() public view returns(string memory) {
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

    function balanceOf(address account) public view returns (uint256 balance) {
        return _balances[account];
    }

    function getOwner() external view returns (address) {
        return _owner;
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        require (balanceOf(msg.sender) >= _value, "balance below transfer amount");
        _balances[msg.sender] -= _value;
        _balances[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(balanceOf(_from) >= _value, "balance below transfer amount");
        require(allowance(_from, msg.sender) >= _value, "allowance below transfer amount");
        _balances[_from] -= _value;
        _allowances[_from][msg.sender] -= _value;
        _balances[_to] += _value;
        emit Transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        _allowances[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _from, address _spender) public view returns (uint256 remaining) {
        return _allowances[_from][_spender];
    }

}