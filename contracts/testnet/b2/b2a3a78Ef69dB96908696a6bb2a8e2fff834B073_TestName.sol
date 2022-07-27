// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "ERC20.sol";

/// @custom:security-contact [email protected]
contract TestName is ERC20 {
    constructor() ERC20("testName", "testSymbol") {
        _mint(msg.sender, 200000000);
    }

    function decimals() public view virtual override returns (uint8) {
        return 0;
    }

}