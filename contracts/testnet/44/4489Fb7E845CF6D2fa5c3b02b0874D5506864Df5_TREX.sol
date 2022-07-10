// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./ERC20.sol";

contract TREX is ERC20
{
    function mint(uint256 amount) public onlyOwner {
        _mint(_msgSender(), amount);
    }

    function burn(uint256 amount) public onlyOwner {
        _burn(_msgSender(), amount);
    }
}