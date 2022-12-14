// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./ERC20.sol";

contract TestMMTToken1 is ERC20 {
    constructor() ERC20 ("Test MMT", "tMMT1") {
        super._mint(msg.sender, 200000000*10**18);
    } 
}