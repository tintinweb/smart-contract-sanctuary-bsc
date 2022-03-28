// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


contract Crowdfund_Create {
    uint256 public totalCrowdfunds = 0;
    
    struct Crowdfund{
        uint256 id;
        address owner;
        uint256 crowdfundGoal;
        uint256 crowdfundAmount;
        bool isOpen;
    }

    mapping(uint => Crowdfund) public crowdfunds;

    function createCrowdfund(uint256 crowdfundGoal) public{
        totalCrowdfunds += 1;
        crowdfunds[totalCrowdfunds] = Crowdfund(totalCrowdfunds, msg.sender, crowdfundGoal, 0, true);
    }

    function donateCrowdfund(uint256 crowdfundID) public payable {
        Crowdfund storage crowdfund = crowdfunds[crowdfundID];
        crowdfund.crowdfundAmount += msg.value;
    }
    
    function withdrawCrowdfund(uint256 crowdfundID) public {
        Crowdfund storage crowdfund = crowdfunds[crowdfundID];
        require(msg.sender == crowdfund.owner, "Must be owner of crowdfund");
        address payable withdrawAddres = payable(msg.sender);
        withdrawAddres.transfer(crowdfund.crowdfundAmount);
        crowdfund.isOpen = false;
    }
}