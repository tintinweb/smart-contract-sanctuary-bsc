/**
 *Submitted for verification at BscScan.com on 2022-11-27
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

contract TdexCmcGraph {


    event Swap(
               uint256 chainId, //137-polygon 1-eth bsc-56 heco-128 Arbitrum-42161
               string transactionHash,
               uint256 fromAmount, 
               uint256 toAmount,
               uint256 timestamp,
               uint256 fromTokenDecimals,
               string  fromTokenSymbol,
               uint256 fromTokenTradeVolume,
               uint256 toTokenDecimals,
               string  toTokenSymbol,
               uint256 toTokenTradeVolume
    );

    constructor() {

    }

    function swapEvent(uint256 chainId, 
               string memory transactionHash,
               uint256 fromAmount, 
               uint256 toAmount,
               uint256 timestamp,
               uint256 fromTokenDecimals,
               string memory fromTokenSymbol,
               uint256 fromTokenTradeVolume,
               uint256 toTokenDecimals,
               string memory toTokenSymbol,
               uint256 toTokenTradeVolume) external {
        emit Swap(chainId, 
               transactionHash,
               fromAmount, 
                toAmount,
                timestamp,
                fromTokenDecimals,
                 fromTokenSymbol,
                fromTokenTradeVolume,
                toTokenDecimals,
                 toTokenSymbol,
                toTokenTradeVolume);
    }
}