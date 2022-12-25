// SPDX-License-Identifier: ISC
pragma solidity ^0.8.0;

import "./ERC20.sol";


contract XDP is ERC20 {
    
    constructor() ERC20("XDualPool", "XDP"){
        _mint(msg.sender, 30000000e18);
    }

}