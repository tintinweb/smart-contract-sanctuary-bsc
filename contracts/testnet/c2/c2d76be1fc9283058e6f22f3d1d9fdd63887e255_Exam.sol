/**
 *Submitted for verification at BscScan.com on 2022-12-26
*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

// Uncomment this line to use console.log
// import "hardhat/console.sol";

contract Exam {

    address public owner;
    uint256 public passPercent;

    mapping (uint256 => uint256) qAns;
    uint256 public totalQulifiedUser;
    uint256 public totalQuestions;

    struct User{
        uint256 obtainMarks;
        uint256 lastAttain;
        uint256 totalMarks;
        string  status;
        uint256 percentage;
        uint256 attempts;
    }
    mapping(address => User) public user;

    constructor () {
        owner = msg.sender;
    }
    // OnlyOwner Modifier
    modifier onlyOwner {
        require(msg.sender == owner,"ONLY_OWNER_ALLOWED");
        _;
        
    }
// Set Question and Thier Choice
function setQuestion(uint256[] memory questions, uint256[] memory corr_choices) public onlyOwner{
    require(questions.length == corr_choices.length,"NOT_EQUAL_Q_A");
    for(uint256 i=0;i< questions.length; i++){
      qAns[questions[i]] = corr_choices[i];
    }
    totalQuestions = questions.length;
}
// Submit Answer By USER
function subAnswer(uint256[] memory setQuest , uint256[] memory answer) public {
   require(setQuest.length == answer.length,"NOT_EQUAL_Q_A");
   uint256 obtainMarks;
   for(uint256 i=0;i< setQuest.length; i++){
    if(qAns[setQuest[i]] == answer[i]){
        obtainMarks++;
    }
   }
   uint256 percent = (obtainMarks * 100)/totalQuestions;
   user[msg.sender].totalMarks = totalQuestions;
   user[msg.sender].obtainMarks = obtainMarks;
   user[msg.sender].percentage = percent;
   user[msg.sender].attempts += 1;
   user[msg.sender].lastAttain = block.timestamp;
   if(percent>passPercent){
      user[msg.sender].status ="pass";
      totalQulifiedUser +=1;
   }else {
    user[msg.sender].status = "fail";
   }
}
// Set Qualifying Marks by Qualifying Marks
function qualifyingPercent(uint256 _qPercent) public onlyOwner {
    require(_qPercent>0,"Should_be_valid");
     passPercent = _qPercent;
}
function isQualified(address _student) public view returns(bool){
    return user[_student].percentage >= passPercent;   
}
function lastAttempt(address _student) public view returns(uint256){
    return user[_student].lastAttain;
}
function noOfAttempts(address _student) public view returns(uint256){
    return user[_student].attempts;
}

}