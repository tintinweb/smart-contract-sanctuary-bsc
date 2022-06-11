/**
 *Submitted for verification at BscScan.com on 2022-06-10
*/

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract HappyIndiaOrganization {
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    address public owner;
    uint256 public totalPool;
    mapping(address => Project) public ownerToProject;
    bool public publicContributionsPeriod;
    address[] public ownersAddressArray;
    uint256 public totalMatched;

    struct Project {
        string name;
        uint256 publicAmount;
        address owner;
        uint256[] contributions;
        uint256 matchedAmount;
        uint256 proportionalMatchedAmount;
    }

    function togglePublicCOntributions() public onlyOwner {
        publicContributionsPeriod = !publicContributionsPeriod;
    }

    function addPublicContribution(address projectOwner) external payable {
        require(publicContributionsPeriod, "Public contributions are halted");
        ownerToProject[projectOwner].contributions.push(msg.value);
        ownerToProject[projectOwner].publicAmount += msg.value;
    }

    function calculateMatchedAmount(address projectOwner)
        external
        returns (uint256)
    {
        uint256[] memory contributionsArray = ownerToProject[projectOwner]
            .contributions;
        uint256 sqrtSum = 0;
        for (uint256 i = 0; i < contributionsArray.length; i++) {
            sqrtSum += sqrt(contributionsArray[i]);
        }
        uint256 matchedAmount = sqrtSum**2 -
            ownerToProject[projectOwner].publicAmount;
        ownerToProject[projectOwner].matchedAmount = matchedAmount;
        return matchedAmount;
    }

    function calculateProportionalMatchedAmount(address projectOwner) external {
        require(totalMatched != 0, "Total amount not matched");
        uint256 matchAmount = ownerToProject[projectOwner].matchedAmount;
        uint256 proportionalMatchAmount = (matchAmount * totalPool) /
            totalMatched;
        ownerToProject[projectOwner]
            .proportionalMatchedAmount = proportionalMatchAmount;
    }

    function calculateTotalMatchedAmount() internal {
        for (uint256 i = 0; i < ownersAddressArray.length; i++) {
            uint256 matchAmount = ownerToProject[ownersAddressArray[i]]
                .matchedAmount;
            if (matchAmount == 0) {
                revert("Amounts not matched for all projects");
            }
            totalMatched += matchAmount;
        }
    }

    function withdrawFunds() external {
        address projectOwner = msg.sender;
        uint256 publicContrbution = ownerToProject[projectOwner].publicAmount;
        uint256 proportionalAmountMatched = ownerToProject[projectOwner]
            .proportionalMatchedAmount;
        payable(projectOwner).transfer(
            publicContrbution + proportionalAmountMatched
        );
    }

    function sqrt(uint256 x) internal pure returns (uint256 y) {
        uint256 z = (x + 1) / 2;
        y = x;
        while (z < y) {
            y = z;
            z = (x / z + z) / 2;
        }
    }
}

// get a list of projects -> store it somewhere -> ask for contribution from public -> add ability to stop getting public contribution ->
// calculate matched amount -> disburse said amount