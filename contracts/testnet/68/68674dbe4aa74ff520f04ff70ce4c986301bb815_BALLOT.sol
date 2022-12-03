/**
 *Submitted for verification at BscScan.com on 2022-12-03
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.17;

contract BALLOT{
    //选民
    struct Voter{
        uint weight; //权重
        bool voted; //是否已经投票
        address delegate; //被委托人
        uint vote; //投票提案的索引
    }

    //提案的类型（选项？）
    struct Proposal{
        bytes32 name;
        uint voteCount; //得票
    }

    //主席
    address public chairperson;

    //这声明了一个状态变量，为每个可能的地址存储一个 `Voter`
    mapping (address => Voter) voters;

    // 一个 `Proposal` 结构类型的动态数组
    Proposal[] public proposals;

    constructor(bytes32[] memory proposalNames){
        chairperson = msg.sender;
        voters[chairperson].weight = 1;
        for(uint i = 0; i < proposalNames.length;i++){
            proposals.push(Proposal({
                name: proposalNames[i],
                voteCount: 0
            }));
        }
    }

    //授权 `voter` 对这个（投票）表决进行投票
    function giveRightToVote(address voter) external {
        require(chairperson == msg.sender, "Only chairperson can give right to vote.");
        require(!voters[voter].voted, "The voter already voted.");
        require(voters[voter].weight == 0);
        voters[voter].weight = 1;
    }

    //把你的投票委托到投票者 `to`。
    function delegate(address to) external {
        Voter storage sender = voters[msg.sender];
        require(!sender.voted, "You already voted.");
        require(sender.weight != 0, "You have no right to vote");
        require(to != msg.sender, "Self-delegation is disallowed.");

        //委托传递
        while(voters[to].delegate != address(0)){
            to = voters[to].delegate;
            require(to != msg.sender, "Found loop in delegation.");
        }

        Voter storage delegate_ = voters[to];
        require(delegate_.weight >= 1, "Voters cannot delegate to accounts that cannot vote.");
        sender.voted = true;
        sender.delegate = to;
        if(delegate_.voted){
            proposals[delegate_.vote].voteCount += sender.weight;
        }else{
            delegate_.weight += sender.weight;
        }
    }

    //投票
    function vote(uint proposal) external{
        Voter storage sender = voters[msg.sender];
        require(!sender.voted,"Already voted.");
        sender.voted = true;
        sender.vote = proposal;
        proposals[proposal].voteCount += sender.weight;
    }

    //结合之前所有的投票，计算出最终胜出的提案
    function winningProposal() internal view returns(uint winningProposal_){
        uint winningVoteCount = 0;
        for(uint p = 0; p < proposals.length; p++){
            if(proposals[p].voteCount > winningVoteCount){
                winningVoteCount = proposals[p].voteCount;
                winningProposal_ = p;
            }
        }
    }

    //调用 winningProposal() 函数以获取提案数组中获胜者的索引，并以此返回获胜者的名称
    function winnerName() public view returns(bytes32 winnerName_){
        winnerName_ = proposals[winningProposal()].name;
    }
}