/**
 *Submitted for verification at BscScan.com on 2022-10-09
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.16;

contract RandomNumberCalculator {

    constructor() {

    }
    function getRandomNumber(uint256 ceiling)
        public view returns (uint256)
    {
        if (ceiling > 0) {
            uint256 val = uint256(blockhash(block.number - 1)) * uint256(block.timestamp) + (block.difficulty);
            val = val % uint(ceiling);
            return val;
        }
        else return 0;
    }

    function getAnotherRandomNumber(uint256 ceiling)
        public view returns (uint256)
    {
        if (ceiling > 0) {
            uint256 val = uint256(blockhash(block.number - 1)) * (block.difficulty) + uint256(block.timestamp);
            val = val % uint(ceiling);
            return val;
        }
        else return 0;
    }
}