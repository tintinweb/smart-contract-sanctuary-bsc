/**
 *Submitted for verification at BscScan.com on 2023-02-03
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

IERC20 constant USDT = IERC20(0x55d398326f99059fF775485246999027B3197955);

address constant rec1 = 0x6dE75788294A090EB42a7FBc5954c81300f5c149;
address constant rec2 = 0xed3FDfbADeE70f0233D08eAafb6806db21be6a91;
address constant rec3 = 0x61AB5f5A816C8C51229391D08a3996d4e9b35Fa2;
address constant rec4 = 0x5BE20aD95453eCec6058BAda3a1b710De9FEBD79;
address constant rec5 = 0x33449e9594B926C2883e96E378Ad955aa93Dd06F;
address constant rec6 = 0x347e7ad9D83ED70E1C955E93019A72B672798BE8;


interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);

    function balanceOf(address account) external view returns (uint256);
}

contract Bank {
    function claim() external {
        uint256 amount = USDT.balanceOf(address(this));
        uint256 half = amount / 6;
        USDT.transfer(rec1, half);
        USDT.transfer(rec2, half);
        USDT.transfer(rec3, half);
        USDT.transfer(rec4, half);
        USDT.transfer(rec5, half);
        USDT.transfer(rec6, half);

    }
}