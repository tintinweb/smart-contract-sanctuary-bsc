/**
 *Submitted for verification at BscScan.com on 2022-02-15
*/

//SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.7.0 <0.9.0;

contract Lottery {
    uint nonce = 0;
    address[] candidateArray;
    uint[] ticketNumArray;
    address chairperson;
    event winnerInfo(address winnerAddr, uint winnerTicketNum);

    constructor() {
        chairperson = msg.sender;
    }

    function setCandidate(address[] memory _candidates, uint[] memory _ticketNums) public {
        require(chairperson == msg.sender, "Only chairperson can set candidate!");

        candidateArray = _candidates;
        ticketNumArray = _ticketNums;
    }

    function winnerCandidate() public {
        require(chairperson == msg.sender, "Only chairperson can vote candidate!");
        require(candidateArray.length > 0, "At least one candidate!");
        if (candidateArray.length == 1) {
            emit winnerInfo(candidateArray[0], ticketNumArray[0]);
        }

        else {
            uint index = winnerIndex();
            emit winnerInfo(candidateArray[index], ticketNumArray[index]);
        }

        delete candidateArray;
        delete ticketNumArray;
    }

    function winnerIndex() private returns (uint){
        uint winner = uint(keccak256(abi.encodePacked(block.timestamp, msg.sender, nonce))) % candidateArray.length;
        nonce++;
        return winner;
    }
}