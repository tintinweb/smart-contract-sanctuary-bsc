/**
 *Submitted for verification at BscScan.com on 2022-06-22
*/

//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.2;



contract Staking { 
    address public owner;

    struct Position{
        uint positionId;
        address walletAddress;
        uint createdDate;
        uint unlockDate;
        uint percentInterest;
        uint weiStaked;
        uint weiIntrest;
        bool open;
    }
    Position public position;
    uint public currentPositionId;
    mapping(uint => Position) public positions;
    mapping(address => uint[]) public positionIdByAddress;
    mapping(uint => uint) public amountOfpercentage;
    uint[] public lockPeriods;

    constructor() payable{
        owner = msg.sender;
        currentPositionId = 0;
        amountOfpercentage[30] = 300;
        amountOfpercentage[60] = 500;
        amountOfpercentage[90] = 800;

        lockPeriods.push(30);
        lockPeriods.push(60);
        lockPeriods.push(90);


    }
    function stakeEth(uint numDays) public payable{
        require(amountOfpercentage[numDays]>0,"invalid staking period");
        positions[currentPositionId] = Position(
            currentPositionId,
            msg.sender,
            block.timestamp,
            block.timestamp + (numDays * 1 days),
            amountOfpercentage[numDays],
            msg.value,
            calculateIntrest(amountOfpercentage[numDays],msg.value),
            true 
        );
        positionIdByAddress[msg.sender].push(currentPositionId);
        currentPositionId+=1;
    }
    function calculateIntrest(uint percentage, uint weiAmount) private pure returns(uint){
        return percentage * weiAmount / 10000;
    }
    function modifyLockUpPeriods(uint numDays, uint changedPercentage   ) public{
        require(owner == msg.sender , "only owner can change staking Period");
        amountOfpercentage[numDays] = changedPercentage;
    }
    function getLockUpPeriods() external view returns(uint[] memory){
        return lockPeriods;
    }
    function getIntrestRate(uint numDays) external view returns(uint){
        return amountOfpercentage[numDays];
    } 
    function getPositionById(uint positionId ) external view returns(Position memory){
        return positions[positionId];
    }
    function getPositionByAddress(address walletAddress) external view returns(uint[] memory){
        return positionIdByAddress[walletAddress];
    }
    function changeLockUpDate(uint positionId,uint newLockUpDate) external returns(uint){
        require(owner == msg.sender , "only owner can change lockUpPeriod");

        return positions[positionId].unlockDate = newLockUpDate;
    }

    
    function closePosition(uint positionId) public returns(bool)  {
        require(positions[positionId].walletAddress == msg.sender,"only position creator can close this position");
        require(positions[positionId].open == true ,"u have alresdy closed the position");
        positions[positionId].open = false;

        if(block.timestamp > positions[positionId].unlockDate) {
            uint amount = positions[positionId].weiStaked + positions[positionId].weiIntrest;
            address payable user1 = payable(msg.sender);
            (bool sent,) = user1.call{value:amount}("");
            return sent;
        }else{
            address payable user1 = payable(msg.sender);
           (bool sent,) =  user1.call{value:positions[positionId].weiStaked}("");
           return sent;
        }  
    }
}