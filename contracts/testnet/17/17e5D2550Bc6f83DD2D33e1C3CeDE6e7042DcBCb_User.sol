/**
 *Submitted for verification at BscScan.com on 2022-08-01
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.15;

contract User {
    struct UserStruct {
        address addr;
        uint phone;
        bool isValid;
    }

    uint userId;
    mapping(uint => UserStruct) records;

    constructor() {
        userId = 0;
    }

    function saveRecord(address _userAddress, uint _phone, bool _isValid) public {
        records[userId++] = UserStruct(_userAddress, _phone, _isValid);
    }

    function getRecord(uint Id) public view returns (address, uint, bool){
        return (records[Id].addr, records[Id].phone, records[Id].isValid);
    }

    function deleteRecord(uint Id)public {
        delete records[Id];
    }

    function updateRecord(uint Id, address _userAddress, uint _phone, bool _isValid) public {
        records[Id].addr = _userAddress;
        records[Id].phone = _phone;
        records[Id].isValid = _isValid;
    }
}