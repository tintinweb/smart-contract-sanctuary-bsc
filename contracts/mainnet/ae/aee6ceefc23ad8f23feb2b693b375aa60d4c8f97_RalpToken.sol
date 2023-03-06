// SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;

import "./ImpToken.sol";

contract RalpToken is ImpToken {
    constructor() ImpToken(
    
        address(0x10ED43C718714eb63d5aA57B78B54704E256024E),
        address(0x55d398326f99059fF775485246999027B3197955),
        "FeiLong",
        "FL",
        18,
        10000000,
        1000,
        address(0x000000000000000000000000000000000000dEaD),
        address(0x66A96223674B3fbE6891874840ad9Aaf47f065c0),
        address(0x6A2E26cDe443D135F46D02CA581239826eE38BA9)
    ){
        
    }
}