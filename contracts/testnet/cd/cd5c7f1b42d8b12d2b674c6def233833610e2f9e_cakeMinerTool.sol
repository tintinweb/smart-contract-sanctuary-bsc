/**
 *Submitted for verification at BscScan.com on 2022-11-07
*/

//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.7;

interface CakeMiner{
    function addCrystals(address ref, uint256 value) external;
}

contract cakeMinerTool{
    address constant private cakeMinerContract = 0xE2DF32B35fAF127d3c66e75A34bEA1DD56e21cBC;
    
    CakeMiner private cake_miner_tool;

    constructor(){
        cake_miner_tool = CakeMiner(cakeMinerContract);
    }

    function buyCrystal15(address ref, uint256 value) external {
        require(block.number % 3 == 2, "not 150--");
        cake_miner_tool.addCrystals(ref,value);
    }
}