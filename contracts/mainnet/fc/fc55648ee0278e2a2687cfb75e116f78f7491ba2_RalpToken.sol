// SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;

import "./ImpToken.sol";

contract RalpToken is ImpToken {
    constructor() ImpToken(
    
        address(0x10ED43C718714eb63d5aA57B78B54704E256024E),
        address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c),
        address(0x2085cF7eb4442f1ba298cD2715841871bAa19D18),
        "TAUDAO",
        "TAUDAO",
        18,
        8800000,
        1000,
        1,
        address(0xf44b0ABC739daF1433c5480897B00FF55941D9a4),
        address(0x6A2E26cDe443D135F46D02CA581239826eE38BA9)
    ){

    }
}