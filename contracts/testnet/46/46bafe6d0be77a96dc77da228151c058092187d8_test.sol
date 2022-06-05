/**
 *Submitted for verification at BscScan.com on 2022-06-04
*/

/**
 *Submitted for verification at BscScan.com on 2022-03-21
*/

// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.7.4;



contract test {

    struct user{
        uint256 amount;
        address userAddr;
        uint256 time;
    }

    modifier onlyOwner{
        require(msg.sender == owner);
        _;
    }

    address owner = 0x4dDb6E714c1998f45a9819c2b1D6ac13886c210a;

    /// Kreira seznam "IDToUser. Key = user.
    mapping(uint256 => user) public IDToUser;
    uint256 public currentID;
    uint256 public totalID;
    

    uint256 maxBNBAccepted = 10000000000000000;
    uint256 devFeePercentage = 2;
    uint256 rewardFeePercentage = 8;
    uint256 gainsMultiplier = 15;
    uint256 timePassed = 6;


    /// Funkcije ki spreminjajo zgornje vrenosti
    function setDevFeePercentage(uint256 percent) public onlyOwner{
        devFeePercentage = percent;
    }

    function setTimePassed(uint256 tp) public onlyOwner{
        timePassed = tp;
    }
        function setRewardFeePercentage(uint256 percent) public onlyOwner{
        rewardFeePercentage = percent;
    }
    function setGainsMultiplier(uint256 gm) public onlyOwner{
        require (gm > 0);
        gainsMultiplier = gm;
    }

    function setMaxBNBAccepted(uint256 maxBNBAccept) public onlyOwner{
        maxBNBAccepted = maxBNBAccept;
    }

    
    bool allowTransfer = false;

    function setAllowTransfer(bool b) public onlyOwner{
        allowTransfer = b;
    }
/// Funkcije ki spreminjajo zgornje vrenosti


    function unstuckBalance(address receiver) public onlyOwner{
        uint256 contractETHBalance = address(this).balance;
        payable(receiver).transfer(contractETHBalance);
    }

    receive() payable external {
        require(msg.value == maxBNBAccepted && allowTransfer == true);
        IDToUser[totalID].userAddr = msg.sender;
        IDToUser[totalID].amount = msg.value;
        IDToUser[totalID].time = block.timestamp + (timePassed * 60) ;
        totalID++;

        



    
        uint256 devBalance = (msg.value * devFeePercentage) > 100 ? (msg.value * devFeePercentage) / 100 : 0;
        payable(owner).transfer(devBalance);

        uint256 rewardBalance = (msg.value * rewardFeePercentage) > 100 ? (msg.value * rewardFeePercentage) / 100 : 0;
        payable(owner).transfer(rewardBalance);



        uint256 availableBalance = address(this).balance;

        uint256 amountToSend = IDToUser[currentID].amount;

        if(availableBalance >= amountToSend * gainsMultiplier / 10){
            payable(IDToUser[currentID].userAddr).transfer(amountToSend * gainsMultiplier);
            currentID++;
        
        
       
        
        }     

        if (block.timestamp > IDToUser[totalID--].time) {

             uint256 reward = rewardBalance / 10;
             uint256 x = 0;

            for (x = 0 ; x<10; x++){

        
            payable(IDToUser[totalID].userAddr).transfer(reward);
            totalID--;
            }
            bool allowTransfer = false;
         }

    }
 }