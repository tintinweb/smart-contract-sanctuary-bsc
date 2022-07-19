/**
 *Submitted for verification at BscScan.com on 2022-07-19
*/

// SPDX-License-Identifier: LGPL-3.0-only
// File: contracts/imported.sol



pragma solidity 0.8.10;


//this library help keep track of deposited tokens
library imported{


    struct Balance_V1 {
    //for now it reflect token balance in uints we will make it right later
        uint256 tokenBalance;
        uint256 lockedAmount;
    }
}
// File: contracts/importing.sol



pragma solidity 0.8.10;


contract importing{

  using imported for imported.Balance_V1;

  imported.Balance_V1 example;
 function setBalance (uint256 first, uint256 second) external {
    example.tokenBalance = first;
    example.lockedAmount = second;
 }
}