/**
 *Submitted for verification at BscScan.com on 2022-12-06
*/

// SPDX-License-Identifier: GPL-3.0 
    //0x429048c80789578DDF1Da71d1Ddd218b61d1c5Cd


    pragma solidity >=0.7.0 <0.9.0;

    contract test 
    {

        struct cycleInfo
            {
            uint256 cycleStart;
            uint256 cycleEnd;
            uint256 cycleTotalProduct;
            uint256 botRewards;
            }
        struct stakeInfo
            {
            uint256 stakeStartCycle;
            uint256 stakeStartTime;
            uint256 amount;
            }
        struct userInCycleInfo
            {
            uint256 Product;
            uint256 Staked;
            uint256 opStake;
            uint256 opUnstake;
            uint256 SubRoutineStart;
            uint256 SubRoutineEnd;
            bool    midCycleOps;
            }

        mapping(address => mapping(uint256 => userInCycleInfo)) public userProductInSpecdCycle;
        mapping(uint256 => cycleInfo) public CycleInfoForSpecdCycle;
        mapping(address => stakeInfo) public stakePerUser; 
        mapping(address => uint256)   public userTotalStaked;
        mapping(address => uint256)   public userClaimedRewards; 

        uint256 public cCycle;
        uint256 public currentTime;
        uint256        subRoutineStart;
        uint256        subRoutineEnd;
        uint256 public totalStaked;


        constructor()
            {
            currentTime = block.timestamp;
            cCycle = 0;
            subRoutineStart = currentTime;
            CycleInfoForSpecdCycle[cCycle].cycleStart = currentTime;
            }

        function Add(uint256 _amount)
            public
            payable
                {
                currentTime = block.timestamp;
                stakeInfo storage user = stakePerUser[msg.sender];
                user.stakeStartTime = currentTime;
                if (user.stakeStartTime == 0) user.stakeStartCycle = cCycle;
                // user.amount = user.amount + _amount;           

                subRoutineEnd = currentTime;
                uint256 subRoutineLength = subRoutineEnd - subRoutineStart;
                CycleInfoForSpecdCycle[cCycle].cycleTotalProduct = CycleInfoForSpecdCycle[cCycle].cycleTotalProduct + totalStaked * subRoutineLength;
                
                subRoutineStart = subRoutineEnd;
                totalStaked = totalStaked + _amount;
                
                userInCycleInfo storage userInCurrentCycle = userProductInSpecdCycle[msg.sender][cCycle];
                userInCurrentCycle.midCycleOps = true;
                userInCurrentCycle.SubRoutineEnd = currentTime;
                if(userInCurrentCycle.SubRoutineStart == 0) userInCurrentCycle.SubRoutineStart = CycleInfoForSpecdCycle[cCycle].cycleStart;
              
                uint256 userSubRoutineLength = userInCurrentCycle.SubRoutineEnd - userInCurrentCycle.SubRoutineStart;
                // userInCurrentCycle.Staked = userTotalStaked[msg.sender];
                userInCurrentCycle.Product = userInCurrentCycle.Product + userTotalStaked[msg.sender] * userSubRoutineLength;
                userInCurrentCycle.SubRoutineStart = userInCurrentCycle.SubRoutineEnd;
                userInCurrentCycle.Staked = userInCurrentCycle.Staked + _amount;
                userInCurrentCycle.opStake = userInCurrentCycle.opStake + _amount;
                userTotalStaked[msg.sender] = userTotalStaked[msg.sender] + _amount;

                }

       function withdraw(uint256 _amount)
            public
            payable
                {
                require(_amount <= userTotalStaked[msg.sender] , "You cannot withdraw more than you have");
                subRoutineEnd = block.timestamp;
                uint256 subRoutineLength = subRoutineEnd - subRoutineStart;
                CycleInfoForSpecdCycle[cCycle].cycleTotalProduct = CycleInfoForSpecdCycle[cCycle].cycleTotalProduct + totalStaked * subRoutineLength;

                subRoutineStart = subRoutineEnd;
                totalStaked = totalStaked - _amount;

                userInCycleInfo storage userInCurrentCycle = userProductInSpecdCycle[msg.sender][cCycle];
                userInCurrentCycle.midCycleOps = true;
                userInCurrentCycle.SubRoutineEnd = subRoutineEnd;
                if(userInCurrentCycle.SubRoutineStart == 0) userInCurrentCycle.SubRoutineStart = CycleInfoForSpecdCycle[cCycle].cycleStart;
                uint256 userSubRoutineLength = userInCurrentCycle.SubRoutineEnd - userInCurrentCycle.SubRoutineStart;
                userInCurrentCycle.Staked = userTotalStaked[msg.sender];
                userInCurrentCycle.Product = userInCurrentCycle.Product + userInCurrentCycle.Staked * userSubRoutineLength;
                userInCurrentCycle.SubRoutineStart = userInCurrentCycle.SubRoutineEnd;
                userInCurrentCycle.Staked = userInCurrentCycle.Staked - _amount;
                userInCurrentCycle.opUnstake = _amount;
                userTotalStaked[msg.sender] = userTotalStaked[msg.sender] - _amount;
                
                }

        function claimRewards(uint256 _amountRewards)
            public
                {
                require(_amountRewards <= accruedRewardsPerUser() - userClaimedRewards[msg.sender], "You don't have enough accrued rewards");
                userClaimedRewards[msg.sender] = userClaimedRewards[msg.sender] + _amountRewards;
                }
        
        function userLeftToClaim()
            public
            view
            returns(uint256)
                {
                return accruedRewardsPerUser() - userClaimedRewards[msg.sender];
                }

        function newCycle(uint256 _botRewards)
            public
                {
                cycleInfo storage cycle = CycleInfoForSpecdCycle[cCycle];
                cycle.cycleEnd = block.timestamp;
                cycle.botRewards = _botRewards;

                            
                subRoutineEnd = cycle.cycleEnd;
                uint256 subRoutineLength = subRoutineEnd - subRoutineStart;
                cycle.cycleTotalProduct = cycle.cycleTotalProduct + totalStaked * subRoutineLength; 

                subRoutineStart = subRoutineEnd;

                cCycle +=1;
                addCycle(subRoutineStart);

                }

        function addCycle(uint256 _addTime)
            internal
                {
                CycleInfoForSpecdCycle[cCycle].cycleStart = _addTime;
                currentTime = _addTime;
                }


        function accruedRewardsPerUser()
            public
            view
            returns(uint256)
                {
                uint256 i = stakePerUser[msg.sender].stakeStartCycle;
                uint256 accrued;
                uint256 ASB;
                for(i; i<cCycle; i++)
                    {
                    userInCycleInfo memory user = userProductInSpecdCycle[msg.sender][i];
                    ASB = ASB + user.opStake - user.opUnstake;
                    uint256 whichMethod;
                    if(user.midCycleOps == false && ASB == 0) whichMethod = 0;
                    if(user.midCycleOps == true) whichMethod = 1;
                    if(user.midCycleOps == false && ASB > 0) whichMethod = 2;


                    // uint256 userProduct = calculateUserProductInSpecdCycle(i,whichMethod, ASB);
                    // uint256 userRatio = calculateUserRatioInSpecdCycle(i, userProduct);
                    // accrued = accrued + rewards(userRatio, CycleInfoForSpecdCycle[i].botRewards);    
                    accrued = accrued + rewards(calculateUserRatioInSpecdCycle(i, calculateUserProductInSpecdCycle(i,whichMethod, ASB)) ,CycleInfoForSpecdCycle[i].botRewards);                 

                    }
                return accrued;     
                }        

        function calculateUserProductInSpecdCycle(uint256 _cycle, uint256 _whichMethod, uint256 _ASB)
            public
            view
            returns(uint256)
                {
                            
                uint256 userProduct;
                userInCycleInfo memory userInCurrentCycle = userProductInSpecdCycle[msg.sender][_cycle];
                
                if (_whichMethod == 0)
                    {
                    userProduct = 0;
                    }
                    else if (_whichMethod == 1)
                            {
                            uint256 cycleLength = CycleInfoForSpecdCycle[_cycle].cycleEnd - userInCurrentCycle.SubRoutineStart;
                            userProduct = userInCurrentCycle.Product + _ASB * cycleLength;
                            }
                            else if (_whichMethod == 2)
                                {
                                uint256 cycleLength = CycleInfoForSpecdCycle[_cycle].cycleEnd - CycleInfoForSpecdCycle[_cycle].cycleStart;
                                userProduct = _ASB * cycleLength;
                                }
                        
                return userProduct;
                }
        
        function calculateUserRatioInSpecdCycle(uint256 _cycle, uint256 _product)
            public
            view
            returns(uint256)
                {
                if(_product != 0 && CycleInfoForSpecdCycle[_cycle].cycleTotalProduct !=0)
                    {
                    return _product * 1000000 / CycleInfoForSpecdCycle[_cycle].cycleTotalProduct;
                    }
                    else return 0;
                }     

        function rewards(uint256 _ratio, uint256 _botRewards)
            public
            pure
            returns(uint256)
                {
                if (_ratio != 0) return _ratio * _botRewards / 1000000;
                else return 0;
                }

    }