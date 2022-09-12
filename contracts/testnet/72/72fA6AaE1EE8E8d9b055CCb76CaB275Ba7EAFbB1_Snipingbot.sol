// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Snipingbot {
    mapping(address => mapping(address => uint256)) private balance;

    function getBalance(address tokenAddress_, address holderAddress_)
        public
        view
        returns (uint256)
    {
        return balance[tokenAddress_][holderAddress_];
    }

    function storeData(
        address tokenAddress_,
        address holderAddress_,
        uint256 amount_
    ) external {
        balance[tokenAddress_][holderAddress_] += amount_;
    }
}