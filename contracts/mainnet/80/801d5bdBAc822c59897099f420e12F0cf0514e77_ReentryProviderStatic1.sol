// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


library ReentryProviderStatic1 {
    function getReentries(address, uint256) external pure returns (uint256) {
        return 1;
    }
}