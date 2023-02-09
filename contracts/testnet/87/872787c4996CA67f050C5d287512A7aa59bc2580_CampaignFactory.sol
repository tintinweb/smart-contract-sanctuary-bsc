// SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;
//pragma experimental ABIEncoderV2;
import "./campaign.sol";
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
                uint256 milestones, address ERC20Token) public{
                    bytes32 _salt = keccak256(abi.encodePacked(msg.sender, projectBuyer, fundingPeriod, projectTotalFund, 
                    projectTitle, projectDescription, projectFileName,  prepaymentPercentage, milestones, manager, ERC20Token));
                    Campaign newCampaign = new Campaign{
                        salt: bytes32(_salt)
                    }(payable(msg.sender), projectBuyer, fundingPeriod,
                     projectTotalFund, projectTitle, projectDescription, projectFileName, prepaymentPercentage, milestones, manager, ERC20Token);
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



    function updateInvestorInfo(address userAddress, address campaignAddress, uint256 operation) external{
        require(campaignAddressList[msg.sender] == true, "only deployed campaigns.");
        if (operation == 1){
            infoInvestor[userAddress].push(campaignAddress);
        }

        if (operation == 0){
            for(uint256 i=0; i < infoInvestor[userAddress].length; i ++){
                if (infoInvestor[userAddress][i] == campaignAddress){
                    delete infoInvestor[userAddress][i];
                }
            }
        }
        
    }

    function getManagerPendingList(address campaignAddress) external view returns(bool){
        return managerPendingList[campaignAddress];
    }


    function getInfoCreator(address userAddress) external view returns(address[] memory) {
        return infoCreator[userAddress];
    }

    function getInfoBuyer(address userAddress) external view returns(address[] memory) {
        return infoBuyer[userAddress];
    }

    function getInfoInvestor(address userAddress) external view returns(address[] memory) {
        return infoInvestor[userAddress];

    }
    

        
}