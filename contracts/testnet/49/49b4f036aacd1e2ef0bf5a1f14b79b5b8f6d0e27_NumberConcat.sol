/**
 *Submitted for verification at BscScan.com on 2022-04-29
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library Strings {

    function concat(string memory _base, string memory _value) internal returns (string memory) {
        bytes memory _baseBytes = bytes(_base);
        bytes memory _valueBytes = bytes(_value);

        string memory _tmpValue = new string(_baseBytes.length + _valueBytes.length);
        bytes memory _newValue = bytes(_tmpValue);

        uint i;
        uint j;

        for(i=0; i<_baseBytes.length; i++) {
            _newValue[j++] = _baseBytes[i];
        }

        for(i=0; i<_valueBytes.length; i++) {
            _newValue[j++] = _valueBytes[i];
        }

        return string(_newValue);
    }

}

contract NumberConcat {
    using Strings for string;
    struct data {
        string num;
    }
    mapping(uint256=>data) public getDataByNumber;
    function appendStrings(uint256 num, string memory str) public returns(string memory) {
        return getDataByNumber[num].num.concat(str).concat(",");
    }
    function addData(uint256 num, string memory str) public {
        getDataByNumber[num]=data(appendStrings(num,str));
    }
}