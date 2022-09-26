// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "ERC20.sol";

contract SeedWink is ERC20 {
    uint8 private _decimals = 18;
    
    constructor (address _icoAddress, address _privateSaleAddress) ERC20("SeedWink", "SWINK") {
        _mint(_icoAddress,         371853439 * (10 ** ( uint256(decimals()) - 2 )));
        _mint(_privateSaleAddress, 128146561 * (10 ** ( uint256(decimals()) - 2 )));
    }

    function decimals() public override view returns (uint8) {
        return _decimals;
    }
}