/**
 *Submitted for verification at BscScan.com on 2022-03-03
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

contract SmartPrivateSale {
    address owner;

    uint256 currencyPrecision = 10**18;
    uint256 oneBNBValue = 416666666667;
    uint256 public numberOfInvestors = 4;
    uint256 public amountRaised = 17000000000000000000;
    uint256 public amountLimit = 218000000000000000000;
    bool public limitPackages = true;

    mapping(uint8 => uint8) packagesAvailable;
    mapping(uint8 => uint8) packagesSold;

    mapping(address => uint256) investments;
    mapping(address => uint256) toraTokens;
    event TotalAmountIncreasedEvent(uint256 totalAmount);

    constructor() {
        owner = msg.sender;

        packagesAvailable[1] = 8;
        packagesAvailable[5] = 6;
        packagesAvailable[10] = 4;
        packagesAvailable[20] = 3;
        packagesAvailable[40] = 2;

        packagesSold[1] = 2;
        packagesSold[5] = 1;
        packagesSold[10] = 1;
        packagesSold[20] = 0;
        packagesSold[40] = 0;
    }

    function smartPackageInvestment() public payable {
        require(msg.value > 0, "Please select a higher amount");
        require(amountLimit > amountRaised, "Amount Limit Reached");

        uint8 packageNumber = uint8(msg.value / currencyPrecision);
        if (limitPackages == true) {
            require(
                packagesAvailable[packageNumber] > 0,
                "Package Limit Reached"
            );
        }

        if (investments[msg.sender] > 0) {
            investments[msg.sender] += msg.value;
            toraTokens[msg.sender] += msg.value * oneBNBValue;
        } else {
            investments[msg.sender] = msg.value;
            toraTokens[msg.sender] = msg.value * oneBNBValue;
            numberOfInvestors += 1;
        }
        amountRaised += msg.value;
        payable(owner).transfer(msg.value);

        emit TotalAmountIncreasedEvent(msg.value);
    }

    function setLimitAmount(uint256 limitToAmount) public {
        require(msg.sender == owner, "Owner Required");
        amountLimit = limitToAmount;
    }

    function setLimitPackages(bool limitToPackages) public {
        require(msg.sender == owner, "Owner Required");
        limitPackages = limitToPackages;
    }

    function myAmount() public view returns (uint256) {
        return investments[msg.sender];
    }

    function myTokens() public view returns (uint256) {
        return toraTokens[msg.sender];
    }

    function packageAvailability(uint8 packageNumber)
        public
        view
        returns (uint8, uint8)
    {
        return (packagesAvailable[packageNumber], packagesSold[packageNumber]);
    }

    function endPrivateSale() public {
        require(msg.sender == owner, "Owner Required");
        payable(owner).transfer(address(this).balance);
    }
}