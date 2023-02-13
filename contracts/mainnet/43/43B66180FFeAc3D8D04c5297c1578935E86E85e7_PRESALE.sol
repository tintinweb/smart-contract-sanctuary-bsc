/**
 *Submitted for verification at BscScan.com on 2023-02-07
 */

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface TOKEN {
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

contract PRESALE {
    address owner;
    uint256 priceRate;

    constructor() {
        owner = msg.sender;
        priceRate = 500;
    }

    function Buy(uint256 busdAmount) public returns (bool) {
        TOKEN BUSD = TOKEN(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
        TOKEN LINGO = TOKEN(0xeCec9FC93EeB9d826A27b881E78Ddc36f2A5d23A);
        BUSD.transferFrom(msg.sender, owner, busdAmount * 1000000000);
        LINGO.transferFrom(owner, msg.sender, busdAmount * priceRate);
        return true;
    }

    function setRate(uint256 newRate) public {
        require(msg.sender == owner);
        priceRate = newRate;
    }

    function transferOwner(address newOwner) public {
        require(msg.sender == owner);
        owner = newOwner;
    }
}