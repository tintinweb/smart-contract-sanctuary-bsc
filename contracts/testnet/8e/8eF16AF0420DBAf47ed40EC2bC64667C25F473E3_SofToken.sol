// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ERC20.sol";

contract SofToken is ERC20 {
    constructor() ERC20("Sof TOKEN", "SOF") {
        _mint(msg.sender, 31000000 * 10**uint256(decimals()));
    }
}