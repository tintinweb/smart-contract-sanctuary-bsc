//SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract structure{

    enum StudentState {Pursuing,Passed,Failed,Restricted,Promoted}

    struct Student{
        uint rollNo;
        string name;
        string class;
        StudentState currentStatus;
    }
    
    mapping(address=>Student) private _studentDetails;

    event NewStudentAdded(address indexed studentAddress_,Student indexed studentDetails_);
    
    constructor(){
          _studentDetails[msg.sender].name="Ram Pandey";
          _studentDetails[msg.sender].class="B.Tech";
          _studentDetails[msg.sender].rollNo=188330043;
          _studentDetails[msg.sender].currentStatus=StudentState.Passed; 
    }

    function getStudentDetails(address studentAddress_) external view returns(Student memory){
          return _studentDetails[studentAddress_];
    }

    function setStudentDetails(uint256 yourRollNo_,string memory yourName,string memory yourClass_,StudentState currnetState_) external returns(bool){
        
          _studentDetails[msg.sender].name=yourName;
          _studentDetails[msg.sender].class=yourClass_;
          _studentDetails[msg.sender].rollNo=yourRollNo_;
          _studentDetails[msg.sender].currentStatus=currnetState_;
          emit NewStudentAdded(msg.sender, _studentDetails[msg.sender]);
        return true;
    }

}