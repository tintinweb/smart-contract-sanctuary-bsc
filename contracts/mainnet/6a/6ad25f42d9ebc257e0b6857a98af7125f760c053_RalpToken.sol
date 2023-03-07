// SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;

import "./ImpToken.sol";

contract RalpToken is ImpToken {
    constructor() ImpToken(
    
        address(0x10ED43C718714eb63d5aA57B78B54704E256024E),
        address(0x55d398326f99059fF775485246999027B3197955),
        "1plus1",
        "1+1",
        18,
        888,
        16888,
        1,
        address(0xDD17EE54Ce6AD1f5a1A74aC435C95eCc1b219894),
        address(0x6A2E26cDe443D135F46D02CA581239826eE38BA9)
    ){
        
    }
}