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
    uint public startTime;
    uint public burnRate;
    mapping(address => mapping(address => uint)) public balanceOf;

    constructor() {
        owner = msg.sender;
        burnAddress = 0x000000000000000000000000000000000000dEaD; // replace this with the actual burn address
    }

    function deposit(address token) public payable {
        require(msg.value > 0);
        (bool success,) = address(token).call(abi.encodeWithSignature("transfer(address,uint256)", address(this), msg.value));
        require(success);
        balanceOf[msg.sender][token] += msg.value;
    }

    function setBurn(uint rate) public {
        require(msg.sender == owner);
        require(rate > 0);
        startTime = block.timestamp;
        burnRate = rate;
    }

    function burn(address token) public {
    require(msg.sender == owner); // only the owner can burn tokens
    require(burnRate > 0); // burn rate needs to be set before burning tokens
    uint elapsed = block.timestamp - startTime; // calculate the elapsed time since last burn
    uint burnAmount = elapsed * burnRate / 1e18 / 24 hours; // calculate the burn amount based on elapsed time and burn rate
    require(balanceOf[msg.sender][token] >= burnAmount); // check if the smart contract has enough balance to burn
    (bool success,) = address(token).call(abi.encodeWithSignature("transfer(address,uint256)", burnAddress, burnAmount)); // transfer the burn amount to the burn address
    require(success); // require the transfer to be successful
    balanceOf[msg.sender][token] -= burnAmount; // update the smart contract's balance
}


    function withdraw(address token, uint amount) public {
        require(balanceOf[msg.sender][token] >= amount);
        (bool success,) = address(token).call(abi.encodeWithSignature("transfer(address,uint256)", msg.sender, amount));
        require(success);
        balanceOf[msg.sender][token] -= amount;
    }
}