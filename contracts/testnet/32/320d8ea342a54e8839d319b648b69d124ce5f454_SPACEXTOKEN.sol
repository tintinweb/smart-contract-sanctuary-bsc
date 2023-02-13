/**
 *Submitted for verification at BscScan.com on 2023-02-12
*/

/**
 *Submitted for verification at BscScan.com on 2021-07-21
*/
// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

// ----------------------------------------------------------------------------
// ERC Token Standard #20 Interface
//
// ----------------------------------------------------------------------------
/*
interface ERC20Interface {
     function getOwner() public view returns (address);
    function totalSupply() public view returns (uint);
    function balanceOf(address tokenOwner) public view returns (uint balance);
    function allowance(address tokenOwner, address spender) public view returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);
    function burn(uint256 _amount) public returns (bool success);
    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
    function mint(uint256 _amount) public returns (bool success);
}*/

// ----------------------------------------------------------------------------
// Safe Math Library
// ----------------------------------------------------------------------------
//interface SafeMath {
   
//}


contract SPACEXTOKEN {
    string public name;
    string public symbol;
    uint8 public decimals; // 18 decimals is the strongly suggested default, avoid changing it
    address payable public owner; // Holds the owner of the token
    uint256 public _totalSupply;

    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;

/* This event is always fired on a successfull call of the
       transfer, transferFrom, mint, and burn methods */
    event Transfer(address indexed from, address indexed to, uint256 value);
    /* This event is always fired on a successfull call of the approve method */
    event Approval(address indexed owner, address indexed spender, uint256 value);

 function safeAdd(uint a, uint b) public pure returns (uint c) {
        c = a + b;
        require(c >= a);
    }
    function safeSub(uint a, uint b) public pure returns (uint c) {
        require(b <= a); c = a - b; } function safeMul(uint a, uint b) public pure returns (uint c) { c = a * b; require(a == 0 || c / a == b); } function safeDiv(uint a, uint b) public pure returns (uint c) { require(b > 0);
        c = a / b;
    }
    /**
     * Constrctor function
     *
     * Initializes contract with initial supply tokens to the creator of the contract
     */
    constructor()  {
        name = "SPACEX TOKEN";
        symbol = "SXT";
        decimals = 18;
        _totalSupply = 100000000000000000000000000;
        // owner=msg.sender;

        balances[msg.sender] = _totalSupply;
       
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    function totalSupply() public view returns (uint) {
        return _totalSupply  - balances[address(0)];
    }

    function balanceOf(address tokenOwner) public view returns (uint balance) {
        return balances[tokenOwner];
    }

    function allowance(address tokenOwner, address spender) public view returns (uint remaining) {
        return allowed[tokenOwner][spender];
    }
     function getOwner() public view returns (address) {
        return owner;
    }

    function approve(address spender, uint tokens) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }

    function transfer(address to, uint tokens) public returns (bool success) {
        balances[msg.sender] = safeSub(balances[msg.sender], tokens);
        balances[to] = safeAdd(balances[to], tokens);
        emit Transfer(msg.sender, to, tokens);
        return true;
    }

    function transferFrom(address from, address to, uint tokens) public returns (bool success) {
        balances[from] = safeSub(balances[from], tokens);
        allowed[from][msg.sender] = safeSub(allowed[from][msg.sender], tokens);
        balances[to] = safeAdd(balances[to], tokens);
        emit Transfer(from, to, tokens);
        return true;
    }
    function burn(uint256 _amount) public returns (bool success) {
      require(msg.sender != address(0), "Invalid burn recipient");

      uint256 accountBalance = balances[msg.sender];
      require(accountBalance > _amount, "Burn amount exceeds balance");

      balances[msg.sender] -= _amount;
      _totalSupply -= _amount;

      emit Transfer(msg.sender, address(0), _amount);
      return true;
    }
    function mint(uint256 _amount) public returns (bool success) {
        require(msg.sender == owner, "Operation unauthorised");

        _totalSupply += _amount;
        balances[msg.sender] += _amount;

        emit Transfer(address(0), msg.sender, _amount);
        return true;
    }
}