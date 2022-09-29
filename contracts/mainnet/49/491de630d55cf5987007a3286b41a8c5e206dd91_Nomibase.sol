// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./Context.sol";
import "./ERC20.sol";
import "./Ownable.sol";

contract Nomibase is Context, ERC20, Ownable {

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowed;

    /**
     * @dev Sets the values for {name} and {symbol}.
     */
    constructor(string memory name_, string memory symbol_) ERC20(name_, symbol_) Ownable() {}

    /**
     * @dev Creates `amount` new tokens for `to`.
     *
     * See {ERC20-_mint}.
     *
     * Requirements:
     *
     * - the caller must have the owner role.
     */
    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    /**
     * @dev Destroys `amount` tokens from the caller.
     *
     * See {ERC20-_burn}.
     */
    function burn(uint256 amount) public {
        _burn(_msgSender(), amount);
    }
}