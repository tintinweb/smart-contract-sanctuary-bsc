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
        string description;
        string fileName;
        uint256 totalFund;
        uint256 milestonesNum;
        uint256 gatheredFund;
        bool buyerApproved;
        bool completed;
        uint256 investedAmount;
        uint256 status;
        uint256 investorsNum;
    }
    //Campaign[] private campaigns;
    address public manager;
    address[] public campaignsList;
    uint256 public pendingProjectsNum = 0; 
    mapping(address => address[]) private infoCreator;
    mapping(address => address[]) private infoBuyer;
    mapping(address => address[]) private infoInvestor;
    mapping(address => bool) private campaignAddressList;
    mapping(address => bool) private managerPendingList;


    // modifier isCampaign(){
    //     require(campaignAddressList[msg.sender] == true, "only deployed campaigns.");
    //     _;
    // }

    // modifier isManager(){
    //     require(manager == msg.sender, "only manager.");
    //     _;
    // }

    

    constructor() {
        manager = msg.sender;
    }

    function createCampaign(address payable projectBuyer, uint256 fundingPeriod, 
                uint256 projectTotalFund, string memory projectTitle, string memory projectDescription,
                string memory projectFileName, uint256 prepaymentPercentage,
                uint256 milestones) public{
                    bytes32 _salt = keccak256(abi.encodePacked(msg.sender, projectBuyer, fundingPeriod, projectTotalFund, 
                    projectTitle, projectDescription, projectFileName,  prepaymentPercentage, milestones, manager));
                    Campaign newCampaign = new Campaign{
                        salt: bytes32(_salt)
                    }(payable(msg.sender), projectBuyer, fundingPeriod,
                     projectTotalFund, projectTitle, projectDescription, projectFileName, prepaymentPercentage, milestones, manager);
	                //campaigns.push(newCampaign);
                    campaignsList.push(address(newCampaign));
                    campaignAddressList[address(newCampaign)] = true;
                    infoCreator[msg.sender].push(address(newCampaign));
                    infoBuyer[projectBuyer].push(address(newCampaign));
                    managerPendingList[address(newCampaign)] = true;
                    pendingProjectsNum ++;
                    // emit campaignCreated(projectTitle, address(newCampaign), msg.sender, projectBuyer, projectTotalFund);
                 }

            
    // function getAddress(address projectBuyer, uint256 fundingPeriod, uint256 projectTotalFund,
    // string memory projectTitle, uint256 prepaymentPercentage, uint256 milestones) public view returns (address) {
    //     bytes memory bytecode = abi.encodePacked(type(Campaign).creationCode, abi.encode(msg.sender, projectBuyer, fundingPeriod, 
    //     projectTotalFund, projectTitle, prepaymentPercentage, milestones, manager));
    //     bytes32 _salt = keccak256(abi.encodePacked(msg.sender, projectBuyer, fundingPeriod, projectTotalFund, 
    //     projectTitle, prepaymentPercentage, milestones, manager));
    //     bytes32 hash = keccak256(
    //         abi.encodePacked(
    //             bytes1(0xff), address(this), _salt, keccak256(bytecode)
    //         )
    //     );
    //     return address(uint160(uint(hash)));
    // }

    function Campaigns_list() external view returns (address[] memory){
        return campaignsList;
    }

    function updatePendingList(address projectCampaign) external{
        require(campaignAddressList[msg.sender] == true, "only deployed campaigns.");
        managerPendingList[projectCampaign] = false;
        pendingProjectsNum --;
    }



    function addInvestorInfo(address userAddress, address campaignAddress) external{
        require(campaignAddressList[msg.sender] == true, "only deployed campaigns.");
        infoInvestor[userAddress].push(campaignAddress);
    }


    function pendingPojectsList() public view returns(address[] memory){
        require(manager == msg.sender, "only manager.");
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

    function getInvestableProjects() public view returns(address[] memory){ 
        uint256 count = 0;
        for (uint256 i=0; i < campaignsList.length; i++){
            address campaignAddress = campaignsList[i];
            if ((uint256(ICampaign(campaignAddress).getProjectStatus()) == 2) || (ICampaign(campaignAddress).getReplaceRequests())){
                count ++;
            }
        }

        address[] memory investableProjects = new address[](count);
        uint256 index = 0;
        for (uint256 j=0; j < campaignsList.length; j++){
            address campaignAddress = campaignsList[j];
            if ((uint256(ICampaign(campaignAddress).getProjectStatus()) == 2) || (ICampaign(campaignAddress).getReplaceRequests())){
                investableProjects[index] = campaignAddress;
                index ++;
            }

        }

        return investableProjects;
    } 



    function getUserCampaignData(address userAddress, uint256 index) external view returns(projectInfo[] memory){
        // address[] memory creatorAddressList = getCreatorInfo(userAddress);
        uint256 count = 0;
        address[] memory addressList;
        if (index == 0){
            // zero for creator
            addressList = infoCreator[userAddress];
            count = addressList.length;    
        }

        if (index == 1){
            // one for buyer
            addressList = infoBuyer[userAddress];
            count = addressList.length;
        }
        
        if (index == 2){
            //2 for investor
            addressList = infoInvestor[userAddress];
            count = addressList.length;
        }
        projectInfo[] memory result = new projectInfo[](count);
        for (uint256 i = 0; i < count; i++) {
            address campaignAddress = addressList[i];
            projectInfo memory res = projectInfo(
                ICampaign(campaignAddress).title(),
                campaignAddress,   
                ICampaign(campaignAddress).description(),
                ICampaign(campaignAddress).fileName(),
                ICampaign(campaignAddress).fullFund(),
                ICampaign(campaignAddress).milestoneNum(),
                ICampaign(campaignAddress).totalFund(),
                ICampaign(campaignAddress).buyerApproved(),
                ICampaign(campaignAddress).projectComplete(),
                ICampaign(campaignAddress).investorsAmount(userAddress),
                //ICampaign(campaignAddress).isFundingFinished(),
                ICampaign(campaignAddress).getProjectStatus(),
                ICampaign(campaignAddress).investorsCount()
            );
            result[i] = res;
        }
        return result;
    }

    // function getBuyerCampaignData(address userAddress) external view returns(projectInfo[] memory){
    //     // address[] memory buyerAddressList = getBuyerInfo(userAddress);
    //     address[] memory buyerAddressList = infoBuyer[userAddress];
    //     uint256 count = buyerAddressList.length;
    //     projectInfo[] memory result = new projectInfo[](count);
    //     for (uint256 i = 0; i < count; i++) {
    //         address campaignAddress = buyerAddressList[i];
    //         projectInfo memory res = projectInfo(
    //             ICampaign(campaignAddress).title(),
    //             campaignAddress,
    //             ICampaign(campaignAddress).fileName(),
    //             ICampaign(campaignAddress).description(),
    //             ICampaign(campaignAddress).fullFund(),
    //             ICampaign(campaignAddress).milestoneNum(),
    //             ICampaign(campaignAddress).totalFund(),
    //             ICampaign(campaignAddress).buyerApproved(),
    //             ICampaign(campaignAddress).projectComplete(),
    //             ICampaign(campaignAddress).investorsAmount(userAddress),
    //             //ICampaign(campaignAddress).isFundingFinished(),
    //             ICampaign(campaignAddress).getProjectStatus()
    //         );
    //         result[i] = res;
    //     }
    //     return result;
    // } 

    
    

    // function getInvestorCampaignData(address userAddress) external view returns(projectInfo[] memory){
    //     //address[] memory  investorAddressList = getInvestorInfo(userAddress);
    //     address[] memory  investorAddressList = infoInvestor[userAddress];
    //     uint256 count = investorAddressList.length;
    //     projectInfo[] memory result = new projectInfo[](count);
    //     for (uint256 i = 0; i < count; i++) {
    //         address campaignAddress = investorAddressList[i];
    //         projectInfo memory res = projectInfo(
    //             ICampaign(campaignAddress).title(),
    //             campaignAddress,
    //             ICampaign(campaignAddress).fileName(),
    //             ICampaign(campaignAddress).description(),
    //             ICampaign(campaignAddress).fullFund(),
    //             ICampaign(campaignAddress).milestoneNum(),
    //             ICampaign(campaignAddress).totalFund(),
    //             ICampaign(campaignAddress).buyerApproved(),
    //             ICampaign(campaignAddress).projectComplete(),
    //             ICampaign(campaignAddress).investorsAmount(userAddress),
    //             //ICampaign(campaignAddress).isFundingFinished(),
    //             ICampaign(campaignAddress).getProjectStatus()
    //         );
    //         result[i] = res;
    //     }
    //     return result;
    // }



    function projectsInStatus(uint256[] memory projectState) public view returns(projectInfo[] memory){
        uint256 index = 0;
        uint256 count = 0;

        for (uint256  i = 0; i < projectState.length; i++){
            uint256 status = projectState[i];
            for (uint256 j=0; j < campaignsList.length; j++){
                address deployedCampaign = campaignsList[j];
                if (status == ICampaign(deployedCampaign).getProjectStatus()){
                    count ++;
                }
            }
        }

        projectInfo[] memory result = new projectInfo[](count);

        for (uint256  h = 0; h < projectState.length; h++){
            uint256 status = projectState[h];
            for (uint256 k=0; k < campaignsList.length; k++){
                address deployedCampaign = campaignsList[k];
                if (status == ICampaign(deployedCampaign).getProjectStatus()){
                    projectInfo memory res = projectInfo(
                    ICampaign(deployedCampaign).title(),
                    deployedCampaign,     
                    ICampaign(deployedCampaign).description(),
                    ICampaign(deployedCampaign).fileName(),
                    ICampaign(deployedCampaign).fullFund(),
                    ICampaign(deployedCampaign).milestoneNum(),
                    ICampaign(deployedCampaign).totalFund(),
                    ICampaign(deployedCampaign).buyerApproved(),
                    ICampaign(deployedCampaign).projectComplete(),
                    ICampaign(deployedCampaign).totalFund(),
                    //ICampaign(deployedCampaign).isFundingFinished(),
                    ICampaign(deployedCampaign).getProjectStatus(),
                    ICampaign(deployedCampaign).investorsCount()
            );
            result[index] = res;
            index ++;
                }
            }
        }
        return result;                
    }
        
}