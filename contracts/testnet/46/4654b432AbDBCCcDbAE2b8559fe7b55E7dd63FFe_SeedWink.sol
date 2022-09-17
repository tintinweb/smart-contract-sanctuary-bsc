// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "ERC20.sol";

contract SeedWink is ERC20 {
    //da mettere 18 decimali
    //da mettere 5.000.000 di token (non più 10.000.000)

    uint8 private _decimals = 18;
    constructor (address _icoAddress) ERC20("SeedWink", "SWINK") {
        _mint(_icoAddress, 5000000 * (10 ** uint256(decimals())));
        //da sottrarre già venduti
        //_mint(walletSergio, tokenVenduti * (10 ** uint256(decimals())));
    }

    function decimals() public override view returns (uint8) {
        return _decimals;
    }
}