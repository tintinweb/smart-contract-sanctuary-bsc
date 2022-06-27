// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

import "./TokenTimelock.sol";

contract InvestmentsLiquidityLock is TokenTimelock {
    constructor(
        IERC20 _token,
        address presaleCreator,
        address presaleAddress,
        uint256 _releaseTime
    ) public TokenTimelock(_token, presaleCreator, presaleAddress, _releaseTime) {}

}