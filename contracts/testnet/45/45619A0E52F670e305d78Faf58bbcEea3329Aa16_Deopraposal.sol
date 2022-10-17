/**
 *Submitted for verification at BscScan.com on 2022-10-17
*/

/**
 *Submitted for verification at BscScan.com on 2022-10-15
*/

// SPDX-License-Identifier: GPL-3.0
   pragma solidity ^0.8.17;

   contract Deopraposal{
    address public owner;
   uint256 public IdProvider =2000;
    uint256 public fessPer=5000;  
     uint256 public UserIdProvider;
        struct ProjectData{

                        uint256 proposalId;
                        string  userProposalTitle;
                        string  userProposalContent;
                        string  proposalLink;
                        address propsalOwnerAddress;
                        
                        }

          struct IdeasInfo{
                    ProjectData[] IdeasInfo;
                 }
                  struct UserDetail{

                        uint256  userId;
                        ProjectData[] projectdata;
                    }

          modifier onlyOwner {
       require(msg.sender == owner , "Only Owner Can Perform This Action");
       _;
       }
     

      ProjectData [] AllRecords;

      mapping(uint256 => ProjectData) private IdeaDetail;
     mapping(address => UserDetail) public UserRecord;
     mapping(uint256 => IdeasInfo) private IdeasIdInfo;
      event propsalData(string  titleUser , string  projectinfo, string  projectlink ,uint256 ProPosaLIDUser);


       constructor(address ownerAddress){
         owner = ownerAddress;
    }

     function setProjectIdeas(string memory usertitle, string memory userprojectinfo, string memory user_link ) public payable {
    require(msg.value >= fessPer/100, "Fees Transfer Issues Please check Issue");

        if(UserRecord[msg.sender].userId ==0){
                      UserIdProvider++;
                     UserRecord[msg.sender].userId =UserIdProvider;
                                    }
        
           IdeaDetail[ UserRecord[msg.sender].userId].proposalId= IdProvider;
         IdeaDetail[ UserRecord[msg.sender].userId].userProposalTitle= usertitle;
         IdeaDetail[ UserRecord[msg.sender].userId].userProposalContent= userprojectinfo;
         IdeaDetail[ UserRecord[msg.sender].userId].proposalLink = user_link;
         UserRecord[msg.sender].projectdata.push(IdeaDetail[UserRecord[msg.sender].userId]);
        IdeasIdInfo[IdProvider].IdeasInfo.push(IdeaDetail[UserRecord[msg.sender].userId]); 
        AllRecords.push(IdeaDetail[UserRecord[msg.sender].userId]);

                        emit propsalData(usertitle,userprojectinfo,user_link,IdProvider);
                        
                        IdProvider++;
               }
      
      function getUserData(address user2) public view  returns (UserDetail memory){
                        return  UserRecord[user2];
                        }
                        

       function AllData()public view returns( ProjectData [] memory){
                        return AllRecords;
                        
                        }
                         
        function setdevPer(uint256 _feesPer) public {
        require(msg.sender == owner, "only owner can change this fess");
       fessPer=_feesPer;
    }

   }