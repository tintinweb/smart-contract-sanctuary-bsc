// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "../ERC20.sol";

/// @custom:security-contact [email protected]
contract ENZNetwork is ERC20 {
    constructor() ERC20("ENZNetwork", "ENZ") {
        _mint(msg.sender, 10000000000 * 10 ** decimals());
    }
}