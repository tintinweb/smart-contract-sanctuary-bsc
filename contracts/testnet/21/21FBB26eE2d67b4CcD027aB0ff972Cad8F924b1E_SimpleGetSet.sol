/**
 *Submitted for verification at BscScan.com on 2023-01-05
*/

pragma solidity ^0.8.7;

contract SimpleGetSet {
    uint storeAge;

    // set age
    function Set(uint age) public {
        storeAge = age;
    }

    // get age
    function Get() public view returns (uint) {
        return storeAge;
    }

}