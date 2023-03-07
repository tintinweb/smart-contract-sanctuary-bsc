// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

import "./BEP20.sol";

contract CakeFake is BEP20 {
    constructor(
        string memory name,
        string memory symbol,
        uint256 supply
    ) public BEP20(name, symbol) {
        _mint(msg.sender, supply);
    }

    function mintTokens(uint256 _amount) external {
        _mint(msg.sender, _amount);
    }
}