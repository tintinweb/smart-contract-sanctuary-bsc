// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "ERC20.sol";
import "ERC20Burnable.sol";
import "Ownable.sol";

/// @custom:security-contact [email protected]
contract GRADIENT is ERC20, ERC20Burnable, Ownable {
    constructor() ERC20("GRADIENT", "GRADI") {
        _mint(msg.sender, 50000000000 * 10 ** decimals());
    }
}