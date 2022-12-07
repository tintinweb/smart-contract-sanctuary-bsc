/**
 *Submitted for verification at BscScan.com on 2022-12-06
*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.5.0;

// Uncomment this line to use console.log
// import "hardhat/console.sol";

contract Exam {

    address public owner;
    uint256 public passMarks;

    mapping (uint256 => uint256) qAns;
    uint256 public totalQulifiedUser;
    uint256 public totalQuestions;
    struct User{
        uint256 obtainMarks;
        uint256 lastAttain;
        uint256 totalMarks;
        string  status;
        uint256 percentage;
    }
    mapping(address => User) user;

    constructor () public{
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
   if(percent>passMarks){
      user[msg.sender].status ="pass";
      totalQulifiedUser +=1;
   }else {
    user[msg.sender].status = "fail";
   }
}
// Set Qualifying Marks by Qualifying Marks
function qualifyingMarks(uint256 _qMarks) public onlyOwner {
    require(_qMarks>0,"Should_be_valid");
     passMarks = _qMarks;
}
function isQualified(address _student) public view returns(bool){
    return user[_student].percentage >= passMarks;   
}

}