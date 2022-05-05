/**
 *Submitted for verification at BscScan.com on 2022-05-05
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

contract SimpleContractWithFullDataTypes {

    event Setting(uint a, uint[] b, bool c, bool[] d, string e, address f, address[] g);

    uint storedUint;
    uint[] storedUintArray;
    bool storedBool;
    bool[] storedBoolArray;
    string storedString;
    address storedAddress;
    address[] storedAddressArray;

    function set(uint a, uint[] memory b, bool c, bool[] memory d, string memory e, address f, address[] memory g) public {
        storedUint = a;
        storedUintArray = b;
        storedBool = c;
        storedBoolArray = d;
        storedString = e;
        storedAddress = f;
        storedAddressArray = g;
        emit Setting(a,b,c,d,e,f,g);
    }
    function get() public view returns (uint, uint[] memory, bool, bool[] memory, string memory, address, address[] memory) {
        return (storedUint,storedUintArray,storedBool,storedBoolArray,storedString, storedAddress,storedAddressArray);
    }
}