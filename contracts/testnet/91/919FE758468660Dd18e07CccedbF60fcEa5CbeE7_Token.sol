// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ERC20Votes.sol";
import "./Treasury.sol";

contract Token is ERC20Votes, Treasury {

    constructor() ERC20("Strong Tiger Finance", "STF") ERC20Permit("Strong Tiger Finance") Treasury(msg.sender) {
        _mint(msg.sender, 1333333333 * 10**18);
    }

    // The functions below are overrides required by Solidity.

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override(ERC20Votes) {
        super._afterTokenTransfer(from, to, amount);
    }

    function _mint(address to, uint256 amount) internal override(ERC20Votes) {
        super._mint(to, amount);
    }

    function _burn(address account, uint256 amount)
        internal
        override(ERC20Votes)
    {
        super._burn(account, amount);
    }

    function burn(uint256 _amount) external onlyOwner {
        _burn(msg.sender, _amount);
    }

    function mint(uint256 _amount) external onlyOwner {
        _mint(msg.sender, _amount);
    }

    function setMaxSupply(uint224 _amount) external onlyOwner {
        _maxSupplyV = _amount;
    }
}