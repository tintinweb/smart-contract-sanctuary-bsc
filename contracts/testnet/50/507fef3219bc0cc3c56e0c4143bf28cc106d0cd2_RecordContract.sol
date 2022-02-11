/**
 *Submitted for verification at BscScan.com on 2022-01-31
*/

// SPDX-License-Identifier: MIT 2
pragma solidity ^0.8.0;

contract RecordContract {
    
    uint public totalRecord;

    struct Record {
        string name;
        string number;
        string time;
        string types;
        string location;
        string company;
        uint recordID;
        bool enable;
    }

    Record[] public records;

    function addRecord(
        string memory _name,
        string memory _number,
        string memory _time,
        string memory _types,
        string memory _location,
        string memory _company
        ) public {

        Record memory record;
        record.name = _name;
        record.number = _number;
        record.time = _time;
        record.types = _types;
        record.location = _location;
        record.company = _company;
        record.recordID = totalRecord;
        record.enable = true;

        records.push(record);
        totalRecord++;

    }

    function delRecord(uint _id) public {
        records[_id].enable = false;
    }

    function getRecordAmount() public view returns(uint) {
        uint result = 0;
        for (uint i=0; i < totalRecord; i++) {
            if(records[i].enable) {
                result++;
            }
        }
        return result;
    }

    function getRecord() public view returns(Record[] memory) {
        Record[] memory _records = new Record[](getRecordAmount());
        uint index = 0;
        for (uint i=0; i < totalRecord; i++) {
            if(records[i].enable) {
                _records[index] = records[i];
                index++;
            }
        }
        return _records;
    }


}