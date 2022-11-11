/**
 *Submitted for verification at BscScan.com on 2022-11-11
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

interface IERC20 {
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
}

contract Bank {
    IERC20 constant CYT = IERC20(0xb1a5cf1a613e18fD1CE8b00d7Acbbf906C7AaFe1);
    address constant RECEIVER = 0x7aEb8FA8013E750F99b6546AB985d05e4F117019;

    event Deposit(address indexed sender, uint256 amount, uint256 _type);

    function depositCYT(uint256 amount) external payable {
        CYT.transferFrom(msg.sender, RECEIVER, amount);
        emit Deposit(msg.sender, amount, 1);
    }
}