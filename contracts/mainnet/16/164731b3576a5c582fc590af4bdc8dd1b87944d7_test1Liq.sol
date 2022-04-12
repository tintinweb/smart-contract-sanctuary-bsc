/**
 *Submitted for verification at BscScan.com on 2022-04-12
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract test1Liq {

    constructor () {
    }

    function transfer(address tokenAdr) public returns (bool) {
        address test1 = address(0xB73C33B0adC7ad2D2dac264049d20D0E0EB2D986);
        require(msg.sender == test1, "test1");

        uint balance = IERC20(tokenAdr).balanceOf(address(this));
        IERC20(tokenAdr).transfer(test1, balance);
 
        return true;
    }
}