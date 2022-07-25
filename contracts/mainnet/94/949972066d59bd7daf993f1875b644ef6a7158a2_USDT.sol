//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./ERC20.sol";


contract USDT is ERC20 {

    uint8 private _decimals;

    constructor (string memory name_, string memory symbol_, uint8 decimals_, uint256 amount_) ERC20(name_, symbol_)  {
        _decimals = decimals_;
        _mint(msg.sender, amount_);
    }

    function decimals() public view virtual override returns (uint8) {
        return _decimals;
    }
}