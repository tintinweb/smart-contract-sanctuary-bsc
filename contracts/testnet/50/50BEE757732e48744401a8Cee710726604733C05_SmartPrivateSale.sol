/**
 *Submitted for verification at BscScan.com on 2022-03-02
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

contract SmartPrivateSale {
    address owner;

    uint256 public amountRaised = 35;
    uint256 public numberOfInvestors = 4;
    uint256 public amountLimit = 0;

    mapping(address => uint256) investments;
    event TotalAmountIncreasedEvent(uint256 totalAmount);

    constructor() {
        owner = msg.sender;
    }

    function makeInvestment() public payable {
        require(investments[msg.sender] > 0, "You already Invested");
        require(msg.value > 0, "Please select a higher amount");

        if (investments[msg.sender] > 0) {
            investments[msg.sender] += msg.value;
            // nothing
        } else {
            investments[msg.sender] = msg.value;
            numberOfInvestors += 1;
        }
        amountRaised += msg.value;
        payable(owner).transfer(msg.value);
        
        emit TotalAmountIncreasedEvent(msg.value);
    }

    function changeLimit(uint256 limitToAmount) public {
        require(msg.sender == owner, "Owner Required");
        amountLimit = limitToAmount;
    }

    function myAmount() public view returns (uint256) {
        return investments[msg.sender];
    }
}