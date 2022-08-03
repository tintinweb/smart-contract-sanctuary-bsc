// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

import "./SafeMath.sol";
import "./owned.sol";
import "./SafeMathInt.sol";
import "./UInt256Lib.sol";
import "./RebaseToken.sol";
import "./IOracle.sol";
import "./IMasonaryContract.sol";

contract RebasePolicy is owned {
    using SafeMath for uint256;
    using UInt256Lib for uint256;
    using  SafeMathInt for int256;

    event LogRebase(
        uint256 indexed epoch,
        uint256 exchangeRate,
        int256 requestedSupplyAdjustment,
        uint256 timestampSec
    );
    uint256 public baseprice;

    RebaseToken public rtokens;
    // address public masonaryAddress;

    // Market oracle provides the token/USD exchange rate as an 18 decimal fixed point number.
    // (eg) An oracle value of 1.5e18 it would mean 1 Rebase is trading for $1.50.
    IOracle public marketOracle;
    IMasonaryContract public masonaryAddress;
    // Block timestamp of last rebase operation
    uint256 public lastRebaseTimestampSec;

     // The number of rebase cycles since inception
    uint256 public rebasecycles;
       // The numbers of epochs in a cycle as rebase should happen after every 6 epochs
    //uint256 private blockcounter; // counter will reset to 0 at the time of rebase or if the token price becomes higher than pegged price in a epoch.
    uint256 public lastblockNum; // epoch of last rebase
    uint256 public epochsize; // number of blocks per epoch
    uint8 public rebaseafterepochcycles; // number of cycles below pegg for rebase to happen
    uint256 public epochStartTime;
    uint256 public epochCount;
    uint8 public rebasecyclecount; // Count to check how many blocks below pegg are gone.
    uint8 public countbelowpeg=0; // count how many cyclees below peg are there in one epoch range 
    uint256 public thisepochstartblock; // To check how on which block this epoch started. 
    uint256 private countCycle =0;
    bool private shouldRebase = true;
    uint256 public minimumPriceThreshhold = 80 ; // Percentage , if the price is below this threshhold for a complete epoch then rebase will happen irrespective of other conditions 

    bool[] private isbelowMinimumPrice; // this is to check if the price was below the pegged price of counter for complete epoch or no. 
   //uint16 private callcount=0;

    bool[] private blockbelowpegg;
    bool[] private nullarray;// to reset the isbelowMinimumprice array. Avoid using for loop;

    uint256 private constant DECIMALS = 18;

    // We will not be using mills other than that we will say it 1/million which is 1/1000000
    // rebasecyclecount is uint8 variable to set number of cycles price need to be below pegged price for rebase operation 
    constructor (uint256 numberofblockspercycle , address _masonaryAddress){
        baseprice = 1*10**18;
        lastblockNum=0;//block.number;
        epochsize= numberofblockspercycle;
        masonaryAddress =IMasonaryContract(_masonaryAddress);
        rebaseafterepochcycles=0;
        rebasecyclecount=0;
        epochCount = 0;
        thisepochstartblock=0;
        epochStartTime = block.timestamp;
    }

    function SetRebaseTokanAddress(address tokenaddress) public onlyOwner{
        rtokens = RebaseToken(tokenaddress);
    }
    function SetEpochCount(uint256 count)public onlyOwner{
        epochCount = count;
    }
    function SetMasonaryAddress(address masonary) public onlyOwner{
        masonaryAddress = IMasonaryContract(masonary);
    }

    function GetMasonaryAddress() public view returns(address){
        return address(masonaryAddress);
    }

    function setepochdetails(uint256 numberofblockspercycle, uint8 afterrebasecycles)public onlyOwner{
        epochsize= numberofblockspercycle;
        rebaseafterepochcycles=afterrebasecycles;
    }
    /**
     * @notice Sets the reference to the market oracle.
     * @param marketOracle_ The address of the market oracle contract.
     */

   
    function setMarketOracle(address marketOracle_) external onlyOwner{
        marketOracle = IOracle(marketOracle_);
    }

    function epoch() external view returns(uint256){
        return epochCount;
    }  

    function nextEpochPoint() public view returns(uint256){
        return (epochStartTime.add(epochsize * 60 * 60)) - block.timestamp;
    }  

    function incrementEpoch() public {
        if(block.timestamp >= epochStartTime + epochsize)
        {
            epochCount++;
        }
    }

    function testPrice() public view returns(uint256){
        return marketOracle.consult(address(rtokens), 1*10**18);
    }  

    // function rebase (uint256 rate) external onlyOwner returns (bool success) {
    function rebase () external onlyOwner returns (bool success){
        epochCount = epochCount + 1;
        epochStartTime = block.timestamp;

        uint256 targetrate = baseprice;
        uint256 threshholdprice = (targetrate.mul(minimumPriceThreshhold)).div(100);
        //  uint256 tokenexchangeRate = rate;//marketOracle.consult(address(rtokens)); // Change for testing
        // uint256 currentblock = blocknum;
        uint256 tokenexchangeRate= marketOracle.consult(address(rtokens),1*10**18);
        // uint256 currentblock=blocknum;
        
        //Implement Expansion logic here 
        uint256 totalSupplyofToken = rtokens.totalSupply(); 
        checkExpansion(totalSupplyofToken);

        if(tokenexchangeRate <= threshholdprice){
            int256 supplyDelta = computeSupplyDelta(tokenexchangeRate, targetrate);

            rtokens.rebase(rebasecycles, supplyDelta);

            rebasecycles.add(1);
            lastRebaseTimestampSec= block.timestamp;
            emit LogRebase(rebasecycles, tokenexchangeRate,supplyDelta, block.timestamp);
            // lastblockNum=currentblock;
            countCycle = 0;
            //rebasecyclecount=0;// this senario resets the Rebase time from last emergency rebase onwards. if i put if under if(chkthreshhold) then it will not reset time
            return true;
        }
        else{
            if(tokenexchangeRate < targetrate && tokenexchangeRate > threshholdprice){
                if(countCycle == rebasecyclecount && shouldRebase == true){
                    int256 supplyDelta = computeSupplyDelta(tokenexchangeRate, targetrate);

                    rtokens.rebase(rebasecycles, supplyDelta);
                    rebasecycles.add(1);
                    lastRebaseTimestampSec = block.timestamp;
                    emit LogRebase(rebasecycles, tokenexchangeRate,supplyDelta, block.timestamp);
                    // lastblockNum=currentblock;
                    lastblockNum = countCycle;
                    shouldRebase = true;
                    countCycle = 0;
                    rebasecyclecount = 0;// this senario resets the Rebase time from last emergency rebase onwards. if i put if under if(chkthreshhold) then it will not reset time
                    return true;
                }
                else{
                    countCycle = countCycle + 1;
                }
            }
            else{
                shouldRebase = false;
                countCycle = countCycle + 1;
            }
            if(countCycle == 6 && !shouldRebase)
            {
                shouldRebase = true;
                countCycle = 0;
            }
        }
        return false;
    }
   
    function computeSupplyDelta(uint256 rate, uint256 targetRate)public view returns (int256){
        // supplyDelta = totalSupply * (rate - targetRate) / targetRate
        int256 targetRateSigned = targetRate.toInt256Safe();
        return rtokens.totalSupply().toInt256Safe()
            .mul(rate.toInt256Safe().sub(targetRateSigned))
            .div(targetRateSigned);
    }

    function updateMinimumpriceThreshhold(uint256 threshholdPercent) public onlyOwner{
        minimumPriceThreshhold= threshholdPercent;
    }

    function checkExpansion(uint256 totalSupply) private {
        uint256 value = 0;
        if(totalSupply <= 50000 *10**18){
             value =  (4.5*100 * totalSupply) / 10000;
        }
        else if(totalSupply >50000 * 10**18 && totalSupply <= 75000 *10**18){
            value =  (4 * totalSupply) / 100;
        }
        else if(totalSupply > 75000 *10**18 && totalSupply <= 100000 *10**18){
            value =  (3.5*100 * totalSupply) / 10000;
        }
        else if(totalSupply > 100000 *10**18 && totalSupply <= 125000 *10**18){
            value =  (3 * totalSupply) / 100;
        }
        else if(totalSupply > 125000 *10**18 && totalSupply <= 150000 *10**18){
            value =  (2.5*100 * totalSupply) / 10000;
        }
        else if(totalSupply > 150000 *10**18 && totalSupply <= 175000 *10**18){
            value =  (2 * totalSupply) / 100;
        }
        else if(totalSupply > 175000 *10**18 && totalSupply <= 200000 *10**18){
             value =  (1.5*100 * totalSupply) / 10000;
        }
        else if(totalSupply > 200000 *10**18 && totalSupply <= 225000 *10**18){
            value =  (1.25*100 * totalSupply) / 10000;
        }
        else if(totalSupply > 225000 *10**18){
            value =  (1 * totalSupply) / 100;
        }

        if(value > 0){
            rtokens.mint(address(this), value);
            bool checkApproval = rtokens.approve(address(masonaryAddress), value);
            if(checkApproval){
                masonaryAddress.allocateSeigniorage(value);
            }
        }
    }
}