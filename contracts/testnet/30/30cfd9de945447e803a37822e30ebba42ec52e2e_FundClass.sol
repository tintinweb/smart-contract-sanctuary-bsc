/**
 *Submitted for verification at BscScan.com on 2022-06-12
*/

//SPDX-License-Identifier: MIT
pragma solidity^0.8.4;
contract FundClass{

    address public owner;
    Student[] public arrayStudents;
    struct Student {
        address Account;
        uint Amount;
        string Content;
    }

    constructor () {
        owner = msg.sender;
    }
    modifier checkOwner () {
        require(msg.sender==owner,"You are not owner");
        _;
    }
    function withdraw () public checkOwner() {
        payable(owner).transfer(address(this).balance);
    }
    function sendDonate (string memory content) public payable {
        require(msg.value>=10*15, "Minimum is 0.001 BNB");
        arrayStudents.push(Student(msg.sender, msg.value, content));
    }
    function studentCounter () public view returns (uint) {
        return arrayStudents.length;
    }
    function get_1_student (uint ordering) public view returns (address, uint, string memory) {
        require (ordering < arrayStudents.length);
        return (arrayStudents[ordering].Account, arrayStudents[ordering].Amount, arrayStudents[ordering].Content);
    }
    function getBalance () public view returns (uint) {
        return address(this).balance;
    }
}