// SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;

import "./ICampaignFactory.sol";
import "./ICampaign.sol";

contract campaignInfo{

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

    ICampaignFactory public campaignFactoryContract;
    address public owner;

    constructor(address factoryContract){
        campaignFactoryContract = ICampaignFactory(factoryContract);
        owner = msg.sender;
    }

    function changeFactoryAddress(address newFactory) external{
        require(owner == msg.sender, "only owner!");
        campaignFactoryContract = ICampaignFactory(newFactory);
    }

    function getInvestableProjects() public view returns(projectInfo[] memory){ 
        address[] memory campaignsList = campaignFactoryContract.Campaigns_list();
        uint256 count = 0;
        for (uint256 i=0; i < campaignsList.length; i++){
            address campaignAddress = campaignsList[i];
            if ((uint256(ICampaign(campaignAddress).getProjectStatus()) == 2) || (ICampaign(campaignAddress).getReplaceRequestsflag())){
                count ++;
            }
        }

        //address[] memory investableProjects = new address[](count);
        projectInfo[] memory result = new projectInfo[](count);
        uint256 index = 0;
        
        for (uint256 j=0; j < campaignsList.length; j++){
            address campaignAddress = campaignsList[j];
            if ((uint256(ICampaign(campaignAddress).getProjectStatus()) == 2) || (ICampaign(campaignAddress).getReplaceRequestsflag())){
                // investableProjects[index] = campaignAddress;
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
                    ICampaign(campaignAddress).totalFund(),
                    //ICampaign(campaignAddress).isFundingFinished(),
                    ICampaign(campaignAddress).getProjectStatus(),
                    ICampaign(campaignAddress).investorsCount()
                );

                result[index] = res;
                index ++;

            }

        }

        // for (uint256 k = 0; k < investableProjects.length; k++) {
        //     address campaignAddress = investableProjects[k];
        //     projectInfo memory res = projectInfo(
        //         ICampaign(campaignAddress).title(),
        //         campaignAddress,   
        //         ICampaign(campaignAddress).description(),
        //         ICampaign(campaignAddress).fileName(),
        //         ICampaign(campaignAddress).fullFund(),
        //         ICampaign(campaignAddress).milestoneNum(),
        //         ICampaign(campaignAddress).totalFund(),
        //         ICampaign(campaignAddress).buyerApproved(),
        //         ICampaign(campaignAddress).projectComplete(),
        //         ICampaign(campaignAddress).totalFund(),
        //         //ICampaign(campaignAddress).isFundingFinished(),
        //         ICampaign(campaignAddress).getProjectStatus(),
        //         ICampaign(campaignAddress).investorsCount()
        //     );
        //     result[k] = res;
        // }

        return result;
    }


    function getUserCampaignData(address userAddress, uint256 index) external view returns(projectInfo[] memory){
        // address[] memory creatorAddressList = getCreatorInfo(userAddress);
        uint256 count = 0;
        address[] memory addressList;
        if (index == 0){
            // zero for creator
            addressList = campaignFactoryContract.getInfoCreator(userAddress);
                
        }

        if (index == 1){
            // one for buyer
            addressList = campaignFactoryContract.getInfoBuyer(userAddress);
        }
        
        if (index == 2){
            //2 for investor
            addressList = campaignFactoryContract.getInfoInvestor(userAddress);
        }

        count = addressList.length;
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

    
    function projectsInStatus(uint256[] memory projectState) public view returns(projectInfo[] memory){
        uint256 index = 0;
        uint256 count = 0;
        address[] memory campaignsList = campaignFactoryContract.Campaigns_list();

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

    function pendingProjectsData() external view returns (projectInfo[] memory){
        address[] memory pendingProjects = pendingPojectsList();
        projectInfo[] memory result = new projectInfo[](pendingProjects.length);
        for (uint256 i=0; i<pendingProjects.length; i++){
            address notVerifiedProject = pendingProjects[i];
            projectInfo memory res = projectInfo(
                ICampaign(notVerifiedProject).title(),
                notVerifiedProject,   
                ICampaign(notVerifiedProject).description(),
                ICampaign(notVerifiedProject).fileName(),
                ICampaign(notVerifiedProject).fullFund(),
                ICampaign(notVerifiedProject).milestoneNum(),
                ICampaign(notVerifiedProject).totalFund(),
                ICampaign(notVerifiedProject).buyerApproved(),
                ICampaign(notVerifiedProject).projectComplete(),
                ICampaign(notVerifiedProject).totalFund(),
                //ICampaign(campaignAddress).isFundingFinished(),
                ICampaign(notVerifiedProject).getProjectStatus(),
                ICampaign(notVerifiedProject).investorsCount()
            );
            result[i] = res;
        }

        return result;
    }

    function pendingPojectsList() internal view returns(address[] memory){

        address[] memory campaignsList = campaignFactoryContract.Campaigns_list();
        //Campaign[] memory _campaigns = campaigns; 
        uint256 index = 0;
        uint256 count = campaignsList.length;
        address[] memory projectPendingList = new address[](campaignFactoryContract.pendingProjectsNum());
        for (uint256 i=0; i < count; i++){
            address campaignAddress = campaignsList[i];
            if (campaignFactoryContract.getManagerPendingList(campaignAddress)) {
                //projectPendingList.push(campaignAddress);
                projectPendingList[index] = campaignAddress;
                index ++;
            }
        }
        return projectPendingList;
    }

    
    function getStatusCount(address userAddress) external view returns(uint256 managerPendingCount, uint256 buyerPendingCount, uint256 investableCount){
        address[] memory campaignsList = campaignFactoryContract.Campaigns_list();
        address[] memory buyerList = campaignFactoryContract.getInfoBuyer(userAddress);
        for (uint256 i=0; i < campaignsList.length; i++){
            address campaignAddress = campaignsList[i];
            if ((uint256(ICampaign(campaignAddress).getProjectStatus()) == 2) || (ICampaign(campaignAddress).getReplaceRequestsflag())){
                investableCount ++;
            }
            if(uint256(ICampaign(campaignAddress).getProjectStatus()) == 0){
                managerPendingCount++;
            }
        }
        for (uint256 i=0; i < buyerList.length; i++){
            address campaignAddress = buyerList[i];
            if(uint256(ICampaign(campaignAddress).getProjectStatus()) == 1){
                buyerPendingCount++;
            }
        }
    }
        
}