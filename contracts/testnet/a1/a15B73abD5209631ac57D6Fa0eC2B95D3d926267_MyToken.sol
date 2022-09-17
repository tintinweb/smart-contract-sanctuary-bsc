// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface ERC20Interface {
    function totalSupply()external view returns (uint);
    function balanceOf(address tokenOwner)external view returns (uint balance);
    function allowance(address tokenOwner, address spender)external view returns (uint remaining);
    function transfer(address to, uint tokens)external returns (bool success);
    function approve(address spender, uint tokens)external returns (bool success);
    function transferFrom(address from, address to, uint tokens)external returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}


contract MyToken is ERC20Interface{
    string public name;                          // name of the token
    string public symbol;                        // symbol of token
    uint8 public decimals;                       // divisibility of token
    uint256 public _totalSupply;                 // total number of tokens in existence

    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;


    constructor() {
        name ="OurToken";
        symbol = "OTK";
        decimals = 10; 
        _totalSupply = 10000000000000; // total tokens would equal (_totalSupply/10**decimals)=1000


        balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    function totalSupply()external view returns (uint) {
        return _totalSupply  - balances[address(0)];
    }

    function balanceOf(address tokenOwner) external view returns (uint balance) {
        return balances[tokenOwner];
    }


    function allowance(address tokenOwner, address spender)external view returns (uint remaining) {
        return allowed[tokenOwner][spender];
    }

    function approve(address spender, uint tokens)external returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }

    function transfer(address to, uint tokens)external returns (bool success) {
        balances[msg.sender] = balances[msg.sender]- tokens;
        balances[to] = balances[to] +  tokens;
        emit Transfer(msg.sender, to, tokens);
        return true;
    }


    function transferFrom(address from, address to, uint tokens)external returns (bool success) {
        balances[from] = balances[from] -  tokens;
        allowed[from][msg.sender] = allowed[from][msg.sender] -  tokens;
        balances[to] = balances[to] + tokens;
        emit Transfer(from, to, tokens);
        return true;
    }
}