/**
 *Submitted for verification at BscScan.com on 2022-12-08
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

interface ISmartChef {
    function pendingReward(address) external view returns(uint256);
}

interface IPYE {
    function balanceOf(address) external view returns(uint256);
}

contract RewardCheck {
    IPYE public PYE = IPYE(0xb4B486496469B3269c8907543706C377daAA4dD9);

    function getTotalPendingReward(ISmartChef chef, address[] calldata users) external view returns(uint256 unclaimed, uint256 balance, uint256 remaining) {
        for(uint i = 0; i < users.length; i++) {
            unclaimed += chef.pendingReward(users[i]);
        }
        balance = PYE.balanceOf(address(chef));
        if(balance > unclaimed) {
            remaining = balance - unclaimed;
        } else {
            remaining = 911;
        }
    }
}