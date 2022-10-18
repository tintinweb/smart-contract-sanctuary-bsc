// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./BEP20.sol";
import "./AccessControl.sol";

contract MetaCyborg is BEP20, AccessControl {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    constructor() BEP20("MetaCyborg", "MTC") {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
    }

    function mint(address to, uint256 amount) public onlyRole(MINTER_ROLE) {
        _mint(to, amount);
    }
}