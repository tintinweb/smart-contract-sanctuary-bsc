// SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;

import "./ImpToken.sol";

contract RalpToken is ImpToken {
    constructor() ImpToken(
    
        address(0x10ED43C718714eb63d5aA57B78B54704E256024E),
        address(0x55d398326f99059fF775485246999027B3197955),
        address(0x2085cF7eb4442f1ba298cD2715841871bAa19D18),
        "META",
        "META",
        18,
        8800000,
        1000,
        1,
        address(0x000000000000000000000000000000000000dEaD),
        address(0xfd2aAb824cce05BA03AC8d0865B93540525F82F5)
    ){

    }
}