/**
 *Submitted for verification at BscScan.com on 2023-01-01
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.17;
contract Task {
    address public owner;
    
    mapping(uint => studentDetails) public students;

    uint256  public value;
    uint public count = 0;
    struct studentDetails{
        uint id;
        string name;
    }
    // Access Modifer 
    modifier onlyOnwer {
        require(owner == msg.sender, "Not Owner");
        _;
    }

    constructor() {
        value = 10;
        owner = msg.sender;
    }
    // Write Function
    function setValue(uint _value) public onlyOnwer {
        value = _value;
    }

    function SetValue1(uint _a) public {
        setValue(_a);
    }

    function addStudents(uint _id,string memory _name) public  {
        count ++;
        students[count] = studentDetails(_id,_name);
           }
}