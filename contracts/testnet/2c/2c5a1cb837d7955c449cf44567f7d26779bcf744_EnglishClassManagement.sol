/**
 *Submitted for verification at BscScan.com on 2022-07-10
*/

// SPDX-License-Identifier: GPL-3.0
//Huynh Gia Khiem

pragma solidity ^0.5.13;

contract Onwership {
    address public owner;
    constructor() public {
        owner = msg.sender;
    }
    
    modifier isOwner {
        require (msg.sender == owner, "You are not the owner!");
        _;
    }
}
contract EnglishClassManagement is Onwership{
    mapping (address => bool) isRegisted;
    uint numberOfStudentRegisted;
    mapping (address => bool) isPay;
    uint numberOfStudentPayed;
    uint totalStudents;
    uint tuitionFee;
    uint totalMoney;

    event statisticalEvent (uint totalStudents, uint numberOfStudentRegisted, uint numberOfStudentPayed, uint tuitionFee, uint totalMoney, uint balance); 
    event checkEvent (address studentAddress, bool isRegisted, bool isPayed);
    constructor(uint _totalStudent, uint _tuitionFee) public {
        totalStudents = _totalStudent;
        tuitionFee = _tuitionFee;
    }

    function registed(address _student) public isOwner {
        require (_student != owner, "Owner can't registed!");
        require (isRegisted[_student] == false, "This student have been registed!");
        isRegisted[_student] = true;
        numberOfStudentRegisted++;
    }

   
    function payFee() public payable {
        require (isRegisted[msg.sender] == true, "Student is not in the list!");
        require (msg.value == tuitionFee, "Your money must be equal to tuition fee!");
        require (isPay[msg.sender] == false, "Tuition fee have been payed! You can't payed again!");
        require (numberOfStudentPayed < totalStudents, "Class is now full slot!");
        isPay[msg.sender] = true;
        numberOfStudentPayed++;
        totalMoney += tuitionFee;
    }

    function statistical() public {
        emit statisticalEvent (totalStudents, numberOfStudentRegisted, numberOfStudentPayed, tuitionFee, totalMoney, address(this).balance);
    }

    function check() public {
        emit checkEvent (msg.sender, isRegisted[msg.sender], isPay[msg.sender]);
    }

    function withdrawMoney() public isOwner {
        msg.sender.transfer(address(this).balance);
    } 


}