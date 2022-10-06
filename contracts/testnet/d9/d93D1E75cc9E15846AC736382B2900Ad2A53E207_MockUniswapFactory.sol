// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

interface IDexFactory {
    function getPair(address tokenA, address tokenB) external view returns (address pair);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import './../interfaces/IDexFactory.sol';

contract MockUniswapFactory is IDexFactory {
    mapping(address => mapping(address => address)) pairs;

    function addPair(
        address tokenA,
        address tokenB,
        address pair
    ) external {
        pairs[tokenA][tokenB] = pair;
        pairs[tokenB][tokenA] = pair;
    }

    function getPair(address tokenA, address tokenB) external view returns (address) {
        return pairs[tokenA][tokenB];
    }
}