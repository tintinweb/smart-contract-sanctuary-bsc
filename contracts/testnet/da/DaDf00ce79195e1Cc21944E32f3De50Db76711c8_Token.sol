pragma solidity ^0.8.7;

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

interface ERC20Interface {
    function totalSupply() external returns (uint);

    function balanceOf(address tokenOwner) external returns (uint balance);

    function allowance(address tokenOwner, address spender) external returns (uint remaining);

    function transfer(address to, uint tokens) external returns (bool success);

    function approve(address spender, uint tokens) external returns (bool success);

    function transferFrom(address from, address to, uint tokens) external returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

contract Token is ERC20Interface, SafeMath {
    string public symbol;
    string public name;
    uint8 public decimals;
    uint public _totalSupply;
    address private owner;

    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;

    constructor() {
        owner = msg.sender;
        symbol = "XYZ";
        name = "XYZ Coin";
        decimals = 18;
        _totalSupply = 300000 * 10 ** 18;
        balances[owner] = _totalSupply;
        emit Transfer(address(0), owner, _totalSupply);
    }

    function totalSupply() public override returns (uint) {
        return _totalSupply - balances[address(0)];
    }

    function balanceOf(address tokenOwner) public override returns (uint balance) {
        return balances[tokenOwner];
    }

    function transfer(address to, uint tokens) public override returns (bool success) {
        balances[msg.sender] = safeSub(balances[msg.sender], tokens);
        balances[to] = safeAdd(balances[to], tokens);
        emit Transfer(msg.sender, to, tokens);
        return true;
    }

    function approve(address spender, uint tokens) public override returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }

    function transferFrom(address from, address to, uint tokens) public override returns (bool success) {
        balances[from] = safeSub(balances[from], tokens);
        allowed[from][msg.sender] = safeSub(allowed[from][msg.sender], tokens);
        balances[to] = safeAdd(balances[to], tokens);
        emit Transfer(from, to, tokens);
        return true;
    }

    function allowance(address tokenOwner, address spender) public override returns (uint remaining) {
        return allowed[tokenOwner][spender];
    }

    receive() external payable {
        revert();
    }
}