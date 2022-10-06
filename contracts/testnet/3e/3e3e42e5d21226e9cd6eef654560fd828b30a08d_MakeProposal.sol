/**
 *Submitted for verification at BscScan.com on 2022-10-06
*/

/**
 *Submitted for verification at BscScan.com on 2022-10-01
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
                        string  choice;
                        string userProposalStartTimestamp;
                        string userProposalEndTimestamp;
                        address propsalOwnerAddress;
                        
                        }
                               struct VotersData{

                        uint256 proposalID;
                        string [][] totalLikedAddress;
                        mapping(uint256  => mapping(address => bool))  VoteValidator;
                    } 

                    VotersData  voterData;

                

                    struct UserDetail{

                        uint256  userId;
                        ProposalData[] Proposaldata;
                    }

                    struct ProposalInfo{
                        ProposalData[] ProposalInfo;
                    }


                        ProposalData [] AllRecords;

                        address [] mods= [0x3CB65D740f3993eD5DDe64CdFFE008e4D04E6Db3,0x65D877D5F099fEe112Cb2EE0aAADBBb3Cbdc5381];

                        mapping(uint256 => ProposalInfo) private PropsalIdInfo;
                        mapping(address => UserDetail) public UserRecord;
                        mapping(uint256 => ProposalData) private ProposalDetail;


                    mapping(uint256 => mapping(address => string)) public votingOptionDetail; 
                    mapping(uint256 => mapping(string => uint256)) public TotalNumberOfVote;
                    mapping(uint256 => VotersData ) public  fetchProposalVoterDetail;



                    function setData(string calldata title , string calldata content, string calldata _choice , string calldata start, string calldata end ) public {
                        

                                    if(UserRecord[msg.sender].userId ==0){
                                        UserIdProvider++;
                                        UserRecord[msg.sender].userId =UserIdProvider;
                                    }
                    

                    
                        ProposalDetail[ UserRecord[msg.sender].userId].proposalId= IdProvider;
                        ProposalDetail[ UserRecord[msg.sender].userId].userProposalTitle= title;
                        ProposalDetail[ UserRecord[msg.sender].userId].userProposalContent= content;
                        ProposalDetail[ UserRecord[msg.sender].userId].choice = _choice;
                        ProposalDetail[ UserRecord[msg.sender].userId].userProposalStartTimestamp= start;
                        ProposalDetail[ UserRecord[msg.sender].userId].userProposalEndTimestamp= end;
                        ProposalDetail[ UserRecord[msg.sender].userId].propsalOwnerAddress= msg.sender;
                        UserRecord[msg.sender].Proposaldata.push(ProposalDetail[UserRecord[msg.sender].userId]);

                        PropsalIdInfo[IdProvider].ProposalInfo.push(ProposalDetail[UserRecord[msg.sender].userId]); 
                        AllRecords.push(ProposalDetail[UserRecord[msg.sender].userId]);
                        
                        IdProvider++;

                    }   
                        function getDataByPropsalId(uint256 _ProposalID) public view  returns (ProposalInfo memory){
                        return PropsalIdInfo[_ProposalID];
                        }
                        

                        function getUserData(address user2) public view  returns (UserDetail memory){
                        return  UserRecord[user2];
                        }
                        

                        function GiveProposalID()public view returns(uint256){
                        return IdProvider;
                        
                        }


                        function AllData()public view returns( ProposalData [] memory){
                        return AllRecords;
                        
                        }
                        function modsAddress() public view  returns(  address   [] memory){

                                    return mods;
                        } 
                        


                    // voting code

                    // function Vote ()

             

                    function vote( uint256 _propsalID,string calldata _likerAddress , string calldata _option )public {

                    
                        require(voterData.VoteValidator[_propsalID][msg.sender]== false,"You Have Alreay Voted");

                        fetchProposalVoterDetail[_propsalID].proposalID = _propsalID;
                        fetchProposalVoterDetail[_propsalID].totalLikedAddress.push([_likerAddress,_option]);
                        votingOptionDetail[_propsalID][msg.sender]=_option;
                        
                        TotalNumberOfVote[_propsalID][_option]++;
                        voterData.VoteValidator[_propsalID][msg.sender]=true;
                        



                    }

                    function GetVotingDetails (uint256 _ProID) public view returns( string [][] memory  ){
                        return fetchProposalVoterDetail[_ProID].totalLikedAddress;
                    }


                    receive() external payable {  
                    }

                        }