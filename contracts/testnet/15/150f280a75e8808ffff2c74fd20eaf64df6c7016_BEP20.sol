// contracts/BEP20.sol
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0 <=0.9.0;

import "./ERC20.sol";

contract BEP20 is ERC20 {
    constructor(uint256 initialSupply) ERC20("BEP20", "BP") {
        _mint(msg.sender, initialSupply);
    }
}