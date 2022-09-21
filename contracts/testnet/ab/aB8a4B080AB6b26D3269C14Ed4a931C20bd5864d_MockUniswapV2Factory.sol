/**
 *Submitted for verification at BscScan.com on 2022-08-25
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

contract MockUniswapV2Factory {
    mapping(address => mapping(address => address)) public getPair;
    address[] public allPairs;

    address public weth = 0x3e1DF6CA40E26efd07727CAdD1ECC25F641671c4;

    constructor() {
    }

    function allPairsLength() external view returns (uint) {
        return allPairs.length;
    }

    function getAllPairs() external view returns (address[] memory) {
        return allPairs;
    }

    function addPair(address tokenA, address tokenB, address pair) public {
        (address token0, address token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);

        getPair[token0][token1] = pair;
        getPair[token1][token0] = pair; // populate mapping in the reverse direction
        allPairs.push(pair);
    }

    function setPair(address) public { //dummie function for compatibleness 
    }

    function setPairExist(bool) public { //dummie function for compatibleness 
    }
}