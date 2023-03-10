/**
 *Submitted for verification at BscScan.com on 2023-03-10
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Bdollar {
    string public constant name = "Binance Unity Dollar";
    string public constant symbol = "Bdollar";
    uint8 public constant decimals = 18;
    uint256 public totalSupply = 10_000_000_000 * 10 ** decimals;
    uint256 public constant maxSupply = 10_000_000_000 * 10 ** decimals;
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;
    uint256 public constant initialPrice = 6000 * 10 ** 14; // 0.6 USD per Bdollar

    constructor() {
        balanceOf[msg.sender] = totalSupply;
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value, "Insufficient balance");
        require(_to != address(0), "Invalid recipient address");
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(balanceOf[_from] >= _value, "Insufficient balance");
        require(allowance[_from][msg.sender] >= _value, "Insufficient allowance");
        require(_to != address(0), "Invalid recipient address");
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        allowance[_from][msg.sender] -= _value;
        emit Transfer(_from, _to, _value);
        return true;
    }

    function buy() public payable returns (bool success) {
        require(totalSupply < maxSupply, "Maximum supply reached");
        uint256 bdollarAmount = msg.value / initialPrice;
        require(totalSupply + bdollarAmount <= maxSupply, "Insufficient Bdollar available for sale");
        balanceOf[msg.sender] += bdollarAmount;
        totalSupply += bdollarAmount;
        emit Transfer(address(0), msg.sender, bdollarAmount);
        return true;
    }

    function sell(uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value, "Insufficient balance");
        uint256 ethAmount = _value * initialPrice;
        balanceOf[msg.sender] -= _value;
        totalSupply -= _value;
        payable(msg.sender).transfer(ethAmount);
        emit Transfer(msg.sender, address(0), _value);
        return true;
    }

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}