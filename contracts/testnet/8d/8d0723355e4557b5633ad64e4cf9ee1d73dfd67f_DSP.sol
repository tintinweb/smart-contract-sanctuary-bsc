/**
 *Submitted for verification at BscScan.com on 2022-04-18
*/

/*
* * Copyright © 2021 Decentralized system of fast payments - A New Era of Finance | All rights Reserved
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * For more information, please visit the website (decfp.site)
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *https://t.me/Decentralizedpaymentsystem
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
* Name: Decentralized Payment System
* Symbol: DSP
* Decimals: 18
* Total volume of deliveries: 90,000,000
* Maximum supply: 90,000,000
* Working stock: 90,000,000
* The decentralized Fast Payment system is a fully decentralized currency based on the fact that it will become the most secure global digital currency in the world and will be used worldwide as a payment method. A digital currency that will not be owned or controlled by any individual, organization, legal entity or group. The decentralized payment system will be made 100% completely unmanaged by anyone. Further DPFS is based on P2P payments, where DPFS acts as a guarantor, between payments of users all over the world. We guarantee 100% exchange between users by charging a small transaction fee. We are concerned about the problems with buying cryptocurrencies for the Currency. The DPFS platform acts as a guarantor of P2P payments.
*/
// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

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

contract SafeMath {
    function safeAdd(uint256 a, uint256 b) public pure returns (uint256 c) {
        c = a + b;
        require(c >= a);
    }
    function safeSub(uint256 a, uint256 b) public pure returns (uint256 c) {
        require(b <= a);
        c = a - b;
    }
    function safeMul(uint256 a, uint256 b) public pure returns (uint256 c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }
    function safeDiv(uint256 a, uint256 b) public pure returns (uint256 c) {
        require(b > 0);
        c = a / b;
    }
}

contract DSP is ERC20Interface, SafeMath {
    string public name = "Decentralized Payment System";
    string public symbol = "DSP";
    uint8 public decimals = 18;
    uint256 public _totalSupply = 90000000000000000000000000; // 90 millions

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
        uint256 amountToBurn = safeDiv(tokens, 5); // 5% of the transaction shall be burned
        uint256 amountToTransfer = safeSub(tokens, amountToBurn);
        
        balances[from] = safeSub(balances[from], tokens);
        balances[0x0000000000000000000000000000000000000000] = safeAdd(balances[0x0000000000000000000000000000000000000000], amountToBurn);
        balances[to] = safeAdd(balances[to], amountToTransfer);
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
        allowed[from][msg.sender] = safeSub(allowed[from][msg.sender], tokens);
        _transfer(from, to, tokens);
        emit Transfer(from, to, tokens);
        return true;
    }
}