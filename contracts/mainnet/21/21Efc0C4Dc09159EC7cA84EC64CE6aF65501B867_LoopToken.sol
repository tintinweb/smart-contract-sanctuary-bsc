// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ERC20.sol";

contract LoopToken is ERC20{
    constructor(){
        _mint(msg.sender,  100000000 * 10 ** decimals());
    }

}