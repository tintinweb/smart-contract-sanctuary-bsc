/**
 *Submitted for verification at BscScan.com on 2022-07-08
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.5.13;

contract Ownerable {
    address private owner;

    constructor() public {
        owner = msg.sender;
    }

    function getOwner() public view returns (address) {
        return owner;
    }

    modifier onlyOwner() {
        require(msg.sender == getOwner(), "Ownable: caller is not the owner");
        _;
    }
}


contract EnglishClassManagement is Ownerable {

    mapping(address => bool) whiteList;
    mapping(address => bool) hadPayFee;
    uint totalStudent;
    uint tuitionFee;
    uint numberStudentInWhitelist;
    uint numberStudentPayFee;
    event checkProcess(uint totalStudent, uint numberStudentInWhitelist, uint numberStudentPayFee, uint tuitionFee, uint totalMoney);
    event checkInfo(address thisAddress, bool hasRegister, bool hasPay);

    constructor(uint _totalStudent, uint _tuitionFee) public {
        totalStudent = _totalStudent;
        tuitionFee = _tuitionFee;
    }

    function register(address student) public onlyOwner{
        
        require(!whiteList[student], "Student has already register!");
        whiteList[student] = true;
        numberStudentInWhitelist++;
    } 

    function payFee() public payable {
        require(whiteList[msg.sender], "You are not in whitelist");
        require(msg.value == tuitionFee, "Your money must be equal to tuition fee!");
        require(numberStudentPayFee < totalStudent, "Class has enough student");
        require(!hadPayFee[msg.sender], "You have been pay tuition fee");
        hadPayFee[msg.sender] = true;
        numberStudentPayFee++;
    }

    function analyze() public {
        emit checkProcess(totalStudent, numberStudentInWhitelist, numberStudentPayFee, tuitionFee, address(this).balance);
    }

    function checkInfomation() public {
        require(msg.sender != getOwner(), "Owner can access this class");
        emit checkInfo(msg.sender, whiteList[msg.sender], hadPayFee[msg.sender]);
    }

    function withdrawMoney(uint amount) public onlyOwner {
        require(amount <= address(this).balance, "Contract can enough money to withdraw");
        msg.sender.transfer(amount);
    }
}