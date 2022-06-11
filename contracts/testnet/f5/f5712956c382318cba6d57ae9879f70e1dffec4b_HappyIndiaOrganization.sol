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