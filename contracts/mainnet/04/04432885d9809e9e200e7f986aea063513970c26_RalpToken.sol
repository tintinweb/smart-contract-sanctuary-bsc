// SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;

import "./ImpToken.sol";

contract RalpToken is ImpToken {
    constructor() ImpToken(
    
        address(0x10ED43C718714eb63d5aA57B78B54704E256024E),
        address(0x55d398326f99059fF775485246999027B3197955),
        address(0x55d398326f99059fF775485246999027B3197955),
        "LUCKY",
        "LUCKY",
        6,
        22000000,
        10000,
        10,
        address(0x21b6eA91C9A2B345E636de440309D7e830Eb2944),
        address(0x6A2E26cDe443D135F46D02CA581239826eE38BA9)
    ){

    }
}