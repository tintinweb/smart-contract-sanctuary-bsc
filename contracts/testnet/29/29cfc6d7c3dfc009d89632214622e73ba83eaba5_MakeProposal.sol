/**
 *Submitted for verification at BscScan.com on 2022-09-24
*/

// SPDX-License-Identifier: GPL-3.0

    pragma solidity ^0.8.0;

    contract MakeProposal{
        
    uint256 public IdProvider;
    uint256 public UserIdProvider;


    struct ProposalData{

    uint256 proposalId;
    string  userProposalTitle;
    string  userProposalContent;
    string userProposalStartDate;
    string userProposalStartTime;
    string userProposalEndDate;
    string userProposalEndTime;  
 
    }

struct UserDetail{

    uint256  userId;
    ProposalData[] Proposaldata;
}

    mapping( address => UserDetail) public UserRecord;
    mapping( uint256 => ProposalData) private ProposalDetail;

    function setData(ProposalData calldata user) private {
            
            if( UserRecord[msg.sender].userId ==0){
                UserIdProvider++;
            UserRecord[msg.sender].userId =UserIdProvider;
            }

            
            // ProposalDetail[UserRecord[msg.sender].userId].proposalId = IdProvider;
            ProposalDetail[UserRecord[msg.sender].userId]=user;
            UserRecord[msg.sender].Proposaldata.push(ProposalDetail[UserRecord[msg.sender].userId]);
            IdProvider++;
            }

        

    function getData(address user) public view  returns (ProposalData memory){
    return ProposalDetail[UserRecord[user].userId];
    }
    

    function getUserData(address user2) public view  returns (UserDetail memory){
    return  UserRecord[user2];
    }
    
    
    


    // function multichoiceProposal( string calldata Choice) public   {
     // ProposalDetail[msg.sender].userProposalMultiChoice.push(Choice);
    // }

    function GiveProposalID()public view returns(uint256){
     return IdProvider;
     
    }
      



  receive() external payable {  
 }

    }