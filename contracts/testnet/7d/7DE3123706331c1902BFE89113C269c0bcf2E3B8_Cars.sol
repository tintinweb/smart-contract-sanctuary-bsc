// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract Cars {

    constructor()  
    {

    }

    function getResult() public pure returns(uint) {
        uint result = 1 + 2;
        return result;
    }
}