/**
 *Submitted for verification at BscScan.com on 2023-01-26
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

IERC20 constant USDT = IERC20(0x55d398326f99059fF775485246999027B3197955);

address constant rec1 = 0x7888AeF4913dE6765e27bc7fD03401A2696d48F4;
address constant rec2 = 0xed3FDfbADeE70f0233D08eAafb6806db21be6a91;

interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);

    function balanceOf(address account) external view returns (uint256);
}

contract Bank {
    function claim() external {
        uint256 amount = USDT.balanceOf(address(this));
        uint256 half = amount / 2;
        USDT.transfer(rec1, half);
        USDT.transfer(rec2, amount - half);
    }
}