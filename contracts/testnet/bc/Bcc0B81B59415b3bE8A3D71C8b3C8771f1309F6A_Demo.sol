/**
 *Submitted for verification at BscScan.com on 2022-02-02
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract Demo {
    uint256 public minAmount; // minimum amount (denominated in wei)

    event LogMsgValueIsLarger(uint256 msgValue, uint256 minAmount);
    event LogMinAmountIsLarger(uint256 msgValue, uint256 minAmount);

    constructor(
        uint256 _minAmount
    ) {
        minAmount = _minAmount;
    }

    function func1() external payable {
        require(msg.value >= minAmount, "Msg value must be greater than minAmount");

        // Do something...
    }

    function func2() external payable {
        if (msg.value >= minAmount) {
            emit LogMsgValueIsLarger(msg.value, minAmount);
        } else {
            emit LogMinAmountIsLarger(msg.value, minAmount);
        }

        // Do something...
    }
}