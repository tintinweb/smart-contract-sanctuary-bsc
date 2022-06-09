/**
 *Submitted for verification at BscScan.com on 2022-06-09
*/

/**


 TAX:
 5% TOP BUYER (Every 500 transaction colected reward distributes to TOP 3 investors at the time)
 5% BOMB EXPLOSION (If there are no TX for more than 5min, reward gets distributed to last 3 TX)
 5% MARKETING 
 5% DEVELOPMENT


*/

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.14;

contract TimeBomb {

    struct user{
        uint256 amount;
        address userAddr;
    }
  
    struct topUser{
        uint256 amount;
        address userAddr;
    }
   
    modifier onlyOwner{
        require(msg.sender == owner);
        _;
    }

    address owner = 0x80E00BEa75A46DA43a7836dcdf0c4DA67C979A2F;
    address dev = 0x9d98ee8c0c28111b6602c5aC249df031e6CD87Da;
 

    mapping(uint256 => user) public IDToUser;
    mapping(uint256 => topUser) public topBuyers;

    mapping(address => bool) topBuyerRegistered;
    mapping(uint256 => address) topBuyerRegisteredCounter;
    mapping(address => uint256) totalSpent;

    uint256 public aCurrentID;
    uint256 public aTotalID;
    address lastBuyer;
    uint256 topBuyerRegisteredCount;

    // Timestamp on last TX + 5minutes
    uint256 public lastTime = block.timestamp + 5 minutes;

    // Initial values
    uint256 public lastBuyRewards;
    uint256 public biggestBuyRewards;
    uint256 public txCounter;
   

    uint256 public maxBNBAccepted = 50000000000000000;
    uint256 public minBNBAccepted = 50000000000000000;
    uint256 public timeMinutes = 100;
    uint256 public txCounterLimit = 500;

    uint256 topBuyer = 3;
    uint256 lastTx = 3;


    uint256 gainsMultiplier = 2;
    
    // TAX
    uint256 marketingFeePercentage = 5;
    uint256 devFeePercentage = 5;
    uint256 lastRewardsFeePercentage = 5;
    uint256 buyRewardsFeePercentage = 5;


    // Set Multiplier
    function setGainsMultiplier(uint256 gm) public onlyOwner{
        require (gm > 0);
        gainsMultiplier = gm;
    }
    // Set Min or Max BNB

    function setBNBAccepted(uint256 _maxBNBAccepted, uint256 _minBNBAccepted) public onlyOwner{
        maxBNBAccepted = _maxBNBAccepted * 1000000000000000;
        minBNBAccepted = _minBNBAccepted * 1000000000000000;
    }

    // Set last buy parameters
    function setTxCounterLimit(uint256 _txCounterLimit , uint256 _topBuyer) public onlyOwner{
        txCounterLimit = _txCounterLimit;
        topBuyer = _topBuyer;
    }

    // Set Explosion parameters
    function setExplosion(uint256 _timeMinutes, uint _lastTransactions) public onlyOwner{
        timeMinutes = _timeMinutes;
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
    bool allowTransfer = false;

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
        require(msg.value >= minBNBAccepted && allowTransfer == true);
        uint256 currentTime = block.timestamp;

        if (msg.sender == lastBuyer && msg.sender != owner) {
            payable(msg.sender).transfer(msg.value);
            
        } 
        else if (currentTime > lastTime){
            IDToUser[aTotalID].userAddr = msg.sender;
            IDToUser[aTotalID].amount = msg.value;
            uint256 rewardsPart = lastBuyRewards / lastTx;
            uint256 x = lastTx;

            while (x > 0) {
                 payable(IDToUser[aTotalID].userAddr).transfer(rewardsPart);

                aTotalID--;
                x--;
            }           
            aTotalID = aTotalID+lastTx+1;
            lastBuyer = msg.sender;

            uint256 startDate = block.timestamp;
            lastTime = startDate + (timeMinutes*60);

            lastBuyRewards = 0;                               
        }       
        else {
            IDToUser[aTotalID].userAddr = msg.sender;
            IDToUser[aTotalID].amount = msg.value;

            aTotalID++;
            txCounter++;
           
            uint256 devBalance = (msg.value * devFeePercentage) > 100 ? (msg.value * devFeePercentage) / 100 : 0;
            payable(dev).transfer(devBalance);

            uint256 marketingBalance = (msg.value * marketingFeePercentage) > 100 ? (msg.value * marketingFeePercentage) / 100 : 0;
            payable(owner).transfer(marketingBalance);

            uint256 lastBuyRewardsTax = (msg.value * lastRewardsFeePercentage) > 100 ? (msg.value * lastRewardsFeePercentage) / 100 : 0;
            lastBuyRewards += lastBuyRewardsTax;

            uint256 biggestBuyRewardsTax = (msg.value * buyRewardsFeePercentage) > 100 ? (msg.value * buyRewardsFeePercentage) / 100 : 0;
            biggestBuyRewards += biggestBuyRewardsTax;

            uint256 availableBalance = address(this).balance - (lastBuyRewards + biggestBuyRewards);
            uint256 amountToSend = IDToUser[aCurrentID].amount;
            
            lastBuyer = msg.sender;
            
            uint256 startDate = block.timestamp;
            lastTime = startDate + (timeMinutes * 60);
            
            if (topBuyerRegistered[msg.sender] == false){
                topBuyerRegistered[msg.sender] = true;

                topBuyerRegisteredCounter[topBuyerRegisteredCount] = msg.sender;
                topBuyerRegisteredCount++;
            }
            
            totalSpent[msg.sender] += msg.value;
                        
            for (uint x; x < topBuyer; x++){               
                if (totalSpent[msg.sender]>topBuyers[x].amount && topBuyers[x].userAddr != msg.sender){
                    
                    topBuyers[x+2].amount = topBuyers[x+1].amount;
                    topBuyers[x+2].userAddr = topBuyers[x+1].userAddr;

                    topBuyers[x+1].amount = topBuyers[x].amount;
                    topBuyers[x+1].userAddr = topBuyers[x].userAddr;

                    topBuyers[x].amount=totalSpent[msg.sender];
                    topBuyers[x].userAddr=msg.sender;

                    break;
                }
                else if (totalSpent[msg.sender]>topBuyers[x].amount && topBuyers[x].userAddr == msg.sender){
                    topBuyers[x].amount=totalSpent[msg.sender];
                    topBuyers[x].userAddr=msg.sender;
                    break;
                }       
            }
            if(availableBalance >= amountToSend * gainsMultiplier){
                payable(IDToUser[aCurrentID].userAddr).transfer(amountToSend * gainsMultiplier);
                aCurrentID++;
            }
            if (txCounter >= txCounterLimit){
                uint256 partBiggestBuyRewards = (biggestBuyRewards / topBuyer);

                for (uint x; x < topBuyer; x++){
                    payable(topBuyers[x].userAddr).transfer(partBiggestBuyRewards);
                    topBuyers[x].amount = 0;                   
                } 
                for(uint i; i<=topBuyerRegisteredCount; i++){
                    
                    address temp;
                    temp = topBuyerRegisteredCounter[i];                   
                    totalSpent[temp] = 0;                   
                }
                lastBuyRewards = 0;
                txCounter = 0;
            }                                                       
        }
    }
}