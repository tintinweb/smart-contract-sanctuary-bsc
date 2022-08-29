/**
 *Submitted for verification at BscScan.com on 2022-08-29
*/

/**
 *Submitted for verification at BscScan.com on 2021-06-23
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract Voting{
    mapping(bytes32 => uint8) public votesReceived;//候选人以及对应的票数
    // bytes32[] public candidateList;//候选人的集合
    bytes32[] public candidateList = [bytes32("0x6469646f31"), "0x6469646f32", "0x6469646f33", "0x6469646f34", "0x6469646f35", "0x6469646f36"];
    address[] public votersList;

    // constructor(bytes32[] memory candidateNames){
    //     candidateList = candidateNames;
    // }

    //
    function totalVotesFor(bytes32 candidate)public view returns(uint8){
        require(validCandidate(candidate));
        return votesReceived[candidate];
    }

    //开始投票
    function voteForCandidate(bytes32 candidate)public{
        require(validCandidate(candidate));
        votesReceived[candidate] += 1;
        votersList.push(msg.sender);
    }

    //判断是否在选民列表中
    function validCandidate(bytes32 candidate)public view returns(bool){
        for(uint i = 0; i < candidateList.length; i++){
            if(candidateList[i] == candidate){
                return true;
            }
        }
        return false;
    }
}