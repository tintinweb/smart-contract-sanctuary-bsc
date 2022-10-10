/**
 *Submitted for verification at BscScan.com on 2022-10-09
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.7.4;

library RexSafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, 'REX: addition overflow');
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, 'REX: subtraction overflow');
        uint256 c = a - b;
        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, 'REX: multiplication overflow');

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, 'REX: division by zero');
        uint256 c = a / b;
        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, 'REX: modulo by zero');
        return a % b;
    }
}

contract RandomNumberCalculator {

    using RexSafeMath for uint256;
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