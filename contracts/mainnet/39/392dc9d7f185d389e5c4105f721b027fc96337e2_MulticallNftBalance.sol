/**
 *Submitted for verification at BscScan.com on 2022-10-31
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

interface IKalmy {
    function userInfo(uint256 pid, address user) external returns (uint256, uint256);
}

contract MulticallNftBalance {
    address public KalmyStaking = 0xc7b92e4a5983DeA5751B9cb027b2478388dE353c;

    address public PancakeSquad = 0x0a8901b0E25DEb55A87524f0cC164E9644020EBA;
    address public MoonPets = 0xE32aE22Ec60E21980247B4bDAA16E9AEa265F919;
    address public KalmyNft = 0x73096042a5297128e2bB074Bd91450Db58F3B4eA;

    function call(address target, address[] memory addresses) external returns (uint256[] memory) {
        uint256[] memory balances = new uint256[](addresses.length);

        for (uint256 i = 0; i < addresses.length; i++){
            balances[i] = IBal(target).balanceOf(addresses[i]);
        }

        //Check if user has PancakeSquad used as Profile
        if (target == PancakeSquad){
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

        //Check if users have staked their NFTs on Kalmy
        if (target == PancakeSquad){
          uint256 len = addresses.length;
          for (uint256 i = 0; i < len;){
              if (balances[i] == 0){
                  (uint256 amount, ) = IKalmy(KalmyStaking).userInfo(3, addresses[i]);
                  if (amount >= 1){
                    balances[i] = amount;
                  }
              }
              unchecked { ++i; }
          }
        }

        if (target == MoonPets){
          uint256 len = addresses.length;
          for (uint256 i = 0; i < len;){
              if (balances[i] == 0){
                  (uint256 amount, ) = IKalmy(KalmyStaking).userInfo(2, addresses[i]);
                  if (amount >= 1){
                    balances[i] = amount;
                  }
              }
              unchecked { ++i; }
          }
        }

        if (target == KalmyNft){
          uint256 len = addresses.length;
          for (uint256 i = 0; i < len;){
              if (balances[i] == 0){
                  (uint256 amount, ) = IKalmy(KalmyStaking).userInfo(0, addresses[i]);
                  if (amount >= 1){
                    balances[i] = amount;
                  }
              }
              unchecked { ++i; }
          }
        }

        return balances;
    }
}