/**
 *Submitted for verification at BscScan.com on 2023-03-03
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract PoisonV1 {
    string public constant name = "PoisonV1";
    string public constant symbol = "POIS";
    uint8 public constant decimals = 6;
    uint256 public constant totalSupply = 100000000 * 10 ** decimals;
    uint256 public constant exchangeFee = 10; // 0.1%
    address public constant exchangeFeeRecipient = 0xa06690322E57f7993a060D40517Ee9C3f8d5Ba74;
    
    mapping(address => uint256) private balances;
    mapping(address => mapping(address => uint256)) private allowed;
    
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    
    constructor() {
        balances[msg.sender] = totalSupply;
    }
    
    
    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }
    
    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(balances[msg.sender] >= _value, "Insufficient balance");
        require(_to != address(0), "Invalid recipient address");
        
        uint256 fee = (_value * exchangeFee) / 10000;
        uint256 netValue = _value - fee;
        balances[msg.sender] -= _value;
        balances[_to] += netValue;
        balances[exchangeFeeRecipient] += fee;
        
        emit Transfer(msg.sender, _to, netValue);
        emit Transfer(msg.sender, exchangeFeeRecipient, fee);
        
        return true;
    }
    
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(balances[_from] >= _value, "Insufficient balance");
        require(_to != address(0), "Invalid recipient address");
        require(allowed[_from][msg.sender] >= _value, "Not allowed to transfer");
        
        uint256 fee = (_value * exchangeFee) / 10000;
        uint256 netValue = _value - fee;
        balances[_from] -= _value;
        balances[_to] += netValue;
        balances[exchangeFeeRecipient] += fee;
        allowed[_from][msg.sender] -= _value;
        
        emit Transfer(_from, _to, netValue);
        emit Transfer(_from, exchangeFeeRecipient, fee);
        
        return true;
    }
    
    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        
        emit Approval(msg.sender, _spender, _value);
        
        return true;
    }
    
    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

}