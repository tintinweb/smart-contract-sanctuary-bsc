//SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
contract RollNumberBook{
    mapping (address=>uint) rollnumber;
    constructor(){
        rollnumber[msg.sender]=1;
    }
    function setRollNo(uint userRollno) external returns(bool)
    {
        require(userRollno!=0,"Error: sahi rollno dalo");
        require(rollnumber[msg.sender]==0," Error : not valid");
        rollnumber[msg.sender]=userRollno;
        return true;
    }

function getRollNo(address userAddress) external view returns(uint)
{
    return rollnumber[userAddress];
}
}