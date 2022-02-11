/**
 *Submitted for verification at BscScan.com on 2022-02-01
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.7.0;

contract test{
    
    function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {
        require(tokenA != tokenB, 'Library: IDENTICAL_ADDRESSES');
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), 'Library: ZERO_ADDRESS');
    }

    function pairFor(address factory, uint intcode, address tokenA, address tokenB) internal pure returns (address pair) {
        (address token0, address token1) = sortTokens(tokenA, tokenB);
        pair = address(uint(keccak256(abi.encodePacked(
                hex'ff',
                factory,
                keccak256(abi.encodePacked(token0, token1)),
                intcode
            ))));
    }
}