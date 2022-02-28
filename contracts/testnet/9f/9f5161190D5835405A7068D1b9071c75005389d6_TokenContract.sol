// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./ERC20Preselable.sol";

contract TokenContract is ERC20Preselable {
    constructor(
        string memory name_,
        string memory symbol_,
        uint8 decimals_,
        uint256 totalSupply_,
        uint256 totalETHRequired_,
        uint256 minimumETHForEntry_,
        uint256 maximumETHForEntry_,
        uint256 allocatedTokenForPresale_
    )
        ERC20(name_, symbol_, decimals_)
        ERC20Preselable(
            totalETHRequired_,
            minimumETHForEntry_,
            maximumETHForEntry_,
            allocatedTokenForPresale_
        )
    {
        _mint(address(this), totalSupply_);
    }
}