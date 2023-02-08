/**
 *Submitted for verification at BscScan.com on 2023-02-07
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

// contract interface

contract BUSD {
    bool public paused = false;

    modifier whenNotPaused() {
        require(!paused, "whenNotPaused");
        _;
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) public whenNotPaused returns (bool) {}
}

contract LINGO {
    function transfer(address _to, uint256 _value) public returns (bool) {}
}

contract BuyLINGO {
    address owner;

    constructor() {
        owner = msg.sender;
    }

    function getLINGO(address _to, uint256 busdAmount) public {
        LINGO LINGOContract = LINGO(0xaAF7B40eF60677cFA7035fa539F27b9F53eDDEBb);
        BUSD(0xaB1a4d4f1D656d2450692D237fdD6C7f9146e814).transferFrom(
            msg.sender,
            owner,
            busdAmount
        );
        LINGOContract.transfer(_to, busdAmount * 333);
    }
}