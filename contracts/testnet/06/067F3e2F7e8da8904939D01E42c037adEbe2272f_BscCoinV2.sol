/**
 *Submitted for verification at BscScan.com on 2022-10-15
*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

contract BscCoinV2 {
    string public unlockTime;
    constructor(string memory _unlockTime)  {
        unlockTime = _unlockTime;
    }

    function withdraw() public  view returns(string memory){
        return unlockTime;
    }
}