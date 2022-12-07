// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.17;

import "./SafeMath.sol";

library SaleHelper {
    using SafeMath for uint256;

    function calculateAmountRequired(uint256 _amount, uint256 _tokenFeePercent) public pure returns (uint256) {
        uint256 tokenFeeAmount = _amount.mul(_tokenFeePercent).div(1000);
        uint256 tokenAmountRequired = _amount.add(tokenFeeAmount);
        return tokenAmountRequired;
    }
}