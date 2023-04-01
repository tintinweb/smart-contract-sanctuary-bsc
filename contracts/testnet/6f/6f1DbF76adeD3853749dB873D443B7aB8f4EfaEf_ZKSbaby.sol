/**
 *Submitted for verification at BscScan.com on 2023-03-31
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ZKSbaby {
    string public name = "ZKSbaby";
    string public symbol = "ZKS";
    uint256 public totalSupply = 100000000 * 10**18; // 100 million tokens with 18 decimal places
    uint8 public decimals = 18;
    
    address public marketingWallet = 0xb744874877ECB800EEBf37217Bd26F4411d2B326;
    uint256 public marketingTax = 2;
  
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor() {
        _balances[msg.sender] = totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) private {
        require(sender != address(0), "ZKSbaby: transfer from the zero address");
        require(recipient != address(0), "ZKSbaby: transfer to the zero address");

        uint256 marketingFee = amount * marketingTax / 100;

        _balances[sender] -= amount;
        _balances[recipient] += amount - marketingFee;
        _balances[marketingWallet] += marketingFee;

        emit Transfer(sender, recipient, amount - marketingFee);
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ZKSbaby: approve from the zero address");
        require(spender != address(0), "ZKSbaby: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
}