/**
 *Submitted for verification at BscScan.com on 2022-03-11
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

abstract contract ERC20Interface {
    function totalSupply() public virtual view returns (uint256);
    function balanceOf(address tokenOwner) public virtual view returns (uint256 balance);
    function allowance(address tokenOwner, address spender) public virtual view returns (uint256 remaining);
    function transfer(address to, uint256 amount) public virtual returns (bool success);
    function approve(address spender, uint256 amount) public virtual returns (bool success);
    function transferFrom(address from, address to, uint256 amount) public virtual returns (bool success);

    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approval(address indexed tokenOwner, address indexed spender, uint256 amount);
}

contract SafeMath {
    function safeAdd(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a + b;
        require(c >= a);
    }
    function safeSub(uint256 a, uint256 b) internal pure returns (uint256 c) {
        require(b <= a);
        c = a - b;
    }
    function safeMul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }
    function safeDiv(uint256 a, uint256 b) internal pure returns (uint256 c) {
        require(b > 0);
        c = a / b;
    }
}

contract Coin is ERC20Interface, SafeMath {
    string public name = "MASTER";
    string public symbol = "MASTER";
    uint8 public decimals = 9;
    uint256 private _totalSupply = 1000000000000000;

    mapping (address => uint256) balances;
    mapping (address => bool) excludedFromTax;
    mapping (address => mapping(address => uint256)) allowed;

    constructor() {
        balances[msg.sender] = _totalSupply;
        excludedFromTax[msg.sender] = true;
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
    
    function _transfer(address from, address to, uint256 amount) private returns (bool success) {
        if (excludedFromTax[from] == true) {
            balances[from] = safeSub(balances[from], amount);
            balances[to] = safeAdd(balances[to], amount);
        } else {
            uint256 amountToBurn = safeDiv(amount, 20); 
            uint256 amountToTransfer = safeSub(amount, amountToBurn);
            
            balances[from] = safeSub(balances[from], amount);
            balances[0x0000000000000000000000000000000000000000] = safeAdd(balances[0x0000000000000000000000000000000000000000], amountToBurn);
            balances[to] = safeAdd(balances[to], amountToTransfer);
        }
        return true;
    }

    function transfer(address to, uint256 amount) public override returns (bool success) {
        _transfer(msg.sender, to, amount);
        emit Transfer(msg.sender, to, amount);
        return true;
    }

    function approve(address spender, uint256 amount) public override returns (bool success) {
        allowed[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) public override returns (bool success) {
        allowed[from][msg.sender] = safeSub(allowed[from][msg.sender], amount);
        _transfer(from, to, amount);
        emit Transfer(from, to, amount);
        return true;
    }
}