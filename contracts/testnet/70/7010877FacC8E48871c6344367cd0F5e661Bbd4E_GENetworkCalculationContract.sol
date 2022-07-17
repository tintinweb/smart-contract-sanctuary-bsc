//SPDX-License-Identifier: MIT

pragma solidity ^0.8;

import "./GEInitialize.sol";

contract GENetworkCalculationContract is GEInitializeContract {

    function _refPayout(address _addr, uint256 _amount) internal {
		address up = useraffiliatedetails[_addr].referrer;
        for(uint8 i = 0; i < ref_bonuses.length; i++) {
            if(up == address(0)) break;
            if(useraffiliatedetails[up].refs[0] >= requiredDirect[i]){ 
    		    uint256 bonus = (_amount * ref_bonuses[i] ) / 100;
                if(!useraffiliatedetails[_addr].isIncomeBlocked)
                {
                  useraffiliatedetails[up].creditedLevelBonus += bonus;
                  totalLevelIncome += bonus;
                  useraffiliatedetails[up].availableLevelBonus += bonus;
                  useraffiliatedetails[up].levelWiseBonus[i] += bonus;
                }
                if(i==0)
                {
                  _jackpotPayout(_addr, bonus);
                }
            }
            _rewardPayout(up);
            up = useraffiliatedetails[up].referrer;
      }
   }

   function _jackpotPayout(address _addr, uint256 _amount) internal {
		address up = useraffiliatedetails[_addr].referrer;
        for(uint8 i = 0; i < jackpot_bonuses.length; i++) {
            if(up == address(0)) break;
    		    uint256 bonus = (_amount * jackpot_bonuses[i] ) / 100;
                if(!useraffiliatedetails[_addr].isIncomeBlocked)
                {
                  useraffiliatedetails[up].availableJackpotBonus += bonus;
                  totalJackportIncome += bonus;
                  useraffiliatedetails[up].levelWiseBonus[i] += bonus;
                }           
            up = useraffiliatedetails[up].referrer;
      }
   }

   function _rewardupdation(address _addr,uint _index) internal{
       UserAffiliateDetails storage useraffiliate = useraffiliatedetails[_addr];
       UserRewardDetails storage userreward = userrewarddetails[_addr];
       if(useraffiliate.totalBusiness>=requiredBusiness[_index]){
            if(useraffiliate.totalReferrer>=requiredNoofId[_index]){
                uint NoofId=0;
                for(uint8 j = 0; j < requiredLevel[_index]; j++) {
                    NoofId += useraffiliate.refs[j];
                }
                if(NoofId>=requiredNoofId[_index]){
                    totalAwardAndReward += reward[_index];
                    useraffiliate.availableAwardRewardBonus += reward[_index];
                    if(_index==0){
                      userreward.tierfirstreceived=true;
                    }
                    else if(_index==1){
                      userreward.tiersecondreceived=true;
                    }
                    else if(_index==2){
                      userreward.tierthirdreceived=true;
                    }
                    else if(_index==3){
                      userreward.tierfourthreceived=true;
                    }
                    else if(_index==4){
                      userreward.tierfifthreceived=true;
                    }
                }
            }
        }
   }

   function _rewardPayout(address _addr) internal {
        UserRewardDetails storage userreward = userrewarddetails[_addr];
        if(userreward.tierfirstreceived==false){
             _rewardupdation(_addr,0);
        }
        if(userreward.tiersecondreceived==false){
            _rewardupdation(_addr,1);
        }
        if(userreward.tierthirdreceived==false){
            _rewardupdation(_addr,2);
        }
        if(userreward.tierfourthreceived==false){
            _rewardupdation(_addr,3);
        }
        if(userreward.tierfifthreceived==false){
             _rewardupdation(_addr,4);
        }
   }
}