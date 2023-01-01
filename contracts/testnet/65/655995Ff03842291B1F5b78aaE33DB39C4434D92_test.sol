/**
 *Submitted for verification at BscScan.com on 2022-12-31
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract test {

    // blocks are mined at a frequency of 10 minutes per block.
    //Start Reward 10,000 MNB
    //52,560

    uint public Mined;
    uint public miningStartAt;
    uint public frequency = 10 minutes;
    uint public deflationRate = 75;   //reverse logic
    uint denominator = 100;

    function startMining() public {
        require(miningStartAt == 0,"Error: Already Started!");
        miningStartAt = block.timestamp;
    }

    function setMiningTime(uint value) public {
        miningStartAt = value;   
    }

    function getTriggerInfo() public view returns (uint mintable) {
        uint firstDeflation = 52560;
        uint sReward = 10000;   
        uint getBlock = getBlocks();
        uint adder = firstDeflation;
        uint subber = 0;
        uint blockdelta = firstDeflation;
        uint rewarddelta = sReward;
        uint coin = 0;

        if(getBlock > firstDeflation) {
            coin = firstDeflation * sReward;
            for(uint i = 0; i < 25; i++) {
                uint tblock = blockdelta*deflationRate/denominator;
                uint tReward = rewarddelta*deflationRate/denominator;
                adder = adder + tblock;
                subber = subber + blockdelta;
                if(getBlock > adder) {
                    coin += tblock*tReward;
                    blockdelta = tblock;
                    rewarddelta = tReward;
                }
                else {
                    uint wr = getBlock - subber;
                    coin += wr * tReward;
                    break;
                }
            }
        }
        else {
            coin = getBlock * sReward;
        }
        return coin - Mined;
    }

    function elapsedTime() public view returns (uint) {
        return miningStartAt > 0 ? block.timestamp - miningStartAt : 0;
    }

    function getBlocks() public view returns (uint) {
        uint getSec = elapsedTime();
        uint getBlock = getSec / frequency;
        return getBlock;
    }

    function getTime() public view returns (uint) {
        return block.timestamp;
    }


}