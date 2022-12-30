// SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;

import "./Campaign.sol";
import "./SafeMath.sol";
import "./ICampaign.sol";



contract CampaignFactory{
    using SafeMath for uint256;
    struct projectInfo {
        string title;
        address campaignAddress;
        //string description;
        uint256 totalFund;
        uint256 milestonesNum;
        uint256 gatheredFund;
        bool buyerApproved;
        bool completed;
        uint256 investedAmount;
        bool fundingFinished;
        uint256 status;
    }
    Campaign[] private campaigns;
    address public manager;
    address[] private campaignsList;
    uint256 public pendingProjectsNum = 0; 
    mapping(address => address[]) private infoCreator;
    mapping(address => address[]) private infoBuyer;
    mapping(address => address[]) private infoInvestor;
    mapping(address => bool) private campaignAddressList;
    mapping(address => bool) private managerPendingList;


    modifier isCampaign(){
        require(campaignAddressList[msg.sender] == true, "only deployed campaigns.");
        _;
    }

    modifier isManager(){
        require(manager == msg.sender, "only manager.");
        _;
    }

    // event campaignCreated(string titleOfProject, address addressOfCampaign, 
    //         address indexed addressOfCreator, address indexed addressOfBuyer, uint256 projectTotalFund);

    constructor() {
        manager = msg.sender;
    }

    function createCampaign(address payable projectBuyer, uint256 fundingPeriod, 
                uint256 projectTotalFund, string memory projectTitle, uint256 prepaymentPercentage,
                uint256 milestones) public{
                    bytes32 _salt = keccak256(abi.encodePacked(msg.sender, projectBuyer, fundingPeriod, projectTotalFund, 
                    projectTitle, prepaymentPercentage, milestones, manager));
                    Campaign newCampaign = new Campaign{
                        salt: bytes32(_salt)
                    }(payable(msg.sender), projectBuyer, fundingPeriod,
                     projectTotalFund, projectTitle, prepaymentPercentage,
                     milestones, manager);
	                campaigns.push(newCampaign);
                    campaignsList.push(address(newCampaign));
                    campaignAddressList[address(newCampaign)] = true;
                    infoCreator[msg.sender].push(address(newCampaign));
                    infoBuyer[projectBuyer].push(address(newCampaign));
                    managerPendingList[address(newCampaign)] = true;
                    pendingProjectsNum ++;
                    // emit campaignCreated(projectTitle, address(newCampaign), msg.sender, projectBuyer, projectTotalFund);
                 }

            
    function getAddress(address projectBuyer, uint256 fundingPeriod, uint256 projectTotalFund,
    string memory projectTitle, uint256 prepaymentPercentage, uint256 milestones) public view returns (address) {
        bytes memory bytecode = abi.encodePacked(type(Campaign).creationCode, abi.encode(msg.sender, projectBuyer, fundingPeriod, 
        projectTotalFund, projectTitle, prepaymentPercentage, milestones, manager));
        bytes32 _salt = keccak256(abi.encodePacked(msg.sender, projectBuyer, fundingPeriod, projectTotalFund, 
        projectTitle, prepaymentPercentage, milestones, manager));
        bytes32 hash = keccak256(
            abi.encodePacked(
                bytes1(0xff), address(this), _salt, keccak256(bytecode)
            )
        );
        return address (uint160(uint(hash)));
    }

    function Campaigns_list() external view returns (Campaign[] memory){
        return campaigns;
    }

    function updatePendingList(address projectCampaign) external isCampaign{
        managerPendingList[projectCampaign] = false;
        pendingProjectsNum --;
    }


    function getCreatorInfo(address userAddress) internal view returns (address[] memory){
        return infoCreator[userAddress];
    }


    function getBuyerInfo(address userAddress) internal view returns (address[] memory){
        return infoBuyer[userAddress];
    }

    function getInvestorInfo(address userAddress) internal view returns(address[] memory){
        return infoInvestor[userAddress];
    }

    function addInvestorInfo(address userAddress, address campaignAddress) external isCampaign{
        infoInvestor[userAddress].push(campaignAddress);
    }

    function getPendingCampaigns(address campaignAddress) public isManager view returns(bool){
        return managerPendingList[campaignAddress];
    }

    function pendingPojectsList() public isManager view returns(address[] memory){
        //Campaign[] memory _campaigns = campaigns; 
        uint256 index = 0;
        uint256 count = campaignsList.length;
        address[] memory projectPendingList = new address[](pendingProjectsNum);
        for (uint256 i=0; i < count; i++){
            address campaignAddress = campaignsList[i];
            if (managerPendingList[campaignAddress]) {
                //projectPendingList.push(campaignAddress);
                projectPendingList[index] = campaignAddress;
                index ++;
            }
        }
        return projectPendingList;
    }



    function getCreatorCampaignData(address userAddress) external view returns(projectInfo[] memory){
        address[] memory creatorAddressList = getCreatorInfo(userAddress);
        uint256 count = creatorAddressList.length;
        projectInfo[] memory result = new projectInfo[](count);
        for (uint256 i = 0; i < count; i++) {
            address campaignAddress = creatorAddressList[i];
            projectInfo memory res = projectInfo(
                ICampaign(campaignAddress).title(),
                campaignAddress,
                ICampaign(campaignAddress).fullFund(),
                ICampaign(campaignAddress).milestoneNum(),
                ICampaign(campaignAddress).totalFund(),
                ICampaign(campaignAddress).buyerApproved(),
                ICampaign(campaignAddress).projectComplete(),
                ICampaign(campaignAddress).investorsAmount(userAddress),
                ICampaign(campaignAddress).isFundingFinished(),
                ICampaign(campaignAddress).getProjectStatus()
            );
            result[i] = res;
        }
        return result;
    }

    function getBuyerCampaignData(address userAddress) external view returns(projectInfo[] memory){
        address[] memory buyerAddressList = getBuyerInfo(userAddress);
        uint256 count = buyerAddressList.length;
        projectInfo[] memory result = new projectInfo[](count);
        for (uint256 i = 0; i < count; i++) {
            address campaignAddress = buyerAddressList[i];
            projectInfo memory res = projectInfo(
                ICampaign(campaignAddress).title(),
                campaignAddress,
                ICampaign(campaignAddress).fullFund(),
                ICampaign(campaignAddress).milestoneNum(),
                ICampaign(campaignAddress).totalFund(),
                ICampaign(campaignAddress).buyerApproved(),
                ICampaign(campaignAddress).projectComplete(),
                ICampaign(campaignAddress).investorsAmount(userAddress),
                ICampaign(campaignAddress).isFundingFinished(),
                ICampaign(campaignAddress).getProjectStatus()
            );
            result[i] = res;
        }
        return result;
    } 

    
    

    function getInvestorCampaignData(address userAddress) external view returns(projectInfo[] memory){
        address[] memory  investorAddressList = getInvestorInfo(userAddress);
        uint256 count = investorAddressList.length;
        projectInfo[] memory result = new projectInfo[](count);
        for (uint256 i = 0; i < count; i++) {
            address campaignAddress = investorAddressList[i];
            projectInfo memory res = projectInfo(
                ICampaign(campaignAddress).title(),
                campaignAddress,
                ICampaign(campaignAddress).fullFund(),
                ICampaign(campaignAddress).milestoneNum(),
                ICampaign(campaignAddress).totalFund(),
                ICampaign(campaignAddress).buyerApproved(),
                ICampaign(campaignAddress).projectComplete(),
                ICampaign(campaignAddress).investorsAmount(userAddress),
                ICampaign(campaignAddress).isFundingFinished(),
                ICampaign(campaignAddress).getProjectStatus()
            );
            result[i] = res;
        }
        return result;
    }

    function getInvestorCampaignAddress(address userAddress) public view returns(address[] memory){
        return infoInvestor[userAddress];
    }
        
}