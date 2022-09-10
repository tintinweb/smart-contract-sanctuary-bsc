/**
 *Submitted for verification at BscScan.com on 2022-09-09
*/

/**
 *Submitted for verification at BscScan.com on 2022-09-01
*/

// SPDX-License-Identifier: none
pragma solidity ^0.8.9;

contract TestContracts{
    uint public x;

    function setX(uint _x) external{
        x = _x;
    }

    function getX() public view returns(uint){
        return x;
    }
}