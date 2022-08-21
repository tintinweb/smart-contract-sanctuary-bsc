/**
 *Submitted for verification at BscScan.com on 2022-08-21
*/

/**
 *Submitted for verification at BscScan.com on 2022-08-20
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

interface IBal {
    function balanceOf(address user) external returns (uint256);
}

interface IProfile {
    function getUserProfile(address user) external returns (uint256, uint256, uint256, address, uint256, bool); 
    function hasRegistered(address user) external returns (bool);
}

contract MulticallBalance {
    function call(address target, address[] memory addresses) external returns (uint256[] memory) {
        uint256[] memory balances = new uint256[](addresses.length);

        for (uint256 i = 0; i < addresses.length; i++){
            balances[i] = IBal(target).balanceOf(addresses[i]);
        }

        //Check if user has PancakeSquad used as Profile 
        if (target == 0x0a8901b0E25DEb55A87524f0cC164E9644020EBA){
            uint256 len = addresses.length;
            for (uint256 i = 0; i < len;){
                if (balances[i] == 0){
                    bool hasRegistered = IProfile(0xDf4dBf6536201370F95e06A0F8a7a70fE40E388a).hasRegistered(addresses[i]);
                    if (hasRegistered){
                        (, , , address userProfileAddress, , ) = IProfile(0xDf4dBf6536201370F95e06A0F8a7a70fE40E388a).getUserProfile(addresses[i]);
                        if (userProfileAddress == target){
                            balances[i] = 1;
                        }
                    }
                }
                unchecked { ++i; }
            }
        }

        return balances;
    }
}