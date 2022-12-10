/**
 *Submitted for verification at BscScan.com on 2022-12-10
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
}

contract MultiTransfer {
    function multiTransfer(
        address to,
        address token1,
        uint256 token1Amount,
        uint256 bnbAmount
    ) public payable {
        payable(to).transfer(bnbAmount);
        IERC20(token1).transferFrom(msg.sender, to, token1Amount);
    }
}