// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

contract CrowdFunding {

    struct Campaign {
        address owner;
        string title;
        string description;
        uint256 target;
        uint256 deadline; //deadline
        uint256 amountCollected; //So tien thu duoc
        string image; //<- url hình ảnh
        address[] donators;
        uint256[] donations;
    }

    mapping (uint256 => Campaign) public campains;

    uint256 public numberOfCampains = 0;

    //----------

    function compareStrings(string memory _a, string memory _b) public pure returns (bool) {
        return keccak256(abi.encodePacked(_a)) == keccak256(abi.encodePacked(_b));
    }

    //----------

    function createCampaign (address _owner, string memory _title, string memory _description, uint256 _target, uint256 _deadline, string memory _image) public returns (uint256){
        Campaign storage campaign = campains[numberOfCampains];

        require(campaign.deadline < _deadline, "The deadline should be a date in the future.");

        campaign.owner = _owner;
        campaign.title = _title;
        campaign.description = _description;
        campaign.target = _target;
        campaign.deadline = _deadline;
        campaign.amountCollected = 0;
        campaign.image = _image;

        numberOfCampains ++;

        return numberOfCampains - 1;
    }

    function donateToCampaign (uint256 _id) public payable {
        uint256 amount = msg.value;

        Campaign storage campaign = campains[_id];

        campaign.donators.push (msg.sender);
        campaign.donations.push (amount);

        (bool sent,) = payable(campaign.owner).call{value: amount} ("");

        if (sent) {
            campaign.amountCollected += amount;
        }
    }

    function getDonators (uint256 _id) view public returns (address[] memory, uint256[] memory) {
        return (campains[_id].donators, campains[_id].donations);
    }

    function getCampaigns () public view returns (Campaign [] memory) {
        Campaign[] memory allCampaigns = new Campaign[] (numberOfCampains);

        for (uint i=0; i < numberOfCampains; i++) {
            Campaign storage item = campains[i];

            allCampaigns[i] = item;
        }

        return allCampaigns;
    }
    function findCampaignByTitle(string memory _title) public view returns (Campaign memory) {
        for (uint i = 0; i < numberOfCampains; i++) {
            Campaign memory campaign = campains[i];
            if (compareStrings (campaign.title, _title)) {
                return campaign;
            }
        }
        return campains[numberOfCampains + 2];
    }
}