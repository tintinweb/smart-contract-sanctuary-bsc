//SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract RollNoBook{

    mapping(address=>uint) private rollNumber;

    constructor(){
        rollNumber[msg.sender]=1;
    }

    function setRollNo(uint userRollNo) external returns(bool)
    {
        require(userRollNo!=0,"Error : are bhai rollno to sahi se dalo");
        require(rollNumber[msg.sender]==0,"Error :ram hack karna band karo");
        rollNumber[msg.sender]=userRollNo;
        return true;
    }
    function getRollNo(address userAddress) external view returns(uint){
        return rollNumber[userAddress];
        
    }
}