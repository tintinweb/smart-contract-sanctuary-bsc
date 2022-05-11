// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;
import "./SafeMath.sol";
import "./IBEP20.sol";

library QubeLaunchPadLib{
    using SafeMath for uint256;
    struct dataStore{
        IBEP20 saleToken;
        IBEP20 quoteToken;
        uint256 currentTier;
        uint256 normalSaleStartTier;
        uint256 totalSaleAmountIn;
        uint256 totalSaleAmountOut;
        uint256[] startTime;
        uint256[] endTime;
        uint256[] salePrice;
        uint256[] quotePrice;
        uint256[] saleAmountIn;
        uint256[] saleAmountOut;        
        uint256[] minimumRequire;
        uint256[] maximumRequire;
        uint256 minimumEligibleQuoteForTx;
        uint256[] minimumEligibleQubeForTx;
        bool tierStatus;
        bool signOff;
        bool delegateState;
    }

    struct vestingStore{
        uint256[] vestingMonths;
        uint256[] instantRoi;
        uint256[] installmentRoi;     
        uint256[] distributeROI;
        bool isLockEnabled;
    }

    struct userData {
        address userAddress;
        IBEP20 saleToken;
        uint256 idoID;
        uint256 lockedAmount;
        uint256 releasedAmount;
        uint256 lockedDuration;
        uint256 lastClaimed;
        uint256 unlockCount;
        uint256 installmentMonths;
        uint256 distributeROI;        
    }
    struct inputStore{
        IBEP20 saleToken;
        IBEP20 quoteToken;
        uint256[] startTime;
        uint256[] endTime;
        uint256[] salePrice;
        uint256[] quotePrice;
        uint256[] saleAmountIn;
        uint256[] vestingMonths;
        uint256[] instantRoi;
        uint256[] installmentRoi;
        uint256[] minimumRequire;//Minimum requirement per tier
        uint256[] maximumRequire;//Maximum allowed per tier
        uint256 minimumEligibleQuoteForTx;
        uint256[] minimumEligibleQubeForTx;//Qube stake requirement for each tier
        bool isLockEnabled;
        bool delegateState;
    }
    function getPrice(uint256 salePrice,uint256 quotePrice,uint256 decimal) public pure returns (uint256) {
       return (10 ** decimal) * salePrice / quotePrice;
    }

    function vestingDetails(vestingStore memory vestingStoreId) public pure returns (vestingStore memory) {
        vestingStore memory vesting = vestingStoreId;
        for(uint256 i; i<vesting.vestingMonths.length; i++){
            vesting.distributeROI[i] = uint256(1e4).div(vesting.vestingMonths[i]);
        }
        return (vesting);
    }

    function reserveDetails(dataStore memory vestingStoreId) public view returns (dataStore memory) {
        dataStore memory vars = vestingStoreId;

        while(vars.endTime[vars.currentTier] < block.timestamp && !vars.tierStatus){
            if(vars.currentTier != vars.startTime.length) {
                vars.currentTier++;
                
                if(vars.startTime[vars.normalSaleStartTier + 1] <= block.timestamp){
                    vars.tierStatus = true;
                    vars.currentTier = vars.normalSaleStartTier + 1;
                } 
            }
            
            if(!vars.signOff && vars.endTime[vars.normalSaleStartTier] <= block.timestamp) {
                vars.signOff = true;
            }
        }
        for(uint256 i=0;i<=vars.currentTier;i++){
            if(i != 0){
                vars.saleAmountIn[i] = vars.saleAmountIn[i].add(vars.saleAmountIn[i-1].sub(vars.saleAmountOut[i-1]));
                vars.saleAmountOut[i-1] = vars.saleAmountIn[i-1];
            }
        }
        return vars;
    }

    function getTokenOut(dataStore memory vestingStoreId,uint256 amount) public view returns (uint256){
        QubeLaunchPadLib.dataStore memory vars = vestingStoreId; 

        while(vars.endTime[vars.currentTier] < block.timestamp && !vars.tierStatus){
            if(vars.currentTier != vars.startTime.length) {
                vars.currentTier++;                
                if(vars.startTime[vars.normalSaleStartTier + 1] <= block.timestamp){
                    vars.tierStatus = true;
                    vars.currentTier = vars.normalSaleStartTier + 1;
                }
            }
        }
        
        if(!(vars.startTime[vars.currentTier] <= block.timestamp && vars.endTime[vars.currentTier] >= block.timestamp && amount >= vars.minimumRequire[vars.currentTier] && amount <= vars.maximumRequire[vars.currentTier])){
            return 0;
        }
        
        if(address(vars.quoteToken) == address(0)){
            return amount.mul(getPrice(vars.salePrice[vars.currentTier],vars.quotePrice[vars.currentTier],18)).div(1e18);
        }
        
        if(address(vars.quoteToken) != address(0)){
            uint256 decimal = vars.quoteToken.decimals();
            return amount.mul(getPrice(vars.salePrice[vars.currentTier],vars.quotePrice[vars.currentTier],decimal)).div(10 ** decimal);
        } else{
            return 0;
        }
    }

    function minimumPurchaseAmount(dataStore storage vestingStoreId, uint256 tierID) public view returns (uint256){
        dataStore storage vars = vestingStoreId;
        return vars.minimumRequire[tierID];
    }
    function maximumPurchaseAmount(dataStore storage vestingStoreId, uint256 tierID) public view returns (uint256){
        QubeLaunchPadLib.dataStore storage vars = vestingStoreId;
        return vars.maximumRequire[tierID];
    }
    
}