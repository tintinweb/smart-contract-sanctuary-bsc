/**
 *Submitted for verification at BscScan.com on 2023-02-07
*/

// SPDX-License-Identifier: MIT
// author https://biubiu.tools
// BiuBiu.Tools: Start exploring web3 here.
// Based on Chainlink

pragma solidity ^0.8.0;

interface IChainLink {
    function latestAnswer() external view returns (int256 price);
}

contract PriceOracle {
    address chainlinkAddr;

    constructor(address c) {
        chainlinkAddr = c;
    }

    // How much ETH for USD
    function latestAnswer(uint256 amountOut) public view returns (uint256) {
        IChainLink oracle = IChainLink(chainlinkAddr);
        uint256 price = uint256(oracle.latestAnswer());
        return (amountOut * 1e18) / price;
    }
}