// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;


library SingleNftUtils
{
    /**
    * predictable, should use oracle service - https://stackoverflow.com/a/67332959/10002846
    **/
    function fakeRandom(uint256 max)
    public
    view
    returns
    (uint256)
    {
        uint256 randNum = uint256(keccak256(abi.encodePacked(block.difficulty, block.timestamp)));
        return randNum % max;
    }
}