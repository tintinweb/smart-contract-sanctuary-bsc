/**
 *Submitted for verification at BscScan.com on 2022-12-10
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;


interface IERC20 {
    function transfer(address to, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}


contract Disperse {

    function disperseTokenSimple(address tokenAddr, address[] memory recipients, uint256[] memory values) external {
        for (uint256 i = 0; i < recipients.length; i++){
            IERC20(tokenAddr).transferFrom(msg.sender, recipients[i], values[i]);
        }
    }
}