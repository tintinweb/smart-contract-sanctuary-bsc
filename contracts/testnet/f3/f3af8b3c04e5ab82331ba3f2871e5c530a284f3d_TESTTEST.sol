/**
 *Submitted for verification at BscScan.com on 2022-06-04
*/

/**
 *Submitted for verification at BscScan.com on 2022-03-22
*/

// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.7.4;



contract TESTTEST {

    struct user{
        uint256 amount;
        address userAddr;
    }

    modifier onlyOwner{
        require(msg.sender == owner);
        _;
    }

    address owner = 0x4dDb6E714c1998f45a9819c2b1D6ac13886c210a;


    mapping(uint256 => user) public IDToUser;
    uint256 public currentID;
    uint256 public totalID;
    address public lastApe;


    uint256 lastTime = block.timestamp + 10 minutes;
    uint256 rewards = 0;

    uint256 maxBNBAccepted = 10000000000000000;
    uint256 devFeePercentage = 2;
    uint256 lastTx = 5;
    uint256 gainsMultiplier = 2;
    uint256 timeMinutes = 5;
    uint256 rewardsFeePercentage = 8;



    function setRewardsFeePercentage(uint256 percent) public onlyOwner{
        rewardsFeePercentage = percent;
    }

    function setTimeMinutes(uint256 min) public onlyOwner{
        timeMinutes = min;
    }

    function setDevFeePercentage(uint256 percent) public onlyOwner{
        devFeePercentage = percent;
    }

    function setLastTx(uint256 count) public onlyOwner{
        lastTx = count;
    }

    function setGainsMultiplier(uint256 gm) public onlyOwner{
        require (gm > 0);
        gainsMultiplier = gm;
    }

    function setMaxBNBAccepted(uint256 maxBNBAccept) public onlyOwner{
        maxBNBAccepted = maxBNBAccept * 1000000000000000;
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
        uint currentTime = block.timestamp;

        if (msg.sender == lastApe && msg.sender != owner) {
            payable(msg.sender).transfer(msg.value);
            
        } 
        else if ( currentTime > lastTime ){
            totalID--;
            uint256 rewardsPart = rewards / lastTx;
            while (lastTx > 0) {
                 payable(IDToUser[totalID].userAddr).transfer(rewardsPart);

                totalID--;
                lastTx--;
            }
            

        }
        
        else {
            IDToUser[totalID].userAddr = msg.sender;
            IDToUser[totalID].amount = msg.value;
            totalID++;
            uint256 devBalance = (msg.value * devFeePercentage) > 100 ? (msg.value * devFeePercentage) / 100 : 0;
            payable(owner).transfer(devBalance);

            uint256 rewardsTax = (msg.value * rewardsFeePercentage) > 100 ? (msg.value * rewardsFeePercentage) / 100 : 0;
            rewards =  rewards + rewardsTax;


            uint256 availableBalance = address(this).balance - rewards;
            uint256 amountToSend = IDToUser[currentID].amount;


            lastApe = msg.sender;
            uint256 startDate = block.timestamp;
            lastTime = startDate + (timeMinutes * 60);
            if(availableBalance >= amountToSend * gainsMultiplier){
                payable(IDToUser[currentID].userAddr).transfer(amountToSend * gainsMultiplier);
                currentID++;
            }
        }
    }
}