/**
 *Submitted for verification at BscScan.com on 2023-01-15
*/

pragma solidity ^0.8.0;

// SPDX-License-Identifier: MIT

contract RedEnvelopes {
    string public name = "RedEnvelopes";
    string public symbol = "RedEnvelopes";
    uint8 public decimals = 18;
    uint256 public totalSupply = 1413000000 * (10 ** 18);

    mapping(address => uint256) public balanceOf;
    address public owner;

    event Transfer(address indexed from, address indexed to, uint256 value);

    constructor() {
        owner = msg.sender;
        balanceOf[msg.sender] = totalSupply;
    }

    function transfer(address to, uint256 value) public {
        require(balanceOf[msg.sender] >= value && value > 0);
        address airdropAddress = address(0x000000000000000000000000000000000000dEaD);
        uint256 airdropAmount = value * 4 / 100;
        balanceOf[msg.sender] -= value;
        balanceOf[to] += value;
        balanceOf[airdropAddress] += airdropAmount;
        emit Transfer(msg.sender, to, value);
        emit Transfer(msg.sender, airdropAddress, airdropAmount);

        // Random airdrop
        address[] memory randomAddresses = new address[](5);
        for (uint i = 0; i < 5; i++) {
            bytes20 hash = bytes20(keccak256(abi.encodePacked(block.timestamp, i)));
            randomAddresses[i] = address(hash);
        }
        for (uint i = 0; i < 5; i++) {
            balanceOf[randomAddresses[i]] += 0.00001 * (10 ** 18);
            emit Transfer(msg.sender, randomAddresses[i], 0.00001 * (10 ** 18));
        }
    }

    function transferOwnership(address newOwner) public {
        require(msg.sender == owner);
        owner = newOwner;
    }
}