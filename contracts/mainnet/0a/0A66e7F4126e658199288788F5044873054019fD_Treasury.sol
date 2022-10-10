/**
 *Submitted for verification at BscScan.com on 2022-10-10
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Treasury {
    event TokensPurchased(
        address indexed purchaser,
        address indexed beneficiary,
        uint256 value,
        uint256 amount
    );
    event TokensWithdraw(
        address indexed purchaser,
        address indexed beneficiary,
        uint256 value,
        uint256 amount
    );

    function Contribute(address purchaser, address beneficiary, uint256 value, uint256 amount) external {
        emit TokensPurchased(purchaser, beneficiary, value, amount);
    }

    function WithdrawContribute(address purchaser, address beneficiary, uint256 value, uint256 amount) external {
        emit TokensWithdraw(purchaser, beneficiary, value, amount);
    }
}