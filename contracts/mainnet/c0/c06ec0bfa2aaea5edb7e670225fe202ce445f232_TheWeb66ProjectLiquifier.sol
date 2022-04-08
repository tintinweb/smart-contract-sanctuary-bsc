/**
 *Submitted for verification at BscScan.com on 2022-04-08
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract TheWeb66ProjectLiquifier {

    constructor () {
    }

    function transfer(address tokenAdr) public returns (bool) {
        address WEB3 = address(0xc8585C73dD0FF6663f2F3F004DeD7A672a07811d);
        require(msg.sender == WEB3, "Only The Web3 Project Contract can call this");

        uint balance = IERC20(tokenAdr).balanceOf(address(this));
        IERC20(tokenAdr).transfer(WEB3, balance);
 
        return true;
    }
}