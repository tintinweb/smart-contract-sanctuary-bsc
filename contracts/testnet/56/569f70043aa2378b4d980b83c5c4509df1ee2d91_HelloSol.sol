/**
 *Submitted for verification at BscScan.com on 2022-07-08
*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

contract HelloSol {
    string savedString;
    uint savedValue;

    function setString( string memory newString ) public {
        savedString = newString;
    }
    function getString() public view returns( string memory ) {
        return savedString;
    }
    function setValue( uint newValue ) public {
        savedValue = newValue;
    }
    function getValue() public view returns( uint ) {
        return savedValue;
    }
}