/**
 *Submitted for verification at BscScan.com on 2022-03-03
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

contract SmartPrivateSale {
    address owner;

    uint256 currencyPrecision = 10**18;
    uint256 public amountRaised = 34000000000000000000;
    uint256 public numberOfInvestors = 8;
    uint256 public amountLimit = 0;

    mapping(address => uint256) investments;
    mapping(address => uint256) toraTokens;
    event TotalAmountIncreasedEvent(uint256 totalAmount);

    constructor() {
        owner = msg.sender;
    }

    function smartPackageInvestment() public payable {
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

    function myTokens() public view returns (uint256) {
        return investments[msg.sender];
    }
}