/**
 *Submitted for verification at BscScan.com on 2022-09-16
*/

// SPDX-License-Identifier: MIT

//    //   / /                                 //   ) )
//   //____     ___      ___                  //___/ /  //  ___      ___     / ___
//  / ____    //   ) ) ((   ) ) //   / /     / __  (   // //   ) ) //   ) ) //\ \
// //        //   / /   \ \    ((___/ /     //    ) ) // //   / / //       //  \ \
////____/ / ((___( ( //   ) )      / /     //____/ / // ((___/ / ((____   //    \ \
// Developed by Dogu Deniz UGUR (https://github.com/DoguD)

pragma solidity ^0.8.0;

interface EasyBlock {
    function isAutoCompounding(address _address) external view returns (bool);
    function holders(uint256 _index) external view returns (address);
    function shareCount(address _address) external view returns (uint256);
    function holderCount() external view returns(uint32);
    function totalShareCount() external view returns(uint256);
}

contract EasyBlockDistributionAnalysis {
    EasyBlock easyBlockContract = EasyBlock(0x827674a42694ce061d594C091B3278173e57feA8); // Contract address of EB Horde

    function getAutoCompoundingShareCount() public view returns(uint256) {
        uint autoCompoundingShareCount = 0;
        uint32 holderCount = easyBlockContract.holderCount();
        for(uint i; i<holderCount; i++) {
            if(easyBlockContract.isAutoCompounding(easyBlockContract.holders(i))) {
                autoCompoundingShareCount += easyBlockContract.shareCount(easyBlockContract.holders(i));
            }
        }
        return autoCompoundingShareCount;
    }

    function getNeededCapital(uint256 rewardAmount, uint256 premiumAmount) public view returns(uint256, uint256, uint256, uint256) { // Reward amount in USD
        rewardAmount = rewardAmount * 10**18 * 2 / 3; // BUSD has 18 decimals & 33% is automatically reinvested
        premiumAmount = premiumAmount * 10 ** 18;
        uint256 totalShares = easyBlockContract.totalShareCount();
        uint256 autoShares = getAutoCompoundingShareCount();

        uint256 totalReward = rewardAmount + premiumAmount;
        uint256 ebFee = totalReward / 10;
        uint256 toBeDistributed = totalReward - ebFee;
        uint256 notAutocompoundingRewardAmount = toBeDistributed * (totalShares-autoShares) / totalShares;
        uint256 ebFeeAuto = (toBeDistributed - notAutocompoundingRewardAmount) / 10;

        uint256 total = notAutocompoundingRewardAmount + ebFee + ebFeeAuto;
        return (notAutocompoundingRewardAmount, ebFee, ebFeeAuto, total);
    }
}