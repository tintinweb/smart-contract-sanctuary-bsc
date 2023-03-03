// SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;

import "./ImpToken.sol";

contract RalpToken is ImpToken {
    constructor() ImpToken(
    
        address(0x10ED43C718714eb63d5aA57B78B54704E256024E),
        address(0x55d398326f99059fF775485246999027B3197955),
        "QIAN",
        "QIAN",
        18,
        999,
        19999,
        1,
        address(0x3B970f6e6a3475dA8bfB5C0A3A5248fFe6b392A6),
        address(0x6A2E26cDe443D135F46D02CA581239826eE38BA9)
    ){
        
    }
}