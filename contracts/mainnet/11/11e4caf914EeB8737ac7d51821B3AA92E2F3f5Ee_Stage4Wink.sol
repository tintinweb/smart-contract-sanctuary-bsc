// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "ERC20.sol";

contract Stage4Wink is ERC20 {
    uint8 private _decimals = 18;
    
    constructor (address _icoAddress) ERC20("Stage4Wink", "S4WINK") {
        _mint(_icoAddress,         70000000 * (10 ** ( uint256(decimals()) )));
    }

    function decimals() public override view returns (uint8) {
        return _decimals;
    }
}