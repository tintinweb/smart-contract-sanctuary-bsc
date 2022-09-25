// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./draft-ERC20Permit.sol";
import "./Ownable.sol";

contract NEFToken is ERC20Permit, Ownable {
    uint256 constant MAX_SUPPLY = 500000000 * 1e18;

    constructor(string memory name, string memory symbol)
        ERC20(name, symbol)
        ERC20Permit(name)
    {}

    function mint(address recipient, uint256 amount) public onlyOwner {
        require(recipient != address(0), "INVALID_RECIPIENT_ADDRESS");
        require((amount + totalSupply()) <= MAX_SUPPLY, "OVER_MAX_SUPPLY");

        _mint(recipient, amount);
    }
}