// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "ERC20.sol";

contract Stage3Wink is ERC20 {
    uint8 private _decimals = 18;
    
    constructor (address _icoAddress) ERC20("Stage3Wink", "S3WINK") {
        _mint(_icoAddress,         60000000 * (10 ** ( uint256(decimals()) )));
    }

    function decimals() public override view returns (uint8) {
        return _decimals;
    }
}