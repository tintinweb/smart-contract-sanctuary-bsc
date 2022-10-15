// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "ERC20.sol";
import "ERC20Burnable.sol";
import "draft-ERC20Permit.sol";
import "ERC20Votes.sol";
import "ERC20FlashMint.sol";
import "Ownable.sol";

/// @custom:security-contact [email protected]
contract GRADIENTAM is ERC20, ERC20Burnable, ERC20Permit, ERC20Votes, ERC20FlashMint, Ownable {
    constructor() ERC20("GRADIENT.A.M.", "GRADI") ERC20Permit("GRADIENT.A.M.") {
        _mint(msg.sender, 32000000 * 10 ** decimals());
    }

    // The following functions are overrides required by Solidity.

    function _afterTokenTransfer(address from, address to, uint256 amount)
        internal
        override(ERC20, ERC20Votes)
    {
        super._afterTokenTransfer(from, to, amount);
    }

    function _mint(address to, uint256 amount)
        internal
        override(ERC20, ERC20Votes)
    {
        super._mint(to, amount);
    }

    function _burn(address account, uint256 amount)
        internal
        override(ERC20, ERC20Votes)
    {
        super._burn(account, amount);
    }
}