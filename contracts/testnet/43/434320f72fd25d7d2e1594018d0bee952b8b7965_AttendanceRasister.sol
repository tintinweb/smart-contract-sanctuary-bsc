/**
 *Submitted for verification at BscScan.com on 2022-05-15
*/

//SPDX-License-Identifier:MIT
pragma solidity^0.8.0;
contract AttendanceRasister{
    struct student{
        string name;
        uint class;
        uint time;
    } 
    address TEACHER;
    uint  roll =1;
     mapping(uint=>student) public STUDENTS;
     event success(uint ROLL,   uint TIME);
    constructor(){
        TEACHER= msg.sender;
    }
    modifier onlyTeacher{
        require( msg.sender==TEACHER ,"You are not a teacher");
        _;
    }
    function addstudent(string memory _name,uint _class)public onlyTeacher{
       // t= block.timestamp ;
     STUDENTS[roll]=student( _name,_class,(block.timestamp)); 
     emit success(roll,block.timestamp); 
        roll++;  }  
}