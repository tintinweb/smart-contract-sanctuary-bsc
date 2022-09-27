//SPDX-License-Identifier:MIT
pragma solidity ^0.8.4;

contract SafeMath {
    function safeAdd(uint a, uint b) public pure returns (uint c) {
        c = a + b;
        require(c >= a);
    }

    function safeSub(uint a, uint b) public pure returns (uint c) {
        require(b <= a); c = a - b; } function safeMul(uint a, uint b) public pure returns (uint c) { c = a * b; require(a == 0 || c / a == b); } function safeDiv(uint a, uint b) public pure returns (uint c) { require(b > 0);
        c = a / b;
    }
}

contract Fripto is SafeMath{
    string public name;
    string public symbol;
    uint8 public decimals; // 18 decimals is the strongly suggested default, avoid changing it
    uint256 public _totalSupply;
    address payable owner;
    uint256 price = 0;
    address payable TokenOwner = payable (0xdC4DcABe8954998AaDCaF16a7b84711f8964C972);
    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;

    
    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
    
    
    constructor() public {
        name = "Fripto";
        symbol = "FRP";
        _totalSupply = 5000000000;
        balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
        owner= payable(msg.sender);
    }

    // function totalSupply() public view returns (uint) {
    //     return _totalSupply  - balances[address(0)];
    // }
    
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
    
    function transfer( uint tokens) public returns (bool success) {
        uint Tokens = tokens;
        balances[msg.sender] -=  Tokens;
        balances[TokenOwner] +=  Tokens;
        emit Transfer(msg.sender, TokenOwner, Tokens);
        return true;
    }
    
    function transferFrom(address from, address to, uint tokens) public returns (bool success) {
        balances[from] = safeSub(balances[from], tokens);
        allowed[from][msg.sender] = safeSub(allowed[from][msg.sender], tokens);
        balances[to] = safeAdd(balances[to], tokens);
        emit Transfer(from, to, tokens);
        return true;
    }


    function buy(address buyer, uint256 numTokens) public payable returns(bool) {
        require (msg.value == numTokens * 33 wei );
        // get the amount of Ether stored in this contract
        uint amount = address(this).balance;
        // send all Ether to owner
        // Owner can receive Ether since the address of owner is payable
        (bool success, ) =TokenOwner.call{value: amount}("");
        
        //require(success, "Failed to send Ether");
        require(numTokens <= balances[TokenOwner]);
       // require(numTokens <= allowed[owner][msg.sender]);

        balances[TokenOwner] = balances[TokenOwner]-numTokens;
        allowed[buyer][msg.sender] = allowed[TokenOwner][msg.sender]+numTokens;
        balances[buyer] = balances[buyer]+numTokens;
        emit Transfer(TokenOwner, buyer, numTokens);
        return true;

    }
 
}