/**

 DOA Based Smart Contract For (Decentralized Green Energy (GE)) Community

 What is a DAO in blockchain?
 what is a DAO? A decentralized autonomous organization is exactly what the name says; 
 a group of people who come together without a central leader or company dictating any of the 
 Decisions.They are built on a blockchain using smart contracts (digital one-of-one agreements)

*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8;

import "./MBCStakingUniversal.sol";

contract MBCStakingMain  is MBCStakingUniversal {

    function _Stake(uint _amount,uint256 _tierslab,address referrer) public updateReward(msg.sender,_tierslab) {
        UserStakingDetails storage usertier = userstakingdetails[msg.sender];
        UserOverallDetails storage useroverall = useraggregatedetails[msg.sender];
        //Manage Stake Holder & Staked Maticpad
        if(usertier.totalStakedAvailable[_tierslab]==0){
            totalNumberofStakers += 1;
            if(_tierslab==0)
            {
                totalTierOneStakers += 1;
            }
            else if(_tierslab==1)
            {
                totalTierTwoStakers += 1;
            }
            else if(_tierslab==2)
            {
                totalTierThreeStakers += 1;
            }
        }
        totalStakesGE +=_amount;
        uint256 _lockedAmount=(_amount*tierLocking[_tierslab])/(100);
        //Update User Stake Section Tier Wise
        usertier.totalStaked[_tierslab] +=_amount;
        usertier.totalUnLockedStaked[_tierslab] +=(_amount-_lockedAmount);
        usertier.totalLockedStaked[_tierslab] +=_lockedAmount;
        usertier.totalStakedAvailable[_tierslab] +=_amount;
        usertier.stakingStatus[_tierslab] =true;
        usertier.lastStakedUpdateTime[_tierslab] =block.timestamp;
        //Update User Section Aggregate
        useroverall.totalStaked +=_amount;
        useroverall.totalUnLockedStaked +=(_amount-_lockedAmount);
        useroverall.totalLockedStaked +=_lockedAmount;
        useroverall.totalStakedAvailable +=_amount;
        useroverall.lastStakedUpdateTime =block.timestamp;
        //Manage Referral Systeh Start Here
        require(_amount >= 1,'Minimum 1 MBC Can Be Staked !');
        UserAffiliateDetails storage useraffiliate = useraffiliatedetails[msg.sender];   
        useraffiliate.isIncomeBlocked=false;
        if (useraffiliate.referrer == address(0) && (useraffiliatedetails[referrer].checkpoint > 0 || referrer == contractOwner) && referrer != msg.sender ) {
            useraffiliate.referrer = referrer;
        }   
		
        require(useraffiliate.referrer != address(0) || msg.sender == contractOwner, "No upline");
       
        if (useraffiliate.referrer != address(0)) {	   
        // unilevel level count
        address upline = useraffiliate.referrer;
        for (uint i = 0; i < ref_bonuses.length; i++) {
            if (upline != address(0)) {
                useraffiliatedetails[upline].levelWiseBusiness[i] += _amount;
                useraffiliatedetails[upline].totalBusiness += _amount;
                if(useraffiliate.checkpoint == 0){
                    useraffiliatedetails[upline].refs[i] += 1;
					useraffiliatedetails[upline].totalReferrer++;
                }
                upline = useraffiliatedetails[upline].referrer;
            } else break;
        }
      }
      //Level Referral Income Distribution
	  _refPayout(msg.sender,_amount);
      if(useraffiliate.checkpoint == 0) {
        useraffiliate.checkpoint = block.timestamp;
        usertier.userId = block.timestamp;
	  }
      //Manage Referral System End Here
      nativetoken.transferFrom(msg.sender, address(this), _amount);
      emit Staking(msg.sender, _amount,_tierslab);
    }

    function _UnStakeUnlockedAmount(uint _amount,uint256 _tierslab) public updateReward(msg.sender,_tierslab) {
        UserStakingDetails storage usertier = userstakingdetails[msg.sender];
        UserOverallDetails storage useroverall = useraggregatedetails[msg.sender];
        require(_amount < usertier.totalUnLockedStaked[_tierslab],'Insufficient MBC For Unstake');
        //Get Penalty Percentage
        uint penaltyPer=getUnStakePenaltyPer(usertier.lastStakedUpdateTime[_tierslab],block.timestamp,_tierslab);
        //Get Penalty Amount
        uint256 penalty=_amount * penaltyPer / 100;
        //Update Penalty Collected
        usertier.penaltyCollected[_tierslab] +=penalty;
        useroverall.penaltyCollected +=penalty;
        //Update Unstake Section
        usertier.totalStakedAvailable[_tierslab] -= _amount;
        useroverall.totalStakedAvailable -= _amount;
        usertier.totalUnLockedStaked[_tierslab] -= _amount;
        useroverall.totalUnLockedStaked -= _amount;
        usertier.totalUnStaked[_tierslab] += _amount;
        useroverall.totalUnStaked += _amount;
        usertier.lastUnStakedUpdateTime[_tierslab] = block.timestamp;
        useroverall.lastUnStakedUpdateTime = block.timestamp;
        //Get Net Receivable Unstake Amount
        uint256 _payableamount=_amount-penalty;
        //Update Supply & Balance of UserStakingDetails
        if(usertier.totalStakedAvailable[_tierslab]==0){
            if(useroverall.totalStakedAvailable==0){
              totalNumberofStakers -= 1;
            }
            if(_tierslab==0)
            {
                totalTierOneStakers -= 1;
            }
            else if(_tierslab==1)
            {
                totalTierTwoStakers -= 1;
            }
            else if(_tierslab==2)
            {
                totalTierThreeStakers -= 1;
            }
        }
        totalStakesGE -=_amount;
        nativetoken.transfer(msg.sender, _payableamount);
        emit UnStakeUnlockedAmount(msg.sender, _payableamount,_tierslab);
    }

    function _UnStakeLockedAmount(uint256 _tierslab) public updateReward(msg.sender,_tierslab) {
        UserStakingDetails storage usertier = userstakingdetails[msg.sender];
        UserOverallDetails storage useroverall = useraggregatedetails[msg.sender];
        //Get Penalty Percentage
        uint penaltyPer=getUnStakePenaltyPer(usertier.lastStakedUpdateTime[_tierslab],block.timestamp,_tierslab);
        require(penaltyPer == 0 ,'Untill Your Tenure Will Not Complete You Can Not Withdraw Your Locked Amount');
        uint256 _amount=usertier.totalLockedStaked[_tierslab];
        //Get Penalty Amount
        uint256 penalty=_amount * penaltyPer / 100;
        //Update Penalty Collected
        usertier.penaltyCollected[_tierslab] +=penalty;
        useroverall.penaltyCollected +=penalty;
        //Update Unstake Section
        usertier.totalStakedAvailable[_tierslab] -= _amount;
        useroverall.totalStakedAvailable -= _amount;
        usertier.totalLockedStaked[_tierslab] -= _amount;
        useroverall.totalLockedStaked -= _amount;
        usertier.totalUnStaked[_tierslab] += _amount;
        useroverall.totalUnStaked += _amount;
        usertier.lastUnStakedUpdateTime[_tierslab] = block.timestamp;
        useroverall.lastUnStakedUpdateTime = block.timestamp;
        //Get Net Receivable Unstake Amount
        uint256 _payableamount=_amount-penalty;
        //Update Supply & Balance of UserStakingDetails
        if(usertier.totalStakedAvailable[_tierslab]==0){
            if(useroverall.totalStakedAvailable==0){
              totalNumberofStakers -= 1;
            }
            if(_tierslab==0)
            {
                totalTierOneStakers -= 1;
            }
            else if(_tierslab==1)
            {
                totalTierTwoStakers -= 1;
            }
            else if(_tierslab==2)
            {
                totalTierThreeStakers -= 1;
            }
        }
        totalStakesGE -=_amount;
        nativetoken.transfer(msg.sender, _payableamount);
        emit UnStakeLockedAmount(msg.sender, _payableamount,_tierslab);
    }

    function _RewardWithdrawal(uint256 _tierslab) public updateReward(msg.sender,_tierslab) {
        UserStakingDetails storage usertier = userstakingdetails[msg.sender];
        UserOverallDetails storage useroverall = useraggregatedetails[msg.sender];
        uint256 _reward = usertier.rewards[_tierslab];
        // Set Reward 0
        usertier.rewards[_tierslab] = 0;
        usertier.totalRewardWithdrawal[_tierslab] += _reward;
        // Reward Withdrawal Section
        useroverall.totalRewardWithdrawal += _reward;
        nativetoken.transfer(msg.sender, _reward);
        emit RewardWithdrawal(msg.sender, _reward,_tierslab);
    }   

    function _Withdrawal() public {  
      UserAffiliateDetails storage useraffiliate = useraffiliatedetails[msg.sender];
      uint256 dailyReleasePer = 100*1e18 / lockingDays*1e18;
      uint256 levelIncomeReleasable = ((useraffiliatedetails[msg.sender].creditedLevelBonus) * dailyReleasePer)/(100*1e18);
      levelIncomeReleasable /= 1e18;
      if(levelIncomeReleasable>useraffiliatedetails[msg.sender].availableLevelBonus)
      {
          levelIncomeReleasable=0;
      }
      (uint noofTotalSecond, uint noofHour, uint noofDay,uint noofYear) = view_DiffTwoDate(useraffiliate.checkpoint,block.timestamp);
      levelIncomeReleasable *= noofDay;
      uint256 TotalBonus = 0;
 //     TotalBonus += useraffiliate.availableJackpotBonus;
      TotalBonus += useraffiliate.availableAwardRewardBonus; 
      TotalBonus += levelIncomeReleasable;
      require(TotalBonus >= minimumWithdrawal,'No Minimum Withdrawal MBC !');
      uint256 _fees = (TotalBonus*adminCharge)/100;
      uint256 actualAmountToSend = (TotalBonus-_fees);
      useraffiliate.awardRewardBonusWithdrawn += useraffiliate.availableAwardRewardBonus;
      useraffiliate.availableAwardRewardBonus=0;
      //useraffiliate.jackpotBonusWithdrawn += useraffiliate.availableJackpotBonus;
      
      useraffiliate.levelBonusWithdrawn += levelIncomeReleasable;
      useraffiliate.availableLevelBonus -= levelIncomeReleasable;
      useraffiliate.checkpoint=block.timestamp;
      nativetoken.transfer(msg.sender, actualAmountToSend);  
      emit Withdrawn(msg.sender,actualAmountToSend);
    }
}