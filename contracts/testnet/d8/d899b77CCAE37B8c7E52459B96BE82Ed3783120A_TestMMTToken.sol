// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./ERC20.sol";

contract TestMMTToken is ERC20 {
    constructor() ERC20 ("Test MMT", 'tMMT') {
        super._mint(msg.sender, 1000000000000*10**18);
    } 
}