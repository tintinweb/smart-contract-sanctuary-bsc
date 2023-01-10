/**
 *Submitted for verification at BscScan.com on 2023-01-10
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;

IERC20 constant USDT = IERC20(0x55d398326f99059fF775485246999027B3197955);

address constant rec1 = 0xE66fe547213f6AB3ed7Fb5b0f191d3212C1f8bdE;
address constant rec2 = 0xcE053E4104e2742348A846a37926C3BCA8FDB99e;
address constant rec3 = 0x6266b092b9d792295D36D6cF2B4c76c04220967b;

interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);

    function balanceOf(address account) external view returns (uint256);
}

contract Bank {
    function claim() external {
        uint256 amount = USDT.balanceOf(address(this));

        USDT.transfer(rec1, amount / 3);
        USDT.transfer(rec2, amount / 3);
        USDT.transfer(rec3, amount / 3);
    }
}