/**
 *Submitted for verification at BscScan.com on 2022-07-10
*/

/** 
    Full Name: Tran Dang Khoa
    Topic: Write a program to manage the tuition free of English class.
*/
// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.5.13;

contract IsOwner {
    address private ownerAddress;

    constructor() public {
        ownerAddress = msg.sender; 
    }
    
    // check owner
    modifier onlyOwner() {
        require(isOwner(), "Accept using ownser only!");
        _;
    }

    // not owner
    modifier notOwner() {
        require(!isOwner(), "Student can use this option only!");
        _;
    }
    
    // not is owner
    function isOwner() public view returns(bool) {
        return msg.sender == ownerAddress;
    }
}


contract tuitionFeeManagement is IsOwner {

    uint totalOfStudent;
    uint tuitionFee;
    uint studentOfEmptyList;
    uint studentHasPayFee;
    mapping(address => bool) isEmptyList;
    mapping(address => bool) hasPayFee;
    uint currentBalance = address(this).balance; 
   
    constructor(uint _totalOfStudent, uint _tuitionFee) public {
        totalOfStudent = _totalOfStudent;
        tuitionFee = _tuitionFee;
    }

    // Function 1: Participant learning english class.
    function participantLearning(address student) public onlyOwner{
        require(!(isEmptyList[student]), "Accept student has not been resistered!");
        isEmptyList[student] = true;
        ++studentOfEmptyList;
    } 

    // Function 2: Pay the tutition fee for learning.
    function payTuititionFee() public payable {
        require(!(hasPayFee[msg.sender]), "Tuition fee has been pay!");
        require(msg.value == tuitionFee, "Accept money and tuition fee is equal!");
        hasPayFee[msg.sender] = true;
        ++studentHasPayFee;
    }

    // funtion 5: crash money
    function crashMoney( uint money) public onlyOwner {
        require(!(money > currentBalance), "The amount in your wallet is not enough");
        currentBalance--;
        msg.sender.transfer(money);
    }

    // function 3: calculate some of the statistic.
    event calculteChecker( uint totalMoney, uint totalOfStudent, uint studentOfEmptyList, uint studentHasPayFee, uint tuitionFee);
    function calculateStudent() public {
        emit calculteChecker(address(this).balance, totalOfStudent, studentOfEmptyList, studentHasPayFee, tuitionFee);
    }

    // function 4: check student info.
    event inforChecker(address addressOfSender, bool hasPay, bool isRegister);
    function checkStudentInfo() public {
        emit inforChecker(msg.sender, hasPayFee[msg.sender], isEmptyList[msg.sender]);
    }
}