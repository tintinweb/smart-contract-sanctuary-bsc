// SPDX-License-Identifier: MIT
pragma solidity >=0.6.12;


contract Counter  {

    uint256 public counter = 0;

    constructor() public {}


    function increaseCounter() external {
        counter += 1;
    }
    
}