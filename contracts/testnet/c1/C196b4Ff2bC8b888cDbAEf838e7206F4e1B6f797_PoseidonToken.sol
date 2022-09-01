/**
 *Submitted for verification at BscScan.com on 2022-08-31
*/

// SPDX-License-Identifier: MIT


pragma solidity ^0.4.24;
 
//Safe Math Interface
 
contract SafeMath {
 
    function safeAdd(uint a, uint b) public pure returns (uint c) {
        c = a + b;
        require(c >= a);
    }
 
    function safeSub(uint a, uint b) public pure returns (uint c) {
        require(b <= a);
        c = a - b;
    }
 
    function safeMul(uint a, uint b) public pure returns (uint c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }
 
    function safeDiv(uint a, uint b) public pure returns (uint c) {
        require(b > 0);
        c = a / b;
    }
}

pragma solidity ^0.4.24;

//Ownable 

contract Ownable {
	function transferOwnership(address newOwner) public returns (bool);
	function Owner() external constant returns (address);
}

pragma solidity ^0.4.24;

//Token Interface

contract ERC20Interface {
    function totalSupply() public constant returns (uint);
    function balanceOf(address tokenOwner) public constant returns (uint balance);
    function allowance(address tokenOwner, address spender) public constant returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);
    function burn(address to, uint tokens) public returns (bool success);
    function mint(address to, uint tokens) public returns (bool success);
    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

contract PoseidonToken is ERC20Interface, SafeMath, Ownable {
    string public symbol;
    string public  name;
    uint8 public decimals;
    uint public _totalSupply;
    address public Owner;
 
    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;
 
    constructor() public {
        symbol = "PSDN";
        name = "Poseidon";
        decimals = 18;
        _totalSupply = safeMul(1000000000000, 1000000000000000000);
        Owner = msg.sender;
        balances[Owner] = _totalSupply;
        emit Transfer(address(0), Owner, _totalSupply);
    }
    
    function thisAddress() public constant returns (address) { 
        return address(this);
    }
    function totalSupply() public constant returns (uint) { 
        return _totalSupply  - balances[address(0)];
    }
    function balanceOf(address tokenOwner) public constant returns (uint balance) {
        return balances[tokenOwner];
    }
 


    function transfer(address to, uint tokens) public returns (bool success) {
        balances[msg.sender] = safeSub(balances[msg.sender], tokens);
        balances[to] = safeAdd(balances[to], tokens);
        emit Transfer(msg.sender, to, tokens);
        return true;
    }

    function approve(address spender, uint tokens) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }

    function transferFrom(address from, address to, uint tokens) public returns (bool success) {
        require(allowance(from, msg.sender)>=tokens, "Not enough allowance!");
        balances[from] = safeSub(balances[from], tokens);
        allowed[from][msg.sender] = safeSub(allowed[from][msg.sender], tokens);
        balances[to] = safeAdd(balances[to], tokens);
        emit Transfer(from, to, tokens);
        return true;
    }

    function burn(address burner, uint tokens) public returns (bool success) {
        require(msg.sender==burner, 'You can only burn your own ERC20!');
        require(balances[burner]>=tokens, 'Not enough ERC20!');
        balances[burner] = safeSub(balances[burner], tokens);
        _totalSupply = safeSub(_totalSupply, tokens);
        emit Transfer(burner, address(0), tokens);
        return true;
    }

    function mint(address to, uint tokens) public onlyOwner returns (bool success) {
        require(msg.sender==Owner, 'You are not the owner!');
        balances[to] = safeAdd(balances[to], tokens);
        _totalSupply = safeAdd(_totalSupply, tokens);
        emit Transfer(address(0), to, tokens);
        return true;
    }

    function allowance(address tokenOwner, address spender) public constant returns (uint remaining) {
        return allowed[tokenOwner][spender];
    }



    function transferOwnership(address newOwner) public returns (bool success) 
    {
        require(msg.sender==Owner, 'You are not the owner!');
        Owner = newOwner;
        return true;
    }

    function Owner() external constant returns (address)
    {
        return Owner;
    }

    modifier onlyOwner() {
        require(Owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }



    function withdraw() public payable onlyOwner{
        revert();
    }
}