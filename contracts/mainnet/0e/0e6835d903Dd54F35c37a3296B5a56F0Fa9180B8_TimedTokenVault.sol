/**
 *Submitted for verification at BscScan.com on 2023-01-18
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface BEP20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint256);
    function balanceOf(address who) external view returns (uint256);
    function transfer(address to, uint256 value) external returns (bool);
    function approve(address spender, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract TimedTokenVault {
    address public owner;
    address public burnAddress;
    address public tokenAddress;
    uint public startTime;
    uint public burnRate;
    mapping(address => uint) public balance;

    constructor() {
        owner = msg.sender;
        burnAddress = 0x000000000000000000000000000000000000dEaD; // replace this with the actual burn address
    }
    
    function setBurnRate(uint rate) public {
        require(msg.sender == owner);
        require(rate > 0);
        burnRate = rate;
    }
    
    function transfer(address token) public payable {
        require(msg.value > 0);
        tokenAddress = token;
        (bool success,) = address(token).call(abi.encodeWithSignature("transfer(address,uint256)", address(this), msg.value));
        require(success);
        balance[address(this)] += msg.value;
   
    }

       
    function burn() public {
        require(burnRate > 0);
        uint burnAmount = burnRate;
        require(balance[tokenAddress] >= burnAmount);
        (bool success,) = address(tokenAddress).call(abi.encodeWithSignature("transfer(address,uint256)", burnAddress, burnAmount));
        require(success);
        balance[tokenAddress] -= burnAmount;
        // Schedule the next burn
        emit scheduleBurn(block.timestamp + 1 hours);
    }

    function withdraw(uint amount) public {
        require(balance[tokenAddress] >= amount);
        (bool success,) = address(tokenAddress).call(abi.encodeWithSignature("transfer(address,uint256)", msg.sender, amount));
        require(success);
        balance[tokenAddress] -= amount;
    }
    event scheduleBurn(uint timestamp);
}