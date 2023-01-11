/**
 *Submitted for verification at BscScan.com on 2023-01-11
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.17;



contract KuJobFairContract {

    uint256 visitedAmount;


     function visit(uint256 amount) external {
         visitedAmount =  visitedAmount + amount;
    }

}