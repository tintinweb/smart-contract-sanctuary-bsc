/**
 *Submitted for verification at BscScan.com on 2022-09-17
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract StudentPhenikaa {

    struct Student {
        string Name;
        uint256 Age;
        bool Sex;
        string Address;
    }

    Student[] students;

    function addStudent(
        string calldata _name, // calldata, memory, storage
        uint256 _age,
        bool _sex,
        string calldata _adddress) external 
    {
        Student memory newStudent = Student({
            Name: _name,
            Age: _age,
            Sex: _sex,
            Address: _adddress
        });
        students.push(newStudent);
    }

    function getStudents() 
        external
        view
        returns (Student[] memory _students) 
    {
        _students = students;
    }

}