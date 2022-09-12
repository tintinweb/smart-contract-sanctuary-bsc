// contracts/GLDToken.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ERC20.sol";

contract HiTigerTeam is ERC20 {
    constructor(uint256 initialSupply) ERC20("Dipper", "DIPP") {
        _mint(msg.sender, initialSupply);
    }
}