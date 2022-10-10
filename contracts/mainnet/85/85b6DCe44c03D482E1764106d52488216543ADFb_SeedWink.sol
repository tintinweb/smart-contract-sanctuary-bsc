// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "ERC20.sol";

contract SeedWink is ERC20 {
    uint8 private _decimals = 18;
    
    constructor (address _icoAddress, address _privateSaleAddress) ERC20("SeedWink", "SWINK") {
        _mint(_icoAddress,         14000000 * (10 ** ( uint256(decimals()) )));
        _mint(_privateSaleAddress, 11000000 * (10 ** ( uint256(decimals()) )));
    }

    function decimals() public override view returns (uint8) {
        return _decimals;
    }
}