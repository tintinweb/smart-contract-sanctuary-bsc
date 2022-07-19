// contracts/GLDToken.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ERC20.sol";

contract HENTAIToken is ERC20 {

    constructor() ERC20("HENTAI TOKEN", "HEN") {
        _mint(msg.sender, 1000000000);
    }

    function decimals() public view virtual override returns (uint8) {
        return 0;
    }

}