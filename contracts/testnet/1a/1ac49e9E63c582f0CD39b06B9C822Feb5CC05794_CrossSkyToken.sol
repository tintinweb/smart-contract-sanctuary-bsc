// SPDX-License-Identifier: MIT␊
pragma solidity ^0.8.0;

import "./ERC20.sol";
import "./ERC20Burnable.sol";
import "./Ownable.sol";

contract CrossSkyToken is ERC20, ERC20Burnable, Ownable {

    uint private maxSupply = 100000000 * 10 ** 18;

    constructor() ERC20("CrossSkyToken", "CSTK") {
        _mint(msg.sender, maxSupply);
    }

    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

}