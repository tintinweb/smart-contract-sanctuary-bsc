/**
 *Submitted for verification at BscScan.com on 2022-10-16
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;


contract Voting{

    address public owner;

    modifier onlyOwner() {
        require(
            msg.sender == owner,
            "only owner has rights to do this"
        );
        _;
    }

    constructor(){
        owner = msg.sender;
    }

    struct Voter{
        bool voted;
        uint vote;
    }

    mapping(address => Voter)  voters;

    string askQuestion;

    function setQuestion(string memory _value) public onlyOwner{
        askQuestion = _value;
    }

    function getQuestion() public view returns (string memory)  {
        return askQuestion;
    }

    struct Options {
        string opt;   
        uint voteCount; 
    }

    //mapping(string => Options[]) option;
    Options[] public  option;

    function setOptions1(string memory _opt) public onlyOwner{
        option.push(Options(_opt, 0));
    }


    function setOptions2(string memory _opt) public onlyOwner{
        option.push(Options(_opt, 0));
    }

    bool stop;

    function startVoting() public onlyOwner{
        stop = true;
    }

    function stopVoting() public onlyOwner{
        stop = false;
    }

    function voteFor(uint index) public {
        require(stop, "voting needs to start");
        Voter storage sender = voters[msg.sender];
        require(!sender.voted, "Already voted.");
        sender.voted = true;
        option[index].voteCount++;
    }


    function winner() public view returns (string memory winnerName){
        require(stop==false, "can't see the result (voting should be ended)");
        uint largest = 0;
        uint largest1 = 0;
        for(uint i=0; i<option.length; i++){
            if(option[i].voteCount > largest){
                largest = option[i].voteCount;
                uint j = i+1;
                largest1 = option[j].voteCount;

                if(largest1 == largest)
                {
                    "Vote is Tie";
                }else
                {
                    winnerName = option[i].opt;
                }
            }
        }
        
    }

}