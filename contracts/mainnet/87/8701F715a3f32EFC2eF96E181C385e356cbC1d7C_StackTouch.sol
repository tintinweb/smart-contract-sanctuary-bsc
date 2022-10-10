/**
 *Submitted for verification at BscScan.com on 2022-10-10
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

contract StackTouch {
    address private _owner;
    address public lastTouchAddress;
    uint public entryCost = 1 * 10**18;
    uint public currentRound = 0;
    uint public transactionCount = 0;
    uint public currentJackpot = 0;
    uint public devFeePercent = 4;
    uint public lastTouchTime = 0;
    uint public endTime = 0;
    uint public timeLimit = 300;
    
    mapping(address => uint) public userRewards;
    constructor() {
        _owner = msg.sender;
    }

    function UpdateEntryCost(uint256 _amount) public{
        require(msg.sender == _owner, "Only the owner may do this.");
        entryCost = _amount;
    }

    function isInProgress() public view returns (bool){
        if (lastTouchTime == 0){
            return false;
        } else if (block.timestamp - lastTouchTime < timeLimit){
            return true;
        } else{
            return false;
        }
    }

    function TouchStack() public payable{
        require(msg.value == entryCost, "Incorrect amount.");
        if (isInProgress() == false){
            userRewards[lastTouchAddress] = currentJackpot;
            currentRound += 1;
            currentJackpot = 0;
            uint addAmount = (msg.value * (100 - devFeePercent)) / 100;
            endTime = block.timestamp + timeLimit;
            lastTouchAddress = msg.sender;
            currentJackpot += addAmount;
            lastTouchTime = block.timestamp;
            payable(_owner).transfer(msg.value - addAmount);
        }else {
            uint addAmount = (msg.value * (100 - devFeePercent)) / 100;
            endTime = block.timestamp + timeLimit;
            currentJackpot += addAmount;
            lastTouchTime = block.timestamp;
            lastTouchAddress = msg.sender;
            payable(_owner).transfer(msg.value - addAmount);
        }

    }

    function claimWinnings() public {
        if (isInProgress() == false){
            userRewards[lastTouchAddress] += currentJackpot;
            currentJackpot = 0;
            require(userRewards[msg.sender] > 0, "You do not have any winnings.");
            payable(msg.sender).transfer(userRewards[msg.sender]);
            userRewards[msg.sender] = 0;
        } else {
            require(userRewards[msg.sender] > 0, "You do not have any winnings.");
            payable(msg.sender).transfer(userRewards[msg.sender]);
            userRewards[msg.sender] = 0;
        }

    }

    function getInfo(address _address) public view returns(bool, uint, uint, uint, uint, uint, address, uint){
        
        return(isInProgress(), currentJackpot, currentRound, entryCost, endTime, userRewards[_address], lastTouchAddress, block.timestamp - lastTouchTime );
    }


    function recoverStuckFunds(uint _amount) public{
        require(msg.sender == _owner, "Only the owner may do this.");
        payable(_owner).transfer(_amount);
    }

    function addToJackpot() public payable{
        currentJackpot += msg.value;
    }

    function updateTimeLimit(uint _amount) public {
        require(msg.sender == _owner, "Only the owner may do this.");
        timeLimit = _amount;
    }

    function updateDevFeePercent(uint _amount) public{
        require(msg.sender == _owner, "Only the owner may do this.");
        devFeePercent = _amount;
    }

}