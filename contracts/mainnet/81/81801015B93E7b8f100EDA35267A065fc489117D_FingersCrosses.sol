/**
 *Submitted for verification at BscScan.com on 2022-10-05
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract FingersCrosses{

    Round[] public arrayRound;
    address owner;
    
    struct Round{
        uint256 roundNo;
        uint256 small;
        uint256 big;
        uint256 dateCreate;
        uint blockNumber;
    }

    constructor(){
        owner = msg.sender;
    }

    modifier checkOwner(){
        require(msg.sender==owner);
        _;
    }

    event new_round(uint256 roundNo, uint256 small, uint256 big, uint256 dateCreate, uint blockNumber);    

    function FingersCrossedGetRandomNumber(uint256 roundNumber) public checkOwner {
        uint256 small = rand(10);
        uint256 big = rand(100);
        Round memory newRound = Round(roundNumber, small, big, block.timestamp, block.number);
        arrayRound.push(newRound);
        emit new_round(newRound.roundNo, newRound.small, newRound.big, newRound.dateCreate, newRound.blockNumber); 
    }

    function getRoundDetail(uint256 _roundNumber) public view returns(uint256, uint256, uint256, uint256){
        for(uint i=0; i<arrayRound.length; i++){
            if(arrayRound[i].roundNo == _roundNumber){
                return(arrayRound[i].roundNo,arrayRound[i].small,arrayRound[i].big, arrayRound[i].blockNumber);
            }
        }
        return(0,0,0, 0);
    }

    function rand(uint256 max) public view returns(uint256)
    {
        uint256 seed = uint256(keccak256(abi.encodePacked(
            block.timestamp + block.difficulty +
            ((uint256(keccak256(abi.encodePacked(block.coinbase)))) / (block.timestamp)) +
            block.gaslimit + 
            ((uint256(keccak256(abi.encodePacked(msg.sender)))) / (block.timestamp)) +
            block.number
        )));

        
        return (seed - ((seed / max) * max));
    }

    function changeOwnerAddress(address newAddress) public checkOwner{
        require(newAddress != address(0), "Wrong address");
        owner = newAddress;
    }
}