// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import "./ERC20.sol";
import "./ERC20Burnable.sol";
import "./Blacklistable.sol";

contract TBC is ERC20, ERC20Burnable, Blacklistable {
    constructor(uint256 initialSupply) public ERC20("Tradebit Coin", "TBC") {
        _setupDecimals(9);
        _mint(msg.sender, initialSupply * (10 ** uint256(decimals())));
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual override {
        super._beforeTokenTransfer(from, to, amount);

        require(!isBlacklisted(from), "ERC20WithSafeTransfer: invalid sender");
        require(!isBlacklisted(to), "ERC20WithSafeTransfer: invalid recipient");
    }
}