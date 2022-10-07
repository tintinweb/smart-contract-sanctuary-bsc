/**
 *Submitted for verification at BscScan.com on 2022-10-06
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract Add3 {
    uint ourNumber;
    
    function initialize() public {
        ourNumber = 0x64;
    }

    function getNumber() public view returns (uint) {
        return ourNumber;
    }

    function addThree() public {
        ourNumber = ourNumber + 3;
    }

}