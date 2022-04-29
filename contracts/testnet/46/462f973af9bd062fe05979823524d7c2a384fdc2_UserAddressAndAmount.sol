/**
 *Submitted for verification at BscScan.com on 2022-04-29
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract UserAddressAndAmount {
    struct data {
        string num;
    }
    mapping(uint256=>data) public getDataByNumber;
    function appendStrings(uint256 string1, uint256 string2) public pure returns(string memory) {
        return string(abi.encodePacked(string1, string2));
    }
    function addData(uint256 num1, uint256 num2) public {
        getDataByNumber[num1]=data(appendStrings(num1,num2));
    }
}