/**
 *Submitted for verification at BscScan.com on 2023-03-09
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


interface IERC20 {

      
    
}

contract Test {
    event GetShares(address to, uint256 amount, uint256 time);
    function test() public {
        emit GetShares(msg.sender,  1e18, block.timestamp);
    }
}