/**
 *Submitted for verification at BscScan.com on 2022-10-15
*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

contract BscCoinV3 {
    string public unlockTime;
    constructor()  {
    }

    function withdraw() public  view returns(string memory){
        return unlockTime;
    }
}