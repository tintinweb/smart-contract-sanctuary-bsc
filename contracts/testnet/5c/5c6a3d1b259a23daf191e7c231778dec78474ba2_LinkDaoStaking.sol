// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

import "../Ownable.sol";
import "../SafeMath.sol";
import "../SafeERC20.sol";

contract LinkDaoStaking is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    address public LINKDAO_TOKEN_ADDRESS;
    uint256 public MAX_STAKE = 10000 ether;
    uint256 public MAX_STAKE_PER_USER = 5000 ether;
    uint256 public MIN_STAKE = 1 ether;

    uint256 public REWARD_PERIOD = 3 minutes;

    uint256[] public RELEASE_INVESTMENT_DAYS = [
            18 minutes,
            21 minutes
        ];

    uint256[] public RELEASE_PERIODS = [
        0,0,0,0,0,4000,8000,8000,8000,8000,8000,8000,8000,8000,8000,8000,8000,8000
    ];
    uint256 public TOTAL_RELEASE_DAYS = 54 minutes;

    uint256 public ROI_PERCENTAGE = 2000; // 2%
    uint256 public TOTAL_PERCENTAGE = 100000;
    uint256 public MAX_REWARD_PERCENTAGE = 24480;

    uint256 public totalInvestments;
    uint256 public totalInvestors;
    uint256 public totalReward;

    uint256 public currentID;


    struct Investor{
        address investor;
        uint256 totalInvestment;
        uint256 activeAmount;
        uint256 totalReward;
        uint256 startDate;
        uint256[] userInvestments;
    }

    struct Investment{
        address investor;
        uint256 totalAmount;
        uint256 totalReward;
        uint256 activeAmount;
        uint256 claimedAmount;
        uint256 startDate;
        uint256 lastCheckpoint;
        uint256 endDate;
        uint256 maxReward;
    }

    mapping(address=>uint256) public blackList;
    mapping(address=>Investor) public investors;
    mapping(uint256=>Investment) public investments;

    constructor(address _linkDaoToken) {
        require(_linkDaoToken!=address(0),"Invalid LinkDao token address");

        LINKDAO_TOKEN_ADDRESS = _linkDaoToken;
    }

    function setLinkDaoToken(address _linkDaoToken) external onlyOwner{
        require(_linkDaoToken!=address(0),"Invalid LinkDao token address");

        LINKDAO_TOKEN_ADDRESS = _linkDaoToken;
    }

    function addToBlackList(address _investorAddress) external onlyOwner{
        blackList[_investorAddress] = 1;
    }
    
    function removeFromBlackList(address _investorAddress) external onlyOwner{
        blackList[_investorAddress] = 0;
    }

    function investAmountForOwner(address investorAddress,uint256 _amount) external onlyOwner{
        require(investorAddress!=address(0),"Invalid investor address");
        require(blackList[investorAddress] == 0,"Investor address is black listed");
        require(_amount>=MIN_STAKE,"Cannot stake less than 1 LKD");
        require(totalInvestments.add(_amount)<=MAX_STAKE,"Cannot stake more than 100,000 LKD");
        require(investors[investorAddress].totalInvestment.add(_amount)<=MAX_STAKE_PER_USER,"Cannot stake more than 100,000 LKD");
        
        currentID = currentID.add(1);

        investments[currentID] = Investment({
            investor:investorAddress,
            totalAmount:_amount,
            totalReward:0,
            activeAmount:_amount,
            claimedAmount:0,
            startDate:block.timestamp,
            lastCheckpoint:block.timestamp,
            endDate:block.timestamp.add(TOTAL_RELEASE_DAYS),
            maxReward:_amount.mul(MAX_REWARD_PERCENTAGE).div(TOTAL_PERCENTAGE)
        });

        IERC20(LINKDAO_TOKEN_ADDRESS).safeTransferFrom(msg.sender,address(this),_amount);

        if(investors[investorAddress].investor==address(0)){
            investors[investorAddress].investor = investorAddress;
            investors[investorAddress].startDate = block.timestamp;
            totalInvestors = totalInvestors.add(1);
        }

        investors[investorAddress].totalInvestment = investors[investorAddress].totalInvestment.add(_amount);
        investors[investorAddress].activeAmount = investors[investorAddress].activeAmount.add(_amount);
        investors[investorAddress].userInvestments.push(currentID);
        
        totalInvestments = totalInvestments.add(_amount);
    }
    
    function investAmount(uint256 _amount) external{
        require(_amount>=MIN_STAKE,"Cannot stake less than 1 LKD");
        require(blackList[msg.sender] == 0,"Investor address is black listed");
        require(totalInvestments.add(_amount)<=MAX_STAKE,"Cannot stake more than 100,000 LKD");
        require(investors[msg.sender].totalInvestment.add(_amount)<=MAX_STAKE_PER_USER,"Cannot stake more than 100,000 LKD");
        
        currentID = currentID.add(1);

        investments[currentID] = Investment({
            investor:msg.sender,
            totalAmount:_amount,
            totalReward:0,
            activeAmount:_amount,
            claimedAmount:0,
            startDate:block.timestamp,
            lastCheckpoint:block.timestamp,
            endDate:block.timestamp.add(TOTAL_RELEASE_DAYS),
            maxReward:_amount.mul(MAX_REWARD_PERCENTAGE).div(TOTAL_PERCENTAGE)
        });

        IERC20(LINKDAO_TOKEN_ADDRESS).safeTransferFrom(msg.sender,address(this),_amount);

        if(investors[msg.sender].investor==address(0)){
            investors[msg.sender].investor = msg.sender;
            investors[msg.sender].startDate = block.timestamp;
            totalInvestors = totalInvestors.add(1);
        }

        investors[msg.sender].totalInvestment = investors[msg.sender].totalInvestment.add(_amount);
        investors[msg.sender].activeAmount = investors[msg.sender].activeAmount.add(_amount);
        investors[msg.sender].userInvestments.push(currentID);
        
        totalInvestments = totalInvestments.add(_amount);
    }

    function getTotalProfit(address _investorAddress) public view returns(uint256 totalProfit) {
        for(uint256 i=0;i<investors[_investorAddress].userInvestments.length;i++){
            totalProfit = totalProfit.add(getTotalProfitForInvestment(
                investors[_investorAddress].userInvestments[i]
            ));
        }
    }

    function getWithdrawableTotalProfit(address _investorAddress) public view returns(uint256 totalProfit) {
        for(uint256 i=0;i<investors[_investorAddress].userInvestments.length;i++){
            (uint256 currentProfit,) = getWithdrawableTotalProfitForInvestment(
                investors[_investorAddress].userInvestments[i]
            );
            totalProfit = totalProfit.add(currentProfit);
        }
    }

    function getTotalProfitForInvestment(uint256 _investmentID) public view returns(uint256 totalProfit){
        uint256 activeAmount =  investments[_investmentID].activeAmount;

        if(activeAmount==0){
            return totalProfit;
        }

        uint256 currentTime = 
            block.timestamp < investments[_investmentID].endDate ? block.timestamp : investments[_investmentID].endDate;


        uint256 timePeriod = currentTime - investments[_investmentID].lastCheckpoint;

        totalProfit = activeAmount.mul(ROI_PERCENTAGE).mul(timePeriod).div(REWARD_PERIOD.mul(TOTAL_PERCENTAGE));

        if(investments[_investmentID].totalReward.add(totalProfit)>investments[_investmentID].maxReward){
            totalProfit = investments[_investmentID].maxReward.sub(investments[_investmentID].totalReward);
        }

        uint256 releaseStartIndex = (investments[_investmentID].lastCheckpoint.sub(investments[_investmentID].startDate)).div(REWARD_PERIOD);
        uint256 releaseEndIndex = (currentTime.sub(investments[_investmentID].startDate)).div(REWARD_PERIOD);

        for(uint256 i = releaseStartIndex; i<releaseEndIndex;i++){
            if(RELEASE_PERIODS[i]>0){
                uint256 releaseAmount = investments[_investmentID].totalAmount.mul(RELEASE_PERIODS[i]).div(TOTAL_PERCENTAGE);

                totalProfit = totalProfit.add(releaseAmount);
            }
        }
    }

    function getWithdrawableTotalProfitForInvestment(uint256 _investmentID) public view returns(uint256 totalProfit,uint256 amountToRelease){
        uint256 activeAmount =  investments[_investmentID].activeAmount;

        if(activeAmount==0){
            return (totalProfit,amountToRelease);
        }

        uint256 currentTime = 
            block.timestamp < investments[_investmentID].endDate ? block.timestamp : investments[_investmentID].endDate;


        uint256 timePeriod = currentTime - investments[_investmentID].lastCheckpoint;

        totalProfit = activeAmount.mul(ROI_PERCENTAGE).mul(timePeriod.div(REWARD_PERIOD)).div(TOTAL_PERCENTAGE);

        if(investments[_investmentID].totalReward.add(totalProfit)>investments[_investmentID].maxReward){
            totalProfit = investments[_investmentID].maxReward.sub(investments[_investmentID].totalReward);
        }

        uint256 releaseStartIndex = (investments[_investmentID].lastCheckpoint.sub(investments[_investmentID].startDate)).div(REWARD_PERIOD);
        uint256 releaseEndIndex = (currentTime.sub(investments[_investmentID].startDate)).div(REWARD_PERIOD);

        for(uint256 i = releaseStartIndex; i<releaseEndIndex;i++){
            if(RELEASE_PERIODS[i]>0){
                uint256 releaseAmount = investments[_investmentID].totalAmount.mul(RELEASE_PERIODS[i]).div(TOTAL_PERCENTAGE);

                totalProfit = totalProfit.add(releaseAmount);
                amountToRelease = amountToRelease.add(releaseAmount);
            }
        }
    }

    function getLkdBalance() public view returns(uint256 balance){
        balance = IERC20(LINKDAO_TOKEN_ADDRESS).balanceOf(address(this));
    }

    function withdrawReward() external {
        require(blackList[msg.sender] == 0,"Investor address is black listed");
        uint256 totalRewardToRelease;
        for(uint256 i = 0;i<investors[msg.sender].userInvestments.length;i++){
            uint256 _investmentID = investors[msg.sender].userInvestments[i];

            (uint256 currentInvestmentProfit,uint256 releaseAmount) = getWithdrawableTotalProfitForInvestment(_investmentID);

            totalRewardToRelease = totalRewardToRelease.add(currentInvestmentProfit);

            investments[_investmentID].totalReward = investments[_investmentID].totalReward.add(currentInvestmentProfit.sub(releaseAmount));
            investments[_investmentID].claimedAmount = investments[_investmentID].claimedAmount.add(currentInvestmentProfit);
            
            investments[_investmentID].activeAmount = investments[_investmentID].activeAmount.sub(releaseAmount);
    
            investors[msg.sender].activeAmount = investors[msg.sender].activeAmount.sub(releaseAmount);

            investments[_investmentID].lastCheckpoint = block.timestamp;
        }
        require(totalRewardToRelease>0,"No withdrawable reward yet");
        
        IERC20(LINKDAO_TOKEN_ADDRESS).safeTransfer(msg.sender,totalRewardToRelease);

        investors[msg.sender].totalReward = investors[msg.sender].totalReward.add(totalRewardToRelease);

        totalReward = totalReward.add(totalRewardToRelease);
    }

    function withdrawSingleReward(uint256 _investmentID) external {
        require(blackList[msg.sender] == 0,"Investor address is black listed");
        require(investments[_investmentID].investor==msg.sender,"Only investor can claim the reward");

        uint256 totalRewardToRelease;

        (uint256 currentInvestmentProfit,uint256 releaseAmount) = getWithdrawableTotalProfitForInvestment(_investmentID);

        totalRewardToRelease = totalRewardToRelease.add(currentInvestmentProfit);

        investments[_investmentID].totalReward = investments[_investmentID].totalReward.add(currentInvestmentProfit.sub(releaseAmount));
        investments[_investmentID].claimedAmount = investments[_investmentID].claimedAmount.add(currentInvestmentProfit);
        
        investments[_investmentID].activeAmount = investments[_investmentID].activeAmount.sub(releaseAmount);
        investors[msg.sender].activeAmount = investors[msg.sender].activeAmount.sub(releaseAmount);

        investments[_investmentID].lastCheckpoint = block.timestamp;

        IERC20(LINKDAO_TOKEN_ADDRESS).safeTransfer(msg.sender,totalRewardToRelease);

        investors[msg.sender].totalReward = investors[msg.sender].totalReward.add(totalRewardToRelease);
        
        totalReward = totalReward.add(totalRewardToRelease);
    }

    function depositLKD(uint256 _amount) external onlyOwner{
        IERC20(LINKDAO_TOKEN_ADDRESS).safeTransferFrom(msg.sender,address(this),_amount);
    }

    function withdrawLKD(uint256 _amount) external onlyOwner{
        IERC20(LINKDAO_TOKEN_ADDRESS).safeTransfer(msg.sender,_amount);
    }
}