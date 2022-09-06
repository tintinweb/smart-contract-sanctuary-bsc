// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

import "./SSSTimelock.sol";

contract SSSlock is SSSTimelock {
    constructor(
        IERC20 _token,
        address lockCreator,
        uint256 _releaseTime
    ) public SSSTimelock(_token, lockCreator, _releaseTime) {}

}