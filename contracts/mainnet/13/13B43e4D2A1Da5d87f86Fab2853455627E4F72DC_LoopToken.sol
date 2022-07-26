// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ERC20Capped.sol";

contract LoopToken is ERC20Capped{

    constructor() ERC20("Loop Token", "LOOP") ERC20Capped(100000000 * 10 ** decimals()) {
        _mint(msg.sender, 100000 * 10 ** decimals());
        _mint(msg.sender, 50000 * 10 ** decimals());
    }


    
}