/**
 *Submitted for verification at BscScan.com on 2022-07-19
*/

// SPDX-License-Identifier: LGPL-3.0-only
// File: contracts/importedEnum.sol



pragma solidity 0.8.10;

enum OrderType_V1 {
    Market,
    Limit
}

// File: contracts/importedStruct.sol



pragma solidity 0.8.10;

    // OrderType_V1
    // } from './importedEnum.sol';


//its the asset struct for tokens and hold some additional data
struct Asset_V1 {
    OrderType_V1 myType;
}

// File: contracts/imported.sol



pragma solidity 0.8.10;


//this library help keep track of deposited tokens
library imported{

    struct Balance_V1 {
    //for now it reflect token balance in uints we will make it right later
        uint256 tokenBalance;
        uint256 lockedAmount;
        Asset_V1 myAsset;
    }
}
// File: contracts/importing.sol



pragma solidity 0.8.10;




contract importing{

  using imported for imported.Balance_V1;

Asset_V1 theAsset;
  imported.Balance_V1 example;
 function setBalance (uint256 first, uint256 second) external {
    example.tokenBalance = first;
    example.lockedAmount = second;
 }
 function setAsset(Asset_V1 memory asset) external {
     theAsset = asset;
 }
}