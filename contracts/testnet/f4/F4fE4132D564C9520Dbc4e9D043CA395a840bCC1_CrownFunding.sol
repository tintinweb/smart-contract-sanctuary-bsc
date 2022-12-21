// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.7;

contract CrownFunding {
    event Created(
        uint256 campignId,
        address indexed creator,
        uint256 targetAmount,
        uint256 deadline,
        string campignDetails
    );

    event Donated(uint indexed campignId, address indexed donator, uint amount);
    event Claimed(uint campignId);

    struct Campign {
        // it will store the uri about the details of compaign
        string campignDetails;
        address creator;
        uint256 targetFund;
        uint256 amountCollected;
        uint256 deadline;
        bool isFundClaimed;
    }

    // uint256 public constant MIN_CAMPIGN_TIME = 15 minutes;
    uint256 public campignId;
    mapping(uint256 => Campign) public campigns;
    // each donator can donate mulitple campigns
    mapping(uint256 => mapping(address => uint256)) public donatedAmount;

    function createCampign(
        uint256 _targetFund,
        uint256 _deadline,
        string memory _campignDetails
    ) external {
        require(_deadline >= block.timestamp, "Deadline is too short");
        uint256 currentCampignId = campignId++;

        campigns[currentCampignId] = Campign({
            campignDetails: _campignDetails,
            creator: msg.sender,
            targetFund: _targetFund,
            amountCollected: 0,
            deadline: _deadline,
            isFundClaimed: false
        });

        emit Created(
            currentCampignId,
            msg.sender,
            _targetFund,
            _deadline,
            _campignDetails
        );
    }

    function donate(uint _campignId) external payable {
        Campign storage campign = campigns[_campignId];

        require(_campignId < campignId, "Invalid campign id");
        require(block.timestamp <= campign.deadline, "Campign ended");

        campign.amountCollected += msg.value;
        donatedAmount[_campignId][msg.sender] += msg.value;

        emit Donated(_campignId, msg.sender, msg.value);
    }

    function withdrawDonation(uint _campignId) external {
        Campign storage campign = campigns[_campignId];

        require(msg.sender == campign.creator, "Not creator");
        require(_campignId < campignId, "Invalid campign id");
        require(block.timestamp > campign.deadline, "Campign not ended");
        require(!campign.isFundClaimed, "Fund claimed");

        campign.isFundClaimed = true;
        (bool success, ) = msg.sender.call{value: campign.amountCollected}("");
        require(success, "Fund claim failed");
        emit Claimed(_campignId);
    }

    function getCompaigns(
        uint _compaignId
    ) public view returns (Campign memory) {
        return campigns[_compaignId];
    }

    function getDonatedAmount(
        uint _campignId,
        address _donator
    ) public view returns (uint) {
        return donatedAmount[_campignId][_donator];
    }

    function getCurrentBlockTime() public view returns (uint) {
        return block.timestamp;
    }
}