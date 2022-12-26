/**
 *Submitted for verification at BscScan.com on 2022-12-26
*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.16;

contract sample{

    uint public count;
    error revertAtTheMovement();

    constructor() {}

    function revertThefunc(address _add) external  {

        if (_add != address(0x0)) revert revertAtTheMovement();
        count++;
    }

}