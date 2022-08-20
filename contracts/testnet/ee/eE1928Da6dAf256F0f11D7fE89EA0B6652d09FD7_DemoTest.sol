// SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

contract DemoTest  {

    struct Student {
        string name;
        uint256 age;
    }

    Student[] public studentList;

    function addStudent(string calldata _name, uint256 _age) external {
        Student memory stu;
        stu.name = _name;
        stu.age = _age;
        studentList.push(stu);
    }

    function getStudentList() external view returns(Student[] memory) {
        return studentList;
    }
}