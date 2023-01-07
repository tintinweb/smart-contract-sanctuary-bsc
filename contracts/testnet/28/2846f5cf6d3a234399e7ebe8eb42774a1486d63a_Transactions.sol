/**
 *Submitted for verification at BscScan.com on 2023-01-06
*/

//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
contract Transactions {
    uint256 TransactionsCount;
    uint firstNo;
    uint secondNo;
    uint thirdNo;

    // Defining the function
    // to set the value of the
    // first variable
    function firstNoSet(uint x) public {
        firstNo = x;
    }

    // Defining the function
    // to set the value of the
    // second variable
    function secondNoSet(uint y) public {
        secondNo = y;
    }

    
function thirdNoSet(uint x) public {
        thirdNo = x;
    }
    // Defining the function
    // to add the two variables
    function add() public view returns (uint) {
        uint Sum = firstNo + secondNo+thirdNo;

        // Sum of two variables
        return Sum;
    }
}