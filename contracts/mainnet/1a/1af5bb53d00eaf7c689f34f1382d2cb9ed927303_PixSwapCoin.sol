// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "./ERC20.sol";
import "./Ownable.sol";
import "./ERC20Pausable.sol";
import "./ERC20Burnable.sol";

contract PixSwapCoin is ERC20, Ownable, ERC20Pausable, ERC20Burnable {
    mapping (address => bool) private _frozenWallets;
    error walletFrozen();

    constructor() ERC20("PixSwap Coin", "PIXSWAP") {
        _mint(msg.sender, 1_000_000_000*(10**18));
    }
    
    function decimals() public pure override returns (uint8) {
        return 18;
    }

    function renounceOwnership() public onlyOwner override {
        // Do nothing
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function freezeWallet(address wallet) public onlyOwner {
        _frozenWallets[wallet] = true;
    }
    function unFreezeWallet(address wallet) public onlyOwner {
        _frozenWallets[wallet] = false;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual override(ERC20, ERC20Pausable) {
        super._beforeTokenTransfer(from, to, amount);
        if (_frozenWallets[from]) revert walletFrozen();
    }
}