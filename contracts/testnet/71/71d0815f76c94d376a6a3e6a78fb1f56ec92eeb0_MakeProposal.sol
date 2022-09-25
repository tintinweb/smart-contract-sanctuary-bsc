/**
 *Submitted for verification at BscScan.com on 2022-09-24
*/

// SPDX-License-Identifier: GPL-3.0

    pragma solidity ^0.8.0;

    contract MakeProposal{
        
    uint256 public IdProvider =4000;
    uint256 public UserIdProvider;


    struct ProposalData{

    uint256 proposalId;
    string  userProposalTitle;
    string  userProposalContent;
    string [] choice;
    string userProposalStartTimestamp;
    string userProposalEndTimestamp;
    // string userProposalEndTime;  
 
    }

struct UserDetail{

    uint256  userId;
    ProposalData[] Proposaldata;
}

    mapping( address => UserDetail) public UserRecord;
    mapping( uint256 => ProposalData) private ProposalDetail;
    // mapping( uint256 => ProposalData) private ProposalInfo;


    // function setData(ProposalData calldata user) public {
            
    //         if( UserRecord[msg.sender].userId ==0){
    //             UserIdProvider++;
    //         UserRecord[msg.sender].userId =UserIdProvider;
    //         }

            
    //         // ProposalDetail[UserRecord[msg.sender].userId].proposalId = IdProvider;
    //         ProposalDetail[UserRecord[msg.sender].userId]=user;
    //         UserRecord[msg.sender].Proposaldata.push(ProposalDetail[UserRecord[msg.sender].userId]);
    //         IdProvider++;
    //         }

        

function setData(string calldata title , string calldata content, string calldata _choice , string calldata start, string calldata end ) public {
    

            if(UserRecord[msg.sender].userId ==0){
                UserIdProvider++;
                  UserRecord[msg.sender].userId =UserIdProvider;
            }
   

   
    ProposalDetail[ UserRecord[msg.sender].userId].proposalId= IdProvider;
    ProposalDetail[ UserRecord[msg.sender].userId].userProposalTitle= title;
    ProposalDetail[ UserRecord[msg.sender].userId].userProposalContent= content;
    ProposalDetail[ UserRecord[msg.sender].userId].choice.push(_choice);
    ProposalDetail[ UserRecord[msg.sender].userId].userProposalStartTimestamp= start;
    ProposalDetail[ UserRecord[msg.sender].userId].userProposalEndTimestamp= end;
    UserRecord[msg.sender].Proposaldata.push(ProposalDetail[UserRecord[msg.sender].userId]);
    
    IdProvider++;

}   


    // function getData(address user) public view  returns (ProposalData memory){
    // return ProposalDetail[UserRecord[user].userId];
    // }
    

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