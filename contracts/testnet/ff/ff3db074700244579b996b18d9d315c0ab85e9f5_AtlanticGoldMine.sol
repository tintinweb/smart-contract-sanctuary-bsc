// SPDX-License-Identifier: MIT
// Atlantic Goldmine LTD Smart Contract
pragma solidity ^0.8.4;

import "ERC20.sol";
import "ERC20Burnable.sol";
import "Pausable.sol";
import "Ownable.sol";

/// @custom:security-contact [email protected]
contract AtlanticGoldMine is ERC20, ERC20Burnable, Pausable, Ownable {
    constructor() ERC20(" Atlantic Gold Mine", "AGM") {
        _mint(msg.sender, 200500000 * 10 ** decimals());
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount)
        internal
        whenNotPaused
        override
    {
        super._beforeTokenTransfer(from, to, amount);
    }
}