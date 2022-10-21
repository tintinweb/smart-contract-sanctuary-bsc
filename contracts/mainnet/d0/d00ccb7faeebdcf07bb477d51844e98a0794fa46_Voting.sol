/**
 *Submitted for verification at BscScan.com on 2022-10-21
*/

// SPDX-License-Identifier: MIT

//    //   / /                                 //   ) )
//   //____     ___      ___                  //___/ /  //  ___      ___     / ___
//  / ____    //   ) ) ((   ) ) //   / /     / __  (   // //   ) ) //   ) ) //\ \
// //        //   / /   \ \    ((___/ /     //    ) ) // //   / / //       //  \ \
////____/ / ((___( ( //   ) )      / /     //____/ / // ((___/ / ((____   //    \ \
// Developed by Dogu Deniz UGUR (https://github.com/DoguD)

pragma solidity ^0.8.0;

interface EasyBlock {
    function shareCount(address _address) external view returns (uint256);
}

contract Voting {
    mapping(address => bool) public isVoteCast;
    mapping(address => bool) public isVoteYes;
    uint256 public votingEndTime;
    uint256 public yesVotes = 0;
    uint256 public noVotes = 0;

    constructor(uint256 _votingEndTime) {
        votingEndTime = _votingEndTime;
    }

    function getTimeLeft() public view returns(uint256){
        return votingEndTime - block.timestamp;
    }

    function vote(bool _vote) public{
        require(block.timestamp <= votingEndTime, "Voting has ended");
        require(!isVoteCast[msg.sender], "You have already voted");

        isVoteCast[msg.sender] = true;
        if(_vote) {
            yesVotes += EasyBlock(0x827674a42694ce061d594C091B3278173e57feA8).shareCount(msg.sender);
            isVoteYes[msg.sender] = true;
        } else {
            noVotes += EasyBlock(0x827674a42694ce061d594C091B3278173e57feA8).shareCount(msg.sender);
        }
    }
}