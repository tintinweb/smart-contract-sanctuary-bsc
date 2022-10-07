/**
 *Submitted for verification at BscScan.com on 2022-10-06
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

contract testContract {
    function getBlockNum()public view returns (uint){
        return block.number;
    }

    function getOldBlockHash(uint blockNum)public view returns (bytes32){
        return blockhash(blockNum);
    }
}