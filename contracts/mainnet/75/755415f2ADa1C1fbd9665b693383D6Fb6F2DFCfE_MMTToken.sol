// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./ERC20.sol";

contract MMTToken is ERC20 {
    constructor() ERC20 ("MarsMinerToken", "MMT") {
        super._mint(msg.sender, 200000000*10**18);
    } 
}