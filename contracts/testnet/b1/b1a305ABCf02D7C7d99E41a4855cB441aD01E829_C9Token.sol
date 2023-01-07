// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./ERC20.sol";

contract C9Token is ERC20 {
    constructor() ERC20 ("Test C9 Token", "tC9") {
        super._mint(msg.sender, 800000000000*10**18);
    } 
}