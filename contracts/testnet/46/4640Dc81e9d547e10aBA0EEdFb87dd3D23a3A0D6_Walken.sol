// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

contract Walken {
    mapping(address => uint) public balances;
    mapping(address => mapping(address => uint)) public allowance;
    mapping(address => bool) public authorizations;
    address public owner; 
    uint256 public totalSupply;
    string public name = "Walken";
    string public symbol = "WLKN";
    uint8 public decimals = 18;
    
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
    
    constructor() {
        balances[msg.sender] = totalSupply;
        authorizations[owner] = true;
    }

    modifier onlyOwner() {
        _isOwner();
        _;
    }

    modifier authorized() {
        _isAuthorized();
        _;
    }

    function _isAuthorized() internal view returns (bool){
        require(authorizations[msg.sender]);
        return true;
    }

    function _isOwner() internal view {
        require(owner == msg.sender);
    }
    
    function authorize(address addr) public onlyOwner returns(bool) {
        authorizations[addr] = true;
        return true;
    }

    function balanceOf(address addr) public view returns(uint) {
        return balances[addr];
    }
    
    function transfer(address to, uint value) public returns(bool) {
        require(balanceOf(msg.sender) >= value);
        balances[to] += value;
        balances[msg.sender] -= value;
       emit Transfer(msg.sender, to, value);
        return true;
    }
    
    function transferFrom(address from, address to, uint value) public returns(bool) {
        require(balanceOf(from) >= value);
        require(allowance[from][msg.sender] >= value);
        balances[to] += value;
        balances[from] -= value;
        emit Transfer(from, to, value);
        return true;
    }
    
    function approve(address spender, uint value) public returns (bool) {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function mint(address recipient, uint256 amount) public authorized returns(bool) {
        balances[recipient] += amount;
        return true;
    }
}