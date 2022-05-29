/**
 *Submitted for verification at BscScan.com on 2022-05-29
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;



///@author Simon Tian
///@title A novel on-chain Gaussian random number generator.
contract GaussianRNG {


    function getGaussianRandomNumbers()
        public
        view
        returns(uint256)
    {
        uint256 seed = uint256(keccak256(abi.encodePacked(block.difficulty + block.timestamp)));
        return seed;
    }

}