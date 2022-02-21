/**
 *Submitted for verification at BscScan.com on 2022-02-20
*/

//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.12;


contract Crowfunding {

    uint public number = 5;
    struct User {
        uint DonatedTime;
        uint AmountDonated;
    }

    struct UserCampaign {
        bytes32 title;
        bytes32 web_page;
        uint currentMoney;
        address ownerAddress;
        mapping(address => User) members;
    }

    mapping(address => UserCampaign) public Campaigns;

    function modifyNumber(uint _number) public {
        number = _number;
    }

    function CreateCampaign (bytes32 title, bytes32 web) public OnlyOneCampaignPerAddress returns(bool success) {

        UserCampaign storage newCampaign = Campaigns[msg.sender];

        newCampaign.title = title;
        newCampaign.web_page = web;
        newCampaign.ownerAddress = msg.sender;

        return (true);    
    }

    function DeleteCampaign() public OnlyOwner {
        delete(Campaigns[msg.sender]);
    }

    function CampaignExists(address _campaignAddress) public view returns(bool exist) {
        if (Campaigns[_campaignAddress].ownerAddress != address(0)) return true;
        return false;
    }

    function DonateToCampaign(address payable _ownerCampaign) public payable returns(uint amountDonated, bool success){

        require(msg.value > 0 , "Error: the money is not more than 0.");
        
        UserCampaign storage campaign = Campaigns[_ownerCampaign];
        payable(_ownerCampaign).transfer(msg.value);
        campaign.members[msg.sender] = User(block.timestamp, msg.value);
        campaign.currentMoney += msg.value;

        return (msg.value, true);
    }

    function BackDonation(address _ownerCampaign) public payable returns(uint amountBack, bool success) {

        User storage user = Campaigns[_ownerCampaign].members[msg.sender];

        require(user.AmountDonated > 0, "Error: you didn't donated anything.");

        if ((user.DonatedTime + 1 days) < block.timestamp) {

            payable(msg.sender).transfer(user.AmountDonated);
            user.AmountDonated = 0;
            user.DonatedTime -= 1 days;
            
            return (user.AmountDonated, true);
        }
        return (0, false);
        
    }

    modifier OnlyOneCampaignPerAddress() {
        require(Campaigns[msg.sender].ownerAddress == address(0), "Error: One campaign per address.");
        _;
    }

    modifier OnlyOwner() {
        require(Campaigns[msg.sender].ownerAddress == msg.sender, "Error: only owner campaign can delete this.");
        _;
    }
}