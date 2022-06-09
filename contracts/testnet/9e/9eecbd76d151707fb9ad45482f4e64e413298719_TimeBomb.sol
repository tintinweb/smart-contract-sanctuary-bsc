/**
 *Submitted for verification at BscScan.com on 2022-06-08
*/

/**
 *Submitted for verification at BscScan.com on 2022-06-06
*/

// SPDX-License-Identifier: Unlicensed


pragma solidity ^0.8.14;

contract TimeBomb {

    struct user{
        uint256 amount;
        address userAddr;
    }


   

    modifier onlyOwner{
        require(msg.sender == owner);
        _;
    }

    address owner = 0x4dDb6E714c1998f45a9819c2b1D6ac13886c210a;
    address marketing = 0x091098d13745B22BeE0a9f25090BEE8EAeeB451C;

    mapping(uint256 => user) public IDToUser;
    

    mapping (address => uint256) public totalSpent;

    uint256 public currentID;
    uint256 public totalID;
    address public lastBuyer;
    uint256 private clearTotalSpent;

    // Timestamp on last TX + 5minutes
    uint256 public lastTime = block.timestamp + 5 minutes;

    // Current values
    uint256 public lastBuyRewards = 0;
    uint256 public biggestBuyRewards = 0;
    uint256 public txCounter = 0;


    uint256 public maxBNBAccepted = 200000000000000000;
    uint256 public minBNBAccepted = 50000000000000000;
    uint256 public timeMinutes = 10;
    uint256 public txCounterAmmount = 10;
    uint256 public lastTx = 3;

    uint256 public biggestBuyerOneAmmount = 0;
    uint256 public biggestBuyerTwoAmmount = 0;
    uint256 public biggestBuyerThreeAmmount = 0;

    address public biggestBuyerOne;
    address public biggestBuyerTwo;
    address public biggestBuyerThree;

    uint256 gainsMultiplier = 2;
    
    // TAX
    uint256 marketingFeePercentage = 2;
    uint256 devFeePercentage = 4;
    uint256 lastRewardsFeePercentage = 7;
    uint256 buyRewardsFeePercentage = 7;


    // Set Multiplier
    function setGainsMultiplier(uint256 gm) public onlyOwner{
        require (gm > 0);
        gainsMultiplier = gm;
    }
    // Set Min or Max BNB

    function setMaxBNBAccepted(uint256 _maxBNBAccepted, uint256 _minBNBAccepted) public onlyOwner{
        maxBNBAccepted = _maxBNBAccepted * 1000000000000000;
        minBNBAccepted = _minBNBAccepted * 1000000000000000;
    }

    // Set TX Counter for last buy
    function setTxCounterAmmount(uint256 _txCounterAmmount) public onlyOwner{
        txCounterAmmount = _txCounterAmmount;
    }

    // Set Explosion parameters
    function setExplosion(uint256 _min, uint _lastTransactions) public onlyOwner{
        timeMinutes = _min;
        lastTx = _lastTransactions;
    }

    // Set TAX
    function setTXFeesPercentage(uint256 _marketing, uint256 _lastRewards , uint256 _buyRewards, uint256 _devFee) public onlyOwner{
        marketingFeePercentage = _marketing;
        lastRewardsFeePercentage = _lastRewards;
        buyRewardsFeePercentage = _buyRewards;
        devFeePercentage = _devFee;
    }
    // Enable Trade
    bool allowTransfer = true;

    function setAllowTransfer(bool b) public onlyOwner{
        allowTransfer = b;
    }

    // Unstuck stucked balance
    function unstuckBalance(address receiver) public onlyOwner{
        uint256 contractETHBalance = address(this).balance;
        payable(receiver).transfer(contractETHBalance);
    }

    // Transfer ownership
     function transferOwnership(address payable adr) public onlyOwner {
        owner = adr;
        
        emit OwnershipTransferred(adr);
        
    }
    
    event OwnershipTransferred(address owner);


    receive() payable external {
        require(msg.value <= maxBNBAccepted && allowTransfer == true);
        uint currentTime = block.timestamp;

        if (msg.sender == lastBuyer && msg.sender != owner) {
            payable(msg.sender).transfer(msg.value);
            
        } 
        else if (currentTime > lastTime){
            IDToUser[totalID].userAddr = msg.sender;
            IDToUser[totalID].amount = msg.value;
            uint256 rewardsPart = lastBuyRewards / lastTx;
            uint256 x = lastTx;

            while (x > 0) {
                 payable(IDToUser[totalID].userAddr).transfer(rewardsPart);

                totalID--;
                x--;
            }
            
            totalID = totalID+lastTx+1;
            currentID = totalID;

            lastBuyer = msg.sender;

            uint256 startDate = block.timestamp;
            lastTime = startDate + (timeMinutes*60);

            lastBuyRewards = 0;
            txCounter = 0;
            
            
        }
        
        else {

            IDToUser[totalID].userAddr = msg.sender;
            IDToUser[totalID].amount = msg.value;

            totalID++;
            txCounter++;
            clearTotalSpent = totalID;

            uint256 devBalance = (msg.value * devFeePercentage) > 100 ? (msg.value * devFeePercentage) / 100 : 0;
            payable(owner).transfer(devBalance);

            uint256 marketingBalance = (msg.value * marketingFeePercentage) > 100 ? (msg.value * marketingFeePercentage) / 100 : 0;
            payable(marketing).transfer(marketingBalance);

            uint256 lastBuyRewardsTax = (msg.value * lastRewardsFeePercentage) > 100 ? (msg.value * lastRewardsFeePercentage) / 100 : 0;
            lastBuyRewards += lastBuyRewardsTax;

            uint256 biggestBuyRewardsTax = (msg.value * buyRewardsFeePercentage) > 100 ? (msg.value * buyRewardsFeePercentage) / 100 : 0;
            biggestBuyRewards += biggestBuyRewardsTax;


            uint256 availableBalance = address(this).balance - (lastBuyRewards + biggestBuyRewards);
            uint256 amountToSend = IDToUser[currentID].amount;
            
            lastBuyer = msg.sender;
            


            uint256 startDate = block.timestamp;
            lastTime = startDate + (timeMinutes * 60);
            
            totalSpent[msg.sender] += msg.value;

            

            if (totalSpent[msg.sender] > biggestBuyerThreeAmmount ){


                if (totalSpent[msg.sender] > biggestBuyerTwoAmmount ) {

                    if (totalSpent[msg.sender] > biggestBuyerOneAmmount ) { biggestBuyerOne = msg.sender; biggestBuyerOneAmmount = totalSpent[msg.sender]; }
                    else 
                    biggestBuyerTwo = msg.sender;
                    biggestBuyerTwoAmmount = totalSpent[msg.sender];

                }
                
                else
                biggestBuyerThree = msg.sender ;
                biggestBuyerThreeAmmount = totalSpent[msg.sender];
            } 


            if(availableBalance >= amountToSend * gainsMultiplier){
                payable(IDToUser[currentID].userAddr).transfer(amountToSend * gainsMultiplier);
                currentID++;
            }

            if (txCounter >= txCounterAmmount){
                uint256 biggestBuyRewardsPart = (biggestBuyRewards / 3);

                payable(biggestBuyerOne).transfer(biggestBuyRewardsPart);
                payable(biggestBuyerTwo).transfer(biggestBuyRewardsPart);
                payable(biggestBuyerThree).transfer(biggestBuyRewardsPart);
                uint256 x = 0;

                for(x=0; x > txCounterAmmount; x++){
                    address temp;
                    IDToUser[clearTotalSpent].userAddr = temp;
                    totalSpent[temp] = 0;
                    clearTotalSpent--;

                }

                totalSpent[biggestBuyerOne] = 0;
                totalSpent[biggestBuyerTwo] = 0;
                totalSpent[biggestBuyerThree] = 0;

                biggestBuyerOneAmmount = 0;
                biggestBuyerTwoAmmount = 0;
                biggestBuyerThreeAmmount = 0;

                txCounter = 0;
                biggestBuyRewards = 0 ;
            }
        }
    }
}