// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DevPancakeFactory {
    mapping(address => mapping(address => address)) public pairs;

    function getPair(address token0, address token1) public view returns (address) {
        return pairs[token0][token1];
    }

    function setPair(address token0, address token1, address _contract) public {
        pairs[token0][token1] = _contract;
    }
}