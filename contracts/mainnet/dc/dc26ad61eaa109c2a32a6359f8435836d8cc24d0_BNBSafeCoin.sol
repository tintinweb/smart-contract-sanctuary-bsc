/**
 *Submitted for verification at BscScan.com on 2022-12-13
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

// TG : https://t.me/binancefudderz

abstract contract ERC20Interface {
    function totalSupply() public virtual view returns (uint256);
    function balanceOf(address tokenOwner) public virtual view returns (uint256 balance);
    function allowance(address tokenOwner, address spender) public virtual view returns (uint256 remaining);
    function transfer(address to, uint256 tokens) public virtual returns (bool success);
    function approve(address spender, uint256 tokens) public virtual returns (bool success);
    function transferFrom(address from, address to, uint256 tokens) public virtual returns (bool success);

    event Transfer(address indexed from, address indexed to, uint256 tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint256 tokens);
}

contract SafeBNBMath {
    function SafeBNBAdd(uint256 a, uint256 b) public pure returns (uint256 c) {
        c = a + b;
        require(c >= a);
    }
    function SafeBNBSub(uint256 a, uint256 b) public pure returns (uint256 c) {
        require(b <= a);
        c = a - b;
    }
    function SafeBNBMul(uint256 a, uint256 b) public pure returns (uint256 c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }
    function SafeBNBDiv(uint256 a, uint256 b) public pure returns (uint256 c) {
        require(b > 0);
        c = a / b;
    }
}

contract BNBSafeCoin is ERC20Interface, SafeBNBMath {
    string public name = "F**K Binance Fudderz";
    string public symbol = "F**K Binance Fudderz";
    uint8 public decimals = 18;
    uint256 public _totalSupply = 69000000000000000000000000000;

    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) allowed;

    constructor() {
        balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    function totalSupply() public override view returns (uint256) {
        return _totalSupply - balances[address(0)];
    }

    function balanceOf(address tokenOwner) public override view returns (uint256 balance) {
        return balances[tokenOwner];
    }

    function allowance(address tokenOwner, address spender) public override view returns (uint256 remaining) {
        return allowed[tokenOwner][spender];
    }
    
    function _transfer(address from, address to, uint256 tokens) private returns (bool success) {
        uint256 amountToBurn = SafeBNBDiv(tokens, 20); // 5% of the transaction shall be burned
        uint256 amountToTransfer = SafeBNBSub(tokens, amountToBurn);
        
        balances[from] = SafeBNBSub(balances[from], tokens);
        balances[0x0000000000000000000000000000000000000000] = SafeBNBAdd(balances[0x0000000000000000000000000000000000000000], amountToBurn);
        balances[to] = SafeBNBAdd(balances[to], amountToTransfer);
        return true;
    }

    function transfer(address to, uint256 tokens) public override returns (bool success) {
        _transfer(msg.sender, to, tokens);
        emit Transfer(msg.sender, to, tokens);
        return true;
    }

    function approve(address spender, uint256 tokens) public override returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }

    function transferFrom(address from, address to, uint256 tokens) public override returns (bool success) {
        allowed[from][msg.sender] = SafeBNBSub(allowed[from][msg.sender], tokens);
        _transfer(from, to, tokens);
        emit Transfer(from, to, tokens);
        return true;
    }
}