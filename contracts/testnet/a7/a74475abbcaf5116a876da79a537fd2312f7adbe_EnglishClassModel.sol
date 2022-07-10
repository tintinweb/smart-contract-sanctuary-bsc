/**
 *Submitted for verification at BscScan.com on 2022-07-09
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.5.13;

contract Ownable {
    address private owner;
    constructor() public {
        owner = msg.sender;
    }

    function getowner() public view returns (address) {
        return owner;
    }

    modifier onlyOwner(){
        require (msg.sender == owner,"Ownalbe: Caller is not the owner");
        _;
    }
}

contract EnglishClassModel is Ownable {
    uint totalStudent;
    uint tuitionFee;
    mapping (address => bool) whitelist;
    uint numberStudentInWhiteList;
    mapping (address => bool) paiedStudent;
    uint numberStudentHasPaied;

    event analyze(uint totalStudent,uint numberStudentInWhiteList, uint numberStudentHasPaied, uint tuitionFee, uint amount);
    event check(bool isStudentInWhiteList, bool isStudentPaiedFee);

    constructor(uint _totalStudent, uint _tuitionFee) public{
        totalStudent = _totalStudent;
        tuitionFee = _tuitionFee;
    }

    function register(address _student) public onlyOwner{
        require(getowner() != _student,"Student can't be owner");
        require(!whitelist[_student], "Student has been added");
        whitelist[_student] = true;
        numberStudentInWhiteList++;
        
    }

    function payFee() public payable{
        require(whitelist[msg.sender],"Student is not in white list");
        require(!paiedStudent[msg.sender],"Tuition fee has been paied");
        require(numberStudentHasPaied < totalStudent,"Classroom has enough student");
        require(msg.value == tuitionFee,"The amount is not equal tuition fee");
        paiedStudent[msg.sender]=true;
        msg.sender.transfer(tuitionFee);
    }

    function Analyze() public {
        emit analyze(totalStudent,numberStudentInWhiteList, numberStudentHasPaied,tuitionFee,address(this).balance);
    }

    function checkStudent() public {
        emit check(whitelist[msg.sender],paiedStudent[msg.sender]);

    }

    function withdrawAllMoney() public onlyOwner{
        msg.sender.transfer(address(this).balance);
    }

}