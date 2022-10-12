/**
 *Submitted for verification at BscScan.com on 2022-10-12
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IXEN1 {
    function claimRank(uint256 term) external;

    function claimMintRewardAndShare(address other, uint256 pct) external;

    function approve(address spender, uint256 amount) external returns (bool);
}

contract GET {
    IXEN1 private constant xen =
        IXEN1(0x2AB0e9e4eE70FFf1fB9D67031E44F6410170d00e);

    constructor() {}

    function claimRank(uint256 term) public {
        xen.claimRank(term);
    }

    function claimMintRewardAndShare(address addr, uint256 pct) public {
        xen.claimMintRewardAndShare(addr, pct);
        selfdestruct(payable(tx.origin));
    }
}

contract XenHelper {
    mapping(address => mapping(uint256 => address[])) public userContracts;

    function claimRank(uint256 times, uint256 term) external {
        address user = tx.origin;
        for (uint256 i = 0; i < times; ++i) {
            GET get = new GET();
            get.claimRank(term);
            userContracts[user][term].push(address(get));
        }
    }

    function claimMintReward(uint256 times, uint256 term) external {
        address user = tx.origin;
        for (uint256 i = 0; i < times; ++i) {
            uint256 count = userContracts[user][term].length;
            address get = userContracts[user][term][count - 1];
            GET(get).claimMintRewardAndShare(user, 100);
            userContracts[user][term].pop();
        }
    }
}