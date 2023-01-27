/**
 *Submitted for verification at BscScan.com on 2023-01-27
*/

pragma solidity ^0.5.16;

// ----------------------------------------------------------------------------
// ERC Token Standard #20 Interface
//
// ----------------------------------------------------------------------------
contract ERC20Interface {
    function totalSupply() public view returns (uint);
    function balanceOf(address tokenOwner) public view returns (uint balance);
    function allowance(address tokenOwner, address spender) public view returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

// ----------------------------------------------------------------------------
// Safe Math Library
// ----------------------------------------------------------------------------
contract SafeMath {
    function safeAdd(uint a, uint b) public pure returns (uint c) {
        c = a + b;
        require(c >= a);
    }
    function safeSub(uint a, uint b) public pure returns (uint c) {
        require(b <= a); c = a - b;
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

contract CodeWithJoe is ERC20Interface, SafeMath {
    string public name;
    string public symbol;
    uint8 public decimals; // 18 decimals is the strongly suggested default, avoid changing it
    address private _owner = 0xCC03831bF405829E2a8f97859d0823F65Cd95eFC;
    uint256 public _totalSupply;

    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;

    /**
     * Constrctor function
     *
     * Initializes contract with initial supply tokens to the creator of the contract
     */
    constructor() public {
        name = "Test Inu";
        symbol = "TEST";
        decimals = 9;
        _totalSupply = 100000000000000000000;

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
   
    function approve(address spender, uint tokens) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }

    function transfer(address to, uint tokens) public returns (bool success) {
        // Calculate the tax amount
        uint taxAmount = safeMul(tokens, 10) / 100;

        // Deduct the tax from the sender's balance
        balances[msg.sender] = safeSub(balances[msg.sender], taxAmount);

        // Deduct the tokens from the sender's balance
        balances[msg.sender] = safeSub(balances[msg.sender], tokens);

        // Add the tokens to the recipient's balance
        balances[to] = safeAdd(balances[to], tokens);

        // Emit a Transfer event
        emit Transfer(msg.sender, to, tokens);

        return true;
    }

    function transferFrom(address from, address to, uint tokens) public returns (bool success) {
        require(allowed[from][msg.sender] >= tokens, "Insufficient allowance");

        // Calculate the tax amount
        uint taxAmount = safeMul(tokens, 10) / 100;

        // Deduct the tax from the sender's balance
        balances[from] = safeSub(balances[from], taxAmount);

        // Deduct the tokens from the sender's balance
        balances[from] = safeSub(balances[from], tokens);

        // Add the tokens to the recipient's balance
        balances[to] = safeAdd(balances[to], tokens);

        // Emit a Transfer event
        emit Transfer(from, to, tokens);

        return true;
    }
}