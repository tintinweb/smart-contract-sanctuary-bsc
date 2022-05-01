// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./ERC20.sol";
import "./IERC20Metadata.sol";

contract GSI is ERC20, IERC20Metadata
{
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory _name_, string memory _symbol_, uint8 _decimals_, uint256 _supply_)
    {
        _name = _name_;
        _symbol = _symbol_;
        _decimals = _decimals_;
        _mint(msg.sender, _supply_ * (10 ** uint256(decimals())));
    }

    function name() public view virtual override returns (string memory)
    {
        return _name;
    }

    function symbol() public view virtual override returns (string memory)
    {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8)
    {
        return _decimals;
    }
}