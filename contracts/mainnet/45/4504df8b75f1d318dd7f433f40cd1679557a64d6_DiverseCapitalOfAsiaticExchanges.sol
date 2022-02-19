// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "ERC20.sol";
import "ERC20Burnable.sol";
import "Pausable.sol";
import "Ownable.sol";

contract DiverseCapitalOfAsiaticExchanges is ERC20, ERC20Burnable, Pausable, Ownable {
    constructor() ERC20("Diverse Capital of Asiatic Exchanges", "DCXa") {
        _mint(msg.sender, 2000000000 * 10 ** decimals());
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function minting(uint256 _Amount) public onlyOwner {
        _mint(msg.sender, _Amount * 10 ** decimals());
    }
    function _beforeTokenTransfer(address from, address to, uint256 amount)
        internal
        whenNotPaused
        override
    {
        super._beforeTokenTransfer(from, to, amount);
    }
}